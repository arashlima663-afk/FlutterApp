from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives import serialization

import uuid, os
from typing import List, Optional, Annotated

from sqlalchemy import LargeBinary
from sqlalchemy.orm import DeclarativeBase,Mapped, mapped_column, Session, sessionmaker

from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker


from fastapi import FastAPI, File, UploadFile


app = FastAPI(title='Fast API',description='Flutter Client')

UPLOAD_DIR = "uploaded_images"

def generate_key_pair():
    private_key = x25519.X25519PrivateKey.generate()
    private_key_bytes = private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption())

    public_key = private_key.public_key()
    public_key_bytes = public_key.public_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PublicFormat.SubjectPublicKeyInfo)
    
    return private_key_bytes, public_key_bytes







@app.put("/")
async def to_client(file: Annotated[bytes, File(description="A file read as bytes")]):

    return 'to client'

@app.get("/")
async def comes_to_server():

    return 'comes to server'




