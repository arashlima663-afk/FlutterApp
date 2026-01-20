# from db import Keys, Base
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import MetaData, Table, Column, Integer, LargeBinary, select
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
import asyncio, uuid,  aiosqlite
from sqlalchemy import create_engine
from db import Base, Keys, Data


async def async_main() -> None:
    engine = create_async_engine("sqlite+aiosqlite:///keys.db")

    session = async_sessionmaker(bind = engine, expire_on_commit=False)

    async with engine.begin() as conn:
    #     await conn.run_sync(Base.metadata.create_all)
    # await engine.dispose()
        await insert_data(session)



# insert data
async def insert_data(sessionmaker: async_sessionmaker[AsyncSession]):
    async with sessionmaker() as session:
        async with session.begin():  # starts a transaction
            # create the Keys object
            keys = Keys(
                pv_key=b"private_key_bytes_here",
                pub_key=b"public_key_bytes_here",
            )
            session.add(keys)
            await session.flush()  # ensures keys.id is generated

            # create the Data object, referencing keys.id
            data = Data(
                aes_key=b"aes_key_bytes_here",
                encoded_image=b"image_bytes_here",
                user_id=keys.id  # now we have the ID
            )
            session.add(data)




if __name__ == "__main__":
    asyncio.run(async_main())

# async def create_db():
#     async with engine.begin() as conn:
#         await conn.run_sync(Base.metadata.create_all)
#     await engine.dispose()



# asyncio.run(create_db())