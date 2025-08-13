from fastapi import FastAPI, WebSocket, WebSocketDisconnect, APIRouter
import logging
from fastapi.middleware.cors import CORSMiddleware
from app.core.connection_manager import ConnectionManager
from app.api.routes import router as api_router

app = FastAPI(title="onka Backend")

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

manager = ConnectionManager()


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
