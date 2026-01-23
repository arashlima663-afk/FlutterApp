import db as _database
import models as _models
import sqlalchemy.orm as _orm
import random,string
import asyncio, os, dotenv, pathlib 
import datetime as _dt
import jwt, base64, time
from secrets import choice   
from string import printable
import schemas as _schemas
from sqlalchemy import ForeignKey, func, select
from sqlalchemy.ext.asyncio import (
    AsyncAttrs,
    create_async_engine,
    AsyncSession,
    async_sessionmaker,
)
from sqlalchemy.orm import (
    DeclarativeBase,
    Mapped,
    mapped_column,
    relationship,
    selectinload,
)
from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.hazmat.primitives.serialization import load_pem_public_key, load_pem_private_key


dotenv.load_dotenv(override=True)

class one_pad_encrypt:
    def __init__(self, message:str):
        self.message = message
        self.pad=""
        self.ciphertext = ""
        self.plaintext = ""
        self.pad = ''.join(choice(string.printable) for _ in range(len(self.message)))

    def encrypt(self) -> str:
        self.ciphertext = ''.join(chr(ord(m) ^ ord(p)) for m, p in zip(self.message, self.pad))
        return self.ciphertext

    def decrypt(self) -> str:
        decrypted = ''.join(chr(ord(c) ^ ord(p)) for c, p in zip(self.ciphertext, self.pad))
        return decrypted



async def create_db():
    async with _database.engine.begin() as conn:
        await conn.run_sync(_models.Base.metadata.create_all)
    await _database.engine.dispose()



async def get_async_db() -> AsyncSession:
    async with _database.async_session() as db:
        yield db


async def create_user(user: _schemas.PublicKeyRequest_Base, db: AsyncSession):
     user_obj = _models.Keys(pv_key=private_key, pub_key=public_key, owner_id_onepadded=owner_id, )
     db.add(user_obj)
     db.commit(user_obj)
     db.refresh(user_obj)


async def get_user_by_owner_id(owner_id:str , db: AsyncSession):
    result = await db.execute(select(_models.Keys).where(_models.Keys.owner_id == owner_id))
    if result:
        return result.first()
    else:
        return None


class key_generating:
    __slots__ = ('pv_bytes', 'pub_bytes', 'pv_str', 'pub_str', 'aes_key','private_key_Ed25519','public_key_Ed25519')

    def __init__(self):
        private_key = x25519.X25519PrivateKey.generate()
        public_key = private_key.public_key()

        # Store keys as Base64 strings for easy transport / JSON
        self.pv_bytes = private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption())

        self.pub_bytes = public_key.public_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PublicFormat.SubjectPublicKeyInfo)

    def key_pair_bytes(self) -> tuple[bytes, bytes]:
        return self.pv_bytes, self.pub_bytes

    def key_pair_str(self) -> tuple[str, str]:
        self.pv_str=str(self.pv_bytes.decode().splitlines()[1])
        self.pub_str = str(self.pub_bytes.decode().splitlines()[1])
        return self.pv_str, self.pub_str

    def generate_aes_key(self, remote_public_key_b64: str) -> bytes:
        remote_pub_bytes = base64.b64encode(remote_public_key_b64)
        remote_public_key = x25519.X25519PublicKey.from_public_bytes(remote_pub_bytes)

        shared_secret = self.pv_bytes.exchange(remote_public_key)

        self.aes_key = HKDF(
            algorithm=hashes.SHA256(),
            length=32,
            salt=None,
            info=b"handshake data",
        ).derive(shared_secret)

        return self.aes_key
    

    
    

def generate_Ed25519(env_path=".env"):
    dotenv.load_dotenv(env_path)

    private_key = Ed25519PrivateKey.generate()
    public_key = private_key.public_key()

    private_key_Ed25519 = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )
    dotenv.set_key(env_path, "SERVER_PV_Ed25519", private_key_Ed25519, quote_mode='never')
    
    public_key_Ed25519 = public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
    dotenv.set_key(env_path, "SERVER_PUB_Ed25519", public_key_Ed25519, quote_mode='never')

    return private_key_Ed25519, public_key_Ed25519

# TODO dotenv
def generate_token(user: _schemas.PublicKeyRequest_Base, private_key: bytes, expire:int) -> str:
    user_schema_obj = _schemas.PublicKeyRequest_Base.model_validate(user)
    user_dict = user_schema_obj.model_dump()
    user_dict.update({'exp': expire})

    pv = load_pem_private_key(private_key, password=None)

    encoded_jwt = jwt.encode(user_dict, pv, algorithm="EdDSA")
    return encoded_jwt


def key_pairs(env_path=".env"):
    file_path = pathlib.Path.cwd().absolute()/"old_keys.txt"
    # while True:
    init = key_generating()
    SERVER_PV_KEY, SERVER_PUB_KEY = init.key_pair_str()
    SERVER_PV_Ed25519, SERVER_PUB_Ed25519 = init.generate_Ed25519()

    with file_path.open("a", encoding="utf-8") as f:
        f.write(f"SERVER_PUB_KEY:{SERVER_PUB_KEY}\t SERVER_PV_KEY:{SERVER_PV_KEY}\t SERVER_PUB_Ed25519:{SERVER_PUB_Ed25519}\t SERVER_PV_Ed25519:{SERVER_PV_Ed25519}\n")

    dotenv.set_key(".env", "SERVER_PV_KEY", SERVER_PV_KEY)
    dotenv.set_key(".env", "SERVER_PUB_KEY", SERVER_PUB_KEY)
    dotenv.set_key(".env", "SERVER_PV_Ed25519", SERVER_PV_Ed25519, quote_mode='never')
    dotenv.set_key(".env", "SERVER_PUB_Ed25519", SERVER_PUB_Ed25519, quote_mode='never')
    # time.sleep(15*60)

    return SERVER_PV_Ed25519, SERVER_PUB_Ed25519
    


def verify_token(jwt_token: str, secret: bytes) -> dict:
    try:
        payload = jwt.decode(jwt_token, load_pem_public_key(bytes(secret)), algorithms=["EdDSA"])
        return payload
    except jwt.exceptions.ExpiredSignatureError:
        print("Token expired")


if __name__ == "__main__":
    req = _schemas.PublicKeyRequest_Base(
    title="My Public Key",
    owner_id="user_123")


    # pub_key_str = os.getenv("SERVER_PUB_Ed25519").replace("'", '"""')
    # priv_key_str = os.getenv("SERVER_PV_Ed25519")
    

    
    
    