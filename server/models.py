import datetime as _dt
import random,string
import sqlalchemy as _sql
import sqlalchemy.orm as _orm
import passlib.hash as _hash
from passlib.context import CryptContext
import jwt

import db as _database

class Keys(_database.Base):
    __tablename__ = "keys"
    id = _sql.Column(_sql.Integer, primary_key=True, index = True)
    pv_key = _sql.Column(_sql.String, unique=True, index = True)
    pub_key = _sql.Column(_sql.String, unique=True, index = True)
    owner_id = _sql.Column(_sql.Integer, unique=True, index = True)
    hashed_token = _sql.Column(_sql.String, unique=True, index = True)
    data_created = _sql.Column(_sql.DateTime, default=_dt.datetime.utcnow())
    expires_in = _sql.Column(_sql.DateTime, default=_dt.datetime.utcnow()+ _dt.timedelta(minutes=3))
    in_token = _sql.Column(_sql.String, unique=True, index = True)
    image = _sql.Column(_sql.LargeBinary)

    def generate_token(self, data: dict, secret='secret'):
        to_encode = data.copy()
        expire = _dt.datetime.utcnow() + _dt.timedelta(minutes=3)
        to_encode.update({'exp':expire})
        encoded_jwt = jwt.encode(to_encode, secret, algorithm="HS256")
        return encoded_jwt

    def verify_token(self, token:str, secret='secret'):
            try:
                payload = jwt.decode(token, secret, algorithm="HS256")
                return payload
            except jwt.JWTError:
                return None

    
    def generate_owner_id() -> str:
        chars = string.ascii_letters + string.digits
        return ''.join(random.choices(chars, random.randrange(6,11)))
         


# class Incomming(_database.Base):
#     __tablename__ = "incomming"
#     id = _sql.Column(_sql.Integer, primary_key=True, index = True)
#     image = _sql.Column(_sql.LargeBinary)
#     owner_id = _sql.Column(_sql.Integer, _sql.ForeignKey("keys.owner_id"))
#     in_token = _sql.Column(_sql.String, unique=True, index = True)
#     data_created = _sql.Column(_sql.DateTime, default=_dt.datetime.utcnow)

#     owner = _orm.relationship("Keys", back_populates="incomming")

#     def verify_token(self, in_token:str):
#         return _hash.bcrypt.verify(in_token, self.hashed_token)


