from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF

from pathlib import Path
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
import schemas as _schemas
import fastapi as _fastapi
import db, services
import sqlalchemy.orm as _orm
from sqlalchemy.orm import Session
from db import Base, engine, SessionLocal
from models import Keys
from fastapi.middleware.cors import CORSMiddleware
import base64


def create_db():
    
    return Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


app = _fastapi.FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_methods=["*"],  
    allow_headers=["*"],
)


class key_generating:

    def generate_key_pair(self):
        private_key = x25519.X25519PrivateKey.generate()
        public_key = private_key.public_key()

        # Store keys as Base64 strings for easy transport / JSON
        private_key_bytes = private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption())

        public_key_bytes = public_key.public_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PublicFormat.SubjectPublicKeyInfo)
        
        return private_key_bytes, public_key_bytes
    
    def key_pair_str(self, private_key_bytes:bytes, public_key_bytes: bytes) ->str:
        return str(private_key_bytes).split('\\n')[1], str(public_key_bytes).split('\\n')[1]

    def generate_aes_key(self, remote_public_key_b64: str, private_key_bytes:bytes) -> bytes:
        remote_pub_bytes = base64.b64encode(remote_public_key_b64)
        remote_public_key = x25519.X25519PublicKey.from_public_bytes(remote_pub_bytes)

        shared_secret = private_key_bytes.exchange(remote_public_key)

        aes_key = HKDF(
            algorithm=hashes.SHA256(),
            length=32,
            salt=None,
            info=b"handshake data",
        ).derive(shared_secret)

        return aes_key
    


    
@app.get("/key")
async def create_user(db:Session):
    private_key_bytes, public_key_bytes = key_generating().generate_key_pair()
    private_key_str, public_key_atr = key_generating().key_pair_str(private_key_bytes, public_key_bytes)
    new_key = Keys(pv_key=private_key_str, pub_key=public_key_atr)
    db.add(new_key)
    db.commit()
    db.refresh(new_key)

    return {"pub_key": f"{'done'}"}
    
    

# @app.post("/")
# async def save_text(file: _fastapi.UploadFile = _fastapi.File()):
#     path = Path.cwd()/f"{str(uuid.uuid4())}.jpg"
#     content = await file.read()
#     with open (path, "wb") as f:
#         f.write(content)
#     return




