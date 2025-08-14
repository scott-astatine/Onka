import asyncpg
import os

DATABASE_URL = os.getenv(
    "DATABASE_URL", "postgresql://postgres:postgres@db:5432/onka"
)


async def get_db():
    return await asyncpg.connect(DATABASE_URL)


async def log_report(reporter_id: str, reported_id: str):
    conn = await get_db()
    try:
        await conn.execute(
            # The TIMESTAMP column has a default of NOW(), so we don't need to provide it.
            """
            INSERT INTO reports (reporter_id, reported_id)
            VALUES ($1, $2)
            """,
            reporter_id,
            reported_id,
        )
    finally:
        await conn.close()
