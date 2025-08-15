import os
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, APIRouter
import logging
from fastapi.middleware.cors import CORSMiddleware
from app.core.connection_manager import ConnectionManager
from app.api.routes import router as api_router
from app.core.auth import create_access_token


app = FastAPI(title="onka Backend")

manager = ConnectionManager()

origins = ["*"]

app.include_router(api_router, prefix="/api")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/stats")
async def stats():
    """Returns the current number of online users."""
    # print(os.getenv("DATABASE_URL"), os.getenv("PORT"))
    return manager.get_stats()


@app.post("/token")
async def login_for_access_token(client_id: str):
    """
    Generates a JWT for a given client_id.
    In a real app, you'd have username/password here.
    """
    access_token = create_access_token(data={"sub": client_id})
    return {"access_token": access_token, "token_type": "bearer"}


@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str):
    await manager.connect(websocket, client_id)
    logger.info(f"Client connected: {client_id}")
    try:
        while True:
            data = await websocket.receive_json()
            await manager.handle_message(client_id, data)
    except WebSocketDisconnect:
        logger.info(f"Client disconnected: {client_id}")
        await manager.disconnect(client_id)
    except Exception as e:
        logger.error(f"Error for client {client_id}: {e}", exc_info=True)
        await manager.disconnect(client_id)
