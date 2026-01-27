
import schemas as _schemas
import services as _services
from models import Ed25519_Key,X25519_Key, User, Base, engine
import fastapi as _fastapi
import sqlalchemy.orm as _orm
from fastapi.middleware.cors import CORSMiddleware
import sqlalchemy as _sql
import datetime as _dt
from fastapi.middleware.cors import CORSMiddleware
from secrets import choice   
import random,string, threading, asyncio
from concurrent.futures import ThreadPoolExecutor
import base64
from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives import serialization

Base.metadata.drop_all(engine)
Base.metadata.create_all(engine)

threads = [threading.Thread(target=_services.generating_x_keys, daemon=True), threading.Thread(target=_services.generating_ed_keys, daemon=True)]
for t in threads:
    t.start()


app = _fastapi.FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:27432"],  # adjust to your client
    allow_credentials=True,
    allow_methods=["*"],  # allow GET, POST, PUT, DELETE, OPTIONS
    allow_headers=["*"],
)



# @app.get("/")
# async def create_user():


#     return {'pubKey':" String pubKey", 'exp': 123456789, 'jwt': "String jwt"}




@app.post("/key")
async def create_user(user: _schemas.PublicKeyRequest_Base, db: _orm.Session = _fastapi.Depends(_services.create_get_db)):
    owner = user.owner_id
    user_exist = await _services.get_user_by_owner_id(owner, db)
    if user_exist:

        return {'pub_key':"user_exist", 'exp': 111111, 'jwt': "user_exist user_exist"}

    row_object_x25519, row_object_ed25519 = _services.get_newest_KeyRows(db)

    server_pub, ed25519_pv = (row_object_x25519.pub_key, row_object_ed25519.pv_key_Ed25519)
    aes = _services.sharedSecret_AES(user.clientPublicKeyBase64, bytes(row_object_x25519.pv_key))
    
    expire = int(_dt.datetime.now().timestamp() + 360)

    new_owner_id = str(user.owner_id+"@"+''.join(choice(string.printable.replace('@', '')) for _ in range(7)))

    loaded_public_key = x25519.X25519PublicKey.from_public_bytes(server_pub).public_bytes(encoding=serialization.Encoding.PEM, format=serialization.PublicFormat.SubjectPublicKeyInfo)

    payload = {"owner_id": new_owner_id, "pub_key": loaded_public_key.decode().splitlines()[1], "exp":expire}

    token = _services.generate_token_payload(payload, ed25519_pv)

    key_response = {"owner_id": user.owner_id, "pub_key": loaded_public_key.decode().splitlines()[1], "jwt":token}
    Public_Key_Response = _schemas.PublicKeyResponse.model_validate(key_response)

    db_user = User(owner_id=new_owner_id, jwt=token, ed25519_key_id = row_object_ed25519.id, x25519_key_id=row_object_x25519.id, exp=expire, clientPublicKeyBase64 = user.clientPublicKeyBase64, sharedSecret_AES=aes)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return Public_Key_Response.model_dump(mode='json')



from fastapi import UploadFile, File, Form

@app.post("/data")
async def data_incoming(
    title: str = Form(...),
    img: UploadFile = File(...),
):
    data = await img.read()  # bytes
    print(type(data))        # <class 'bytes'>
    print(len(data))
    return {"status": "ok"}