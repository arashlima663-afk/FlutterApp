import sqlalchemy as _sql
import sqlalchemy.ext.declarative as _declarative
import sqlalchemy.orm as _orm
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
import aiosqlite
from datetime import datetime, timezone




engine = create_async_engine("sqlite+aiosqlite:///keys.db")
async_session = async_sessionmaker(bind=engine, expire_on_commit=False, autoflush=False)


# SessionLocal = _orm.sessionmaker(autocommit=False, autoflush=False, bind=engine)
# Base = _declarative.declarative_base()

