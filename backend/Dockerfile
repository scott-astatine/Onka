# Use a specific, recent patch version for reproducibility and security
FROM python:3.10.13-slim

# Set environment variables for best practices in containers
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV PORT 8080

WORKDIR /app

# Create a non-root user and group for security
RUN addgroup --system nonroot && adduser --system --ingroup nonroot nonroot

# Copy and install dependencies first to leverage Docker layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the application code and set permissions
COPY --chown=nonroot:nonroot ./app /app/app

# Switch to the non-root user
USER nonroot

# Expose the port. This is good practice but not strictly required by Cloud Run.
EXPOSE 8080

# Use Gunicorn for production. It will listen on the PORT env var (8080).
# The number of workers can be tuned. A good starting point is 2-4 for a 1 vCPU instance.
CMD ["gunicorn", "-w", "2", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8080", "app.main:app"]