import datetime as _dt
import random,string
import sqlalchemy as _sql
import sqlalchemy.orm as _orm
import passlib.hash as _hash
from passlib.context import CryptContext
import jwt
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.ext.asyncio import AsyncSession, AsyncAttrs


import db as _database

class Base(AsyncAttrs, DeclarativeBase):
    pass


class Keys(Base):
    __tablename__ = "keys"
    id = _sql.Column(_sql.Integer, primary_key=True, index = True)
    pv_key = _sql.Column(_sql.String, unique=True, index = True)
    pub_key = _sql.Column(_sql.String, unique=True, index = True)
    owner_id = _sql.Column(_sql.Integer, unique=True, index = True)
    jwt = _sql.Column(_sql.String, unique=True, index = True)
    in_token = _sql.Column(_sql.String, unique=True, index = True)
    data_created = _sql.Column(_sql.Integer)
    exp = _sql.Column(_sql.Integer)
    image = _sql.Column(_sql.LargeBinary)


# class Users(Base):
#     __tablename__ = "user"
#     id = _sql.Column(_sql.Integer, primary_key=True, index = True)
#     owner_id = _sql.Column(_sql.Integer, unique=True, index = True)
#     jwt = _sql.Column(_sql.String, unique=True, index = True)
#     data_created = _sql.Column(_sql.Integer)
#     exp = _sql.Column(_sql.Integer)
#     image = _sql.Column(_sql.LargeBinary)

#     keys = _orm.relationship("Keys", back_populates="user")


# class Keys(Base):
#     __tablename__ = "keys"

#     id = _sql.Column(_sql.Integer, primary_key=True, index=True)

#     owner_id = _sql.Column(
#         _sql.Integer,
#         unique=True,
#         index=True,
#         nullable=False
#     )

#     pv_key = _sql.Column(_sql.String, unique=True, index=True)
#     pub_key = _sql.Column(_sql.String, unique=True, index=True)

#     pv_key_Ed25519 = _sql.Column(_sql.String, unique=True, index=True)
#     pub_key_Ed25519 = _sql.Column(_sql.String, unique=True, index=True)

#     created_at = _sql.Column(
#         _sql.Integer,
#         default=lambda: int(_dt.datetime.now().timestamp())
#     )

#     user = _orm.relationship(
#         "Users",
#         back_populates="keys"
#     )


