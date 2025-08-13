import asyncpg
import os
from datetime import datetime

DATABASE_URL = os.getenv(
    "DATABASE_URL", "postgresql://postgres:postgres@db:5432/onka"
)


async def get_db():
    return await asyncpg.connect(DATABASE_URL)


async def log_report(reporter_id: str, reported_id: str):
    conn = await get_db()
    try:
        await conn.execute(
            """
            INSERT INTO reports (reporter_id, reported_id, timestamp)
            VALUES ($1, $2, $3)
            """,
            reporter_id,
            reported_id,
            datetime.utcnow(),
        )
    finally:
        await conn.close()


async def get_stats():
    conn = await get_db()
    try:
        waiting = await conn.fetchval(
            "SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle' AND datname = 'onka'"
        )
        return {"users_online": waiting}
    finally:
        await conn.close()
