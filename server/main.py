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



class Base(DeclarativeBase):
    pass

class Keys(Base):
    __tablename__ = "ephemeral_keys"
    id: Mapped[int] = mapped_column(primary_key=True)
    pv_key: Mapped[bytes] = mapped_column(LargeBinary(33))
    pub_key: Mapped[bytes] = mapped_column(LargeBinary(33))
    


    def __repr__(self) -> str:
        return f"Key (id={self.id}, pub_key={self.pub_key}, pv_key={self.pv_key})"





@app.put("/")
async def to_client(file: Annotated[bytes, File(description="A file read as bytes")]):
    # engine = create_async_engine("sqlite+aiosqlite://keys.db", echo=True)

    # pv, pub = generate_key_pair()

    # async with async_sessionmaker(engine, expire_on_commit=True) as session:
    #     key_entry = Keys(pub_key=pv, pv_key=pub)
    #     async with session.begin():
    #         session.add(key_entry)

    return 'to client'

@app.get("/")
async def comes_to_server():

    return 'comes to server'




