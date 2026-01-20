
from sqlalchemy import ForeignKey, String, Integer
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy import ForeignKey, String, Integer
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


from sqlalchemy import LargeBinary,  ForeignKey, create_engine
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase,Mapped, mapped_column, Session, sessionmaker, relationship
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
import uuid
from datetime import datetime, timezone


class Base(DeclarativeBase):
    pass

class Keys(Base):
    __tablename__ = "init_keys"

    id: Mapped[int] = mapped_column(primary_key=True)
    pv_key: Mapped[bytes] = mapped_column(LargeBinary(33), nullable=False)
    pub_key: Mapped[bytes] = mapped_column(LargeBinary(33), nullable=False)

    profile: Mapped["Data"] = relationship(
        back_populates="user",
        uselist=False,
        cascade="all, delete-orphan",
    )

    def __repr__(self) -> str:
        return f"Keys(id={self.id})"


class Data(Base):
    __tablename__ = "incoming_data"

    id: Mapped[int] = mapped_column(primary_key=True)
    aes_key: Mapped[bytes] = mapped_column(LargeBinary, nullable=False)
    encoded_image: Mapped[bytes] = mapped_column(LargeBinary, nullable=False)

    user_id: Mapped[int] = mapped_column(
        ForeignKey("init_keys.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
    )

    user: Mapped["Keys"] = relationship(back_populates="profile")

    def __repr__(self) -> str:
        return f"Data(id={self.id}, user_id={self.user_id})"

