from fastapi import WebSocket
from typing import Dict, Optional, Set
import logging
import asyncio


class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, WebSocket] = {}
        self.waiting_users: Set[str] = set()
        self.paired_users: Dict[str, str] = {}
        self.lock = asyncio.Lock()
        self.logger = logging.getLogger(__name__)

    async def connect(self, websocket: WebSocket, client_id: str):
        await websocket.accept()
        async with self.lock:
            self.active_connections[client_id] = websocket
            self.waiting_users.add(client_id)
            await self.pair_users()
        self.logger.info(f"Client {client_id} is now waiting for a pair.")

    async def disconnect(self, client_id: str):
        async with self.lock:
            self.active_connections.pop(client_id, None)
            self.waiting_users.discard(client_id)
            peer_id = self.paired_users.pop(client_id, None)
            if peer_id:
                self.paired_users.pop(peer_id, None)
                peer_ws = self.active_connections.get(peer_id)
                if peer_ws:
                    self.logger.info(f"Notifying peer {peer_id} of disconnection.")
                    await peer_ws.send_json({"type": "peer_left"})
                    self.waiting_users.add(peer_id)
                    await self.pair_users()

    async def pair_users(self):
        while len(self.waiting_users) >= 2:
            user1, user2 = list(self.waiting_users)[:2]
            self.waiting_users.discard(user1)
            self.waiting_users.discard(user2)
            self.paired_users[user1] = user2
            self.paired_users[user2] = user1
            ws1 = self.active_connections[user1]
            ws2 = self.active_connections[user2]
            await ws1.send_json({"type": "peer_found", "peer_id": user2})
            await ws2.send_json({"type": "peer_found", "peer_id": user1})
            self.logger.info(f"Paired users: {user1} and {user2}")

    async def handle_message(self, sender_id: str, data: dict):
        message_type = data.get("type")

        if message_type == "next":
            async with self.lock:
                peer_id = self.paired_users.get(sender_id)
                if peer_id:
                    self.logger.info(f"User {sender_id} requested 'next'. Breaking pair with {peer_id}.")
                    # Notify both users the chat has ended
                    for user_id in [sender_id, peer_id]:
                        ws = self.active_connections.get(user_id)
                        if ws:
                            await ws.send_json({"type": "chat_ended"})
                    # Unpair them and put them back in the waiting pool
                    self.paired_users.pop(sender_id, None)
                    self.paired_users.pop(peer_id, None)
                    self.waiting_users.add(sender_id)
                    self.waiting_users.add(peer_id)
                    await self.pair_users()
            return

        # For all other messages (offer, answer, ice-candidate), forward them to the peer
        async with self.lock:
            peer_id = self.paired_users.get(sender_id)
            if peer_id and (peer_ws := self.active_connections.get(peer_id)):
                await peer_ws.send_json(data)
