from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives import serialization

import uuid, os, asyncio
from typing import List, Optional, Annotated

from create_db import Database
from fastapi import FastAPI, File, UploadFile 
from fastapi.responses import PlainTextResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
origins = ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def generate_key_pair():
    private_key = x25519.X25519PrivateKey.generate()
    private_key_bytes = private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption()).decode("utf-8").replace("-----BEGIN PRIVATE KEY-----", "").replace("-----END PRIVATE KEY-----", "").replace("\n", "")

    public_key = private_key.public_key()
    public_key_bytes = public_key.public_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PublicFormat.SubjectPublicKeyInfo).decode("utf-8").replace("-----BEGIN PUBLIC KEY-----", "").replace("-----END PUBLIC KEY-----", "").replace("\n", "")

    return private_key_bytes, public_key_bytes




@app.get("/keychange", response_class=JSONResponse)
async def to_client():
    private_key, public_key = generate_key_pair()
    db = await Database.Connect()
    await Database.Insert(db, pub_key= public_key, pv_key= private_key)



    return {'public_key':public_key}
    

@app.get("/")
async def comes_to_server():

    return 'comes to server'


