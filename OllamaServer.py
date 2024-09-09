# OllamaServer.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain.chains import RetrievalQA
from langchain_community.llms import Ollama
from transformers import pipeline


app = FastAPI()


# Global variables to store the document data and QA chain
qa_chain = None
vector_store = None
loaded_documents = []

class DocumentInput(BaseModel):
    content: str

class QueryInput(BaseModel):
    question: str

# Set up the LLM (Ollama)
llm = Ollama(model="llama3")
@app.post("/load")
def load_document(document: DocumentInput):
    """Load the document into the RAG model."""
    global qa_chain, vector_store, loaded_documents
    
    # Load the document content
    content = document.content
    loaded_documents.append(content)
    
    # Split the document into chunks
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=0)
    chunks = text_splitter.split_text(content)  # Adjusted to use split_text directly on the string
    
    # Use HuggingFaceEmbeddings for embeddings
    embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
    
    # Create a FAISS vector store
    vector_store = FAISS.from_texts(chunks, embeddings)  # Updated to directly create a vector store from chunks of text
    
    # Set up the RAG pipeline with Ollama
    retriever = vector_store.as_retriever()
    qa_chain = RetrievalQA.from_chain_type(llm, retriever=retriever)
    
    return {"message": "Document loaded successfully"}

@app.post("/unload")
def unload_documents():
    """Unload all documents from the RAG model."""
    global qa_chain, vector_store, loaded_documents
    
    qa_chain = None
    vector_store = None
    loaded_documents.clear()
    
    return {"message": "All documents unloaded successfully"}

@app.post("/query")
def query_document(query: QueryInput):
    """Query the RAG model about the loaded documents."""
    global qa_chain
    if qa_chain is None:
        raise HTTPException(status_code=400, detail="No documents are currently loaded.")
    
    response = qa_chain({"query": query.question})
    return {"answer": response['result']}

@app.post("/summarize")
def summarize_document(document: DocumentInput = None):
    """Summarize the document content using RAG. If a document is passed, unload the previous document and summarize the new one."""
    global qa_chain, vector_store
    
    # Case 1: A new document is passed, unload the previous document (if any)
    if document is not None and document.content:
        # Unload the previous document
        qa_chain = None
        vector_store = None
        
        # Load the new document and summarize it
        content = document.content
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=0)
        chunks = text_splitter.split_text(content)
        
        # Create embeddings and store them in FAISS
        embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
        vector_store = FAISS.from_texts(chunks, embeddings)
        
        # Create a retriever from the vector store
        retriever = vector_store.as_retriever()
        
        # Create the QA chain using the retriever and LLM
        llm = Ollama(model="llama3")
        qa_chain = RetrievalQA.from_chain_type(llm, retriever=retriever)
    
    # Case 2: No document passed, use the currently loaded document
    elif qa_chain is None:
        raise HTTPException(status_code=400, detail="No documents are currently loaded. Please load a document or pass one for summarization.")
    
    # Step 1: Query for summarization using the existing or newly created chain
    # You may want to tweak this query based on what data you're sending in
    query = "Please summarize the key points of this document."
    response = qa_chain({"query": query})
    
    # Step 2: Return the generated summary
    return {"bullet_points": response['result']}

# To run the server, use: `uvicorn OllamaServer:app --host 0.0.0.0 --port 8000`
