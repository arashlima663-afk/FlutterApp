import datetime as _dt
import sqlalchemy as _sql
import sqlalchemy.orm as _orm
from sqlalchemy.orm import DeclarativeBase
import sqlalchemy.orm as _orm

engine = _sql.create_engine("sqlite:///database.db", connect_args={"check_same_thread": False}, pool_pre_ping=True,pool_size=10,max_overflow=20,)
SessionLocal = _orm.sessionmaker(autocommit=False, bind=engine)




class Base(DeclarativeBase):
    pass


class X25519_Key(Base):
    __tablename__ = "x25519"

    id = _sql.Column(_sql.Integer, primary_key=True, index=True)

    pv_key = _sql.Column(_sql.LargeBinary, unique=True)
    pub_key = _sql.Column(_sql.LargeBinary, unique=True)

    x25519_created_at = _sql.Column(_sql.Integer, default=int(_dt.datetime.now().timestamp()))

    users = _orm.relationship("User", back_populates="key_x", cascade="all, delete-orphan")


class Ed25519_Key(Base):
    __tablename__ = "ed25519"

    id = _sql.Column(_sql.Integer, primary_key=True, index=True)

    pv_key_Ed25519 = _sql.Column(_sql.LargeBinary, unique=True, nullable=False)
    pub_key_Ed25519 = _sql.Column(_sql.LargeBinary, unique=True, nullable=False)

    ed25519_created_at = _sql.Column(_sql.Integer, default=int(_dt.datetime.now().timestamp()))

    users = _orm.relationship("User", back_populates="key_ed", cascade="all, delete-orphan")




class User(Base):
    __tablename__ = "users"

    id = _sql.Column(_sql.Integer, primary_key=True, index = True, unique=True)
    owner_id = _sql.Column( _sql.String, index=True )

    jwt = _sql.Column(_sql.String, unique=True, index = True)
    aesNonce = _sql.Column(_sql.String, unique=True, index = True)
    data_created = _sql.Column(_sql.Integer, default=int(_dt.datetime.now().timestamp()))
    exp = _sql.Column(_sql.Integer)
    image = _sql.Column(_sql.LargeBinary, nullable=True)
    clientPublicKeyBase64 = _sql.Column(_sql.String, nullable=True)
    sharedSecret_AES = _sql.Column(_sql.LargeBinary, nullable=True)

    x25519_key_id = _sql.Column(_sql.Integer,_sql.ForeignKey("x25519.id"))
    ed25519_key_id = _sql.Column(_sql.Integer,_sql.ForeignKey("ed25519.id"))

    key_ed = _orm.relationship("Ed25519_Key", back_populates="users")
    key_x = _orm.relationship("X25519_Key", back_populates="users")


# if __name__ == "__main__":


