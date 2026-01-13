from db import engine, Keys, Base

import asyncio


async def create_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    await engine.dispose()



asyncio.run(create_db())