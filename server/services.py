import models as _models
import sqlalchemy.orm as _orm
import sqlalchemy as _sql
import datetime as _dt
import jwt, base64, time, random
import schemas as _schemas

from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey,Ed25519PublicKey
from cryptography.hazmat.primitives.serialization import load_pem_public_key, load_pem_private_key
from models import engine


def create_get_db():
    if not (_sql.inspect(_models.engine).has_table("x25519") and _sql.inspect(_models.engine).has_table("users")):
        _models.Base.metadata.drop_all(_models.engine)
        _models.Base.metadata.create_all(_models.engine)

    db = _models.SessionLocal()
    try:
        yield db
    finally:
        db.close()



async def get_user_by_owner_id(owner_id: str , db: _orm.Session):
    query = _sql.select(_models.User).where( _sql.func.substr(_models.User.owner_id, 1, _sql.func.instr(_models.User.owner_id, "@") - 1 ) == owner_id)
    result = db.execute(query)
    if result:
        return result.scalars().first()
    else:
        return False



def get_newest_KeyRows(db: _orm.Session):
    x25519_stmt = (_sql.select(_models.X25519_Key).order_by(_models.X25519_Key.x25519_created_at.desc()).limit(1))
    ed25519_stmt = (_sql.select(_models.Ed25519_Key).order_by(_models.Ed25519_Key.ed25519_created_at.desc()).limit(1))
    x25519_result = db.execute(x25519_stmt).scalar_one_or_none()
    ed25519_result = db.execute(ed25519_stmt).scalar_one_or_none()
    return (x25519_result, ed25519_result)



class key_generating:
    __slots__ = ('pv_bytes', 'pub_bytes','pv_str', 'pub_str','private_key_Ed25519','public_key_Ed25519')

    def __init__(self):

        private_key = x25519.X25519PrivateKey.generate()
        public_key = private_key.public_key()

        # Store keys as Base64 strings for easy transport / JSON
        self.pv_bytes = private_key.private_bytes(
                encoding=serialization.Encoding.Raw,
                format=serialization.PrivateFormat.Raw,
                encryption_algorithm=serialization.NoEncryption())

        self.pub_bytes = public_key.public_bytes(
                encoding=serialization.Encoding.Raw,
                format=serialization.PublicFormat.Raw)

    def key_pair_bytes(self) -> tuple[bytes, bytes]:
        return self.pv_bytes, self.pub_bytes

    def key_pair_str(self) -> tuple[str, str]:
        self.pv_str=str(self.pv_bytes.decode().splitlines()[1])
        self.pub_str = str(self.pub_bytes.decode().splitlines()[1])
        return self.pv_str, self.pub_str
   

    def generate_Ed25519(self):

        private_key = Ed25519PrivateKey.generate()
        public_key = private_key.public_key()

        self.private_key_Ed25519 = private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption())
        
        self.public_key_Ed25519 = public_key.public_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PublicFormat.SubjectPublicKeyInfo)

        return self.private_key_Ed25519, self.public_key_Ed25519



def sharedSecret_AES(clientPublicKeyBase64: str, server_private_bytes: bytes, nonce:str):
    # Load server private key from raw 32 bytes
    server_private_key = x25519.X25519PrivateKey.from_private_bytes(server_private_bytes)

    # Load client public key from Base64

    client_pub_bytes = base64.b64decode(clientPublicKeyBase64.encode('utf-8'))
    client_public_key = x25519.X25519PublicKey.from_public_bytes(client_pub_bytes)

    # Compute shared secret
    shared_secret = server_private_key.exchange(client_public_key)

    # Derive AES key from shared secret
    nonce = base64.b64decode(nonce)

    aes_key_bytes = HKDF(
        algorithm=hashes.SHA256(),
        length=32,
        salt=nonce,
        info=None,
    ).derive(shared_secret)
    aes_key_str= base64.b64encode(aes_key_bytes).decode('utf-8')
    return aes_key_bytes



def decrypt_aes(key: bytes, nonce: str, ciphertext, mac) -> bytes:
    nonce = base64.b64decode(nonce)
    ciphertext = bytes(ciphertext)
    mac = bytes(mac)
    aesgcm = AESGCM(key)
    data = aesgcm.decrypt(nonce, ciphertext + mac, None)

    return data



def generate_token_payload(payload: dict, private_key) -> str:
    secret_pv = private_key.decode()
    token = jwt.encode(payload, secret_pv, algorithm="EdDSA")
    return token


def verify_token(jwt_token: str, public_key) -> dict:
    try:
        secret_pub = public_key.decode()
        payload = jwt.decode(jwt_token, secret_pub, algorithms=["EdDSA"])
        return payload
    except jwt.exceptions.ExpiredSignatureError:
        print("Token expired")




def generating_x_keys():
    while True:
        
        try:
            db: _orm.Session = _models.SessionLocal()
            a = key_generating()
            server_pv, server_pub = a.key_pair_bytes()
            new_keys = _models.X25519_Key(pv_key=server_pv, pub_key=server_pub)
            db.add(new_keys)
            db.commit()
            db.refresh(new_keys)

        except Exception as e:
            db.rollback()
            print("Key generation error:", e)
        finally:
            db.close()

        time.sleep(random.randint(30*60,40*60))


def generating_ed_keys():
    while True:
        
        try:
            db: _orm.Session = _models.SessionLocal()
            b = key_generating()
            ed25519_pv, ed25519_pub = b.generate_Ed25519()
            new_keys = _models.Ed25519_Key(pv_key_Ed25519=ed25519_pv, pub_key_Ed25519=ed25519_pub)

            db.add(new_keys)
            db.commit()
            db.refresh(new_keys)

        except Exception as e:
            db.rollback()
            print("Key generation error:", e)

        finally:
            db.close()

        time.sleep(random.randint(20*60,30*60))



# if __name__ == "__main__":
