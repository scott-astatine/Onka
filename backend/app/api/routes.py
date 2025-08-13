from fastapi import APIRouter, Depends, status
from app.db.reports import log_report, get_stats
from pydantic import BaseModel
from app.core.security import get_current_user_id

router = APIRouter()


class ReportRequest(BaseModel):
    # The reporter_id will be injected from the authenticated user dependency.
    reported_id: str


@router.get("/stats")
async def stats():
    return await get_stats()


@router.post("/report", status_code=status.HTTP_201_CREATED)
async def report(
    request: ReportRequest, reporter_id: str = Depends(get_current_user_id)
):
    # The reporter_id is now securely obtained from the dependency.
    await log_report(reporter_id, request.reported_id)
    return {"message": "Report logged"}
