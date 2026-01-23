
from pathlib import Path
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
import schemas as _schemas
import services as _services
import fastapi as _fastapi
import db, services, os
import sqlalchemy.orm as _orm
from db import engine
from models import Keys
from fastapi.middleware.cors import CORSMiddleware
import base64
from sqlalchemy.ext.asyncio import AsyncSession
import sqlalchemy as _sql
import dotenv, os
import datetime as _dt
app = _fastapi.FastAPI()


from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["127.0.0.1:51704"],  # Flutter DevTools
    allow_methods=["*"],
    allow_headers=["*"],
)
SERVER_PUB_Ed25519=b'-----BEGIN PUBLIC KEY-----\nMCowBQYDK2VwAyEAkx1HBvEpDXOOCv4IaH5vRm1VU/GaZBv9AXbckg9hCdE=\n-----END PUBLIC KEY-----\n'
SERVER_PV_Ed25519=b'-----BEGIN PRIVATE KEY-----\nMC4CAQAwBQYDK2VwBCIEIAhdEcw4+JqRVS8inJKO5uJoq/OMZtXJ/4z9x1LdutFD\n-----END PRIVATE KEY-----\n'
    


@app.get("/key")
async def create_user():
    return 'Hello'


@app.get("/key")
async def create_user(user: _schemas.PublicKeyRequest_Base, db: AsyncSession = _fastapi.Depends(_services.get_async_db), env_path=".env"):
    
    db_user = _services.get_user_by_owner_id(db, owner_id=user.owner_id)

    if(db_user):
        raise _fastapi.HTTPException(status_code=400, detail="there is the user with owner_id")
    else:
        expire_time = int((_dt.datetime.now() + _dt.timedelta(minutes=5)).timestamp())
        generated_jwt = _services.generate_token(user, SERVER_PV_Ed25519, expire_time)
        user_obj = Keys(pub_key= 'secret', owner_id=user.owner_id, jwt=generated_jwt, data_created = user.date_created, expire = expire_time)

        await db.add(user_obj)
        await db.commit(user_obj)
        await db.refresh(user_obj)
    
        payload = _schemas.PublicKeyResponse(pub_key= 'secret', exp=expire_time, jwt=generated_jwt)

    return payload
    
    
    
# @app.post("/")
# async def save_text(file: _fastapi.UploadFile = _fastapi.File()):
#     path = Path.cwd()/f"{str(uuid.uuid4())}.jpg"
#     content = await file.read()
#     with open (path, "wb") as f:
#         f.write(content)
#     return
