import asyncio
import aiosqlite

class Database:
    async def Connect():
        db = await aiosqlite.connect("database.db")
        await db.execute("""
            CREATE TABLE IF NOT EXISTS database (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                pub_key TEXT,
                pv_key TEXT,
                aes TEXT,
                enc_photo TEXT
            )
        """)
        await db.commit()
        return db

    async def Insert(db, pub_key, pv_key):

        # columns = ", ".join(values.keys())
        # placeholders = ", ".join("?" for _ in values)
        sql = f"INSERT INTO database (pub_key, pv_key) VALUES (?, ?)"

        await db.execute(sql, (pub_key, pv_key))
        await db.commit()

    async def Read(db, **values):
        c = db.cursor()

        columns = ", ".join(values.keys())
        await c.execute(f"SELECT {columns} FROM database")
        records = await c.fetchall()
        for i in records:
            print(i)

        await db.close()