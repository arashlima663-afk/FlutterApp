from sqlalchemy import LargeBinary
from sqlalchemy.orm import DeclarativeBase,Mapped, mapped_column, Session, sessionmaker
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

from datetime import datetime, timezone


engine = create_async_engine(
    "sqlite+aiosqlite:///keys.db")

class Base(DeclarativeBase):
    pass

class Keys(Base):
    __tablename__ = "ephemeral_keys"
    id: Mapped[int] = mapped_column(primary_key=True)
    pv_key: Mapped[bytes] = mapped_column(LargeBinary(33))
    pub_key: Mapped[bytes] = mapped_column(LargeBinary(33))
    date_created: Mapped[datetime] = mapped_column(default=lambda: datetime.now(timezone.utc))
    

    def __repr__(self) -> str:
        return f"Key (id={self.id}, created={self.date_created})"

