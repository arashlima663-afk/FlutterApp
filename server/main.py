
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
import base64, uuid, pathlib
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
    allow_origins=["*"],  # adjust to your client
    allow_credentials=True,
    allow_methods=["*"],  # allow GET, POST, PUT, DELETE, OPTIONS
    allow_headers=["*"],
)



@app.post("/key")
async def create_user(user: _schemas.PublicKeyRequest_Base, db: _orm.Session = _fastapi.Depends(_services.create_get_db)):
    owner = user.owner_id
    print(user)
    user_exist = await _services.get_user_by_owner_id(owner, db)
    if user_exist:

        return {'pub_key':"user_exist", 'exp': 111111, 'jwt': "user_exist user_exist"}

    row_object_x25519, row_object_ed25519 = _services.get_newest_KeyRows(db)
    server_pv, server_pub, ed25519_pv = (row_object_x25519.pv_key, row_object_x25519.pub_key, row_object_ed25519.pv_key_Ed25519)

    aes = _services.sharedSecret_AES(user.clientPublicKeyBase64, server_pv, user.hkdfNonce)
    
    expire = int(_dt.datetime.now().timestamp() + 360)

    new_owner_id = str(user.owner_id+"@"+''.join(choice(string.printable.replace('@', '')) for _ in range(7)))
    payload = {"owner_id": new_owner_id, "pub_key": base64.b64encode(server_pub).decode('utf-8'), "exp":expire}
    token = _services.generate_token_payload(payload, ed25519_pv)

    key_response = {"owner_id": user.owner_id, "pub_key": base64.b64encode(server_pub).decode('utf-8'), "jwt":token}
    Public_Key_Response = _schemas.PublicKeyResponse.model_validate(key_response)

    db_user = User(owner_id=new_owner_id, jwt=token, ed25519_key_id = row_object_ed25519.id, x25519_key_id=row_object_x25519.id, exp=expire, clientPublicKeyBase64 = user.clientPublicKeyBase64, sharedSecret_AES=aes, aesNonce=user.aesNonce)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    print(Public_Key_Response.model_dump(mode='json'))
    print(base64.b64encode(server_pv).decode('utf-8'))
    print(base64.b64encode(aes).decode('utf-8'))

    return Public_Key_Response.model_dump(mode='json')




@app.post("/data")
async def upload_cipher(req: dict, db: _orm.Session = _fastapi.Depends(_services.create_get_db)):
    # old_owner = req.owner_id
    user_exist = await _services.get_user_by_owner_id(req['owner_id'], db)
    if not user_exist:
        raise _fastapi.HTTPException(status_code=404, detail="User not found")
    
    path = pathlib.Path('.') / 'images' / (str(uuid.uuid4()) + '.jpg')
    with open(path, "wb") as f:
        f.write(_services.decrypt_aes(user_exist.sharedSecret_AES, user_exist.aesNonce, req["ciphertext"], req["mac"]))
    

    print(base64.b64encode(user_exist.sharedSecret_AES).decode('utf-8'))
    return {'ok':'ok'}

