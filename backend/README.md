# onka Backend (FastAPI)

This directory contains the backend for onka, a modern Omegle-like video chat application. The backend is built with FastAPI and provides REST APIs, WebSocket signaling, and PostgreSQL integration.

## Features

- **WebSocket Signaling:** Pairs users and relays WebRTC signaling messages.
- **REST API:**
  - `/api/stats`: Get number of online/waiting users.
  - `/api/report`: Report a user (logs to database).
- **Connection Management:** Handles user pool, pairing, and disconnections.
- **PostgreSQL Logging:** Stores reports of inappropriate users.
- **Dockerized:** Easy deployment with Docker and docker-compose.

## Directory Structure

```
backend/
├── app/
│   ├── main.py                # FastAPI entry point
│   ├── core/
│   │   └── connection_manager.py  # WebSocket connection/pairing logic
│   ├── api/
│   │   └── routes.py          # REST API endpoints
│   └── db/
│       ├── reports.py         # Database access for reports/stats
│       └── init.sql           # DB schema
├── requirements.txt           # Python dependencies
├── Dockerfile                 # Docker build for backend
├── docker-compose.yml         # Multi-service setup (backend + PostgreSQL)
```

## Key Technologies

- **Python 3.10+**
- **FastAPI**: High-performance async web framework
- **asyncpg**: Async PostgreSQL driver
- **PostgreSQL**: Database for reports
- **Docker**: Containerization

## Setup Instructions

1. **Install Docker & Docker Compose**
2. **Build and run services:**
   ```
   docker-compose up --build
   ```
3. **Database:**
   - The database is automatically initialized with `init.sql`.
   - Reports are stored in the `reports` table.
4. **API Endpoints:**
   - WebSocket: `/ws/{client_id}`
   - REST: `/api/stats`, `/api/report`
5. **WebRTC Signaling:**
   - The backend only relays signaling data; it does not interpret SDP/ICE.
   - Pairing logic is in `connection_manager.py`.
6. **STUN/TURN:**
   - For real-world use, configure your own TURN server and update the frontend's WebRTC config.

## Project Philosophy

- **Performance:** Async, non-blocking, scalable.
- **Security:** Minimal data, sanitized inputs, robust error handling.
- **Simplicity:** Easy to deploy, maintain, and extend.

## Contact

For issues or contributions, see the main project repository.
