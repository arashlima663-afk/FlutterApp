from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives import serialization

import uuid, os, sqlite3, aiosqlite
from typing import List, Optional, Annotated

from fastapi import FastAPI, File, UploadFile


conn = sqlite3.connect('example.db')
cursor = conn.cursor()
app = FastAPI(title='Fast API',description='Flutter Client')

cursor.execute('''
CREATE TABLE IF NOT EXISTS database (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pub_key TEXT,
    pv_key TEXT,
    aes TEXT,
    enc_photo TEXT
)
''')

conn.commit()

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



@app.get("/init")
async def comes_to_server():
    private_key, public_key = generate_key_pair()

    
    

    return 'comes to server'



@app.post("/")
async def to_client(file: Annotated[bytes, File(description="A file read as bytes")]):

    return 'to client'




@app.get("/")
async def comes_to_server():

    return 'comes to server'




