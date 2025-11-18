FROM python:3.11-slim AS builder

# Build arguments for versioning
ARG BUILD_VERSION="1.0.0"
ARG BUILD_DATE
ARG COMMIT_SHA

WORKDIR /app

#####################################
# Install build dependencies        #
#####################################
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev curl \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .

###################################
# Install to virtual environment   #
###################################
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


######################################
# Final stage
######################################
FROM python:3.11-slim

# Labels for image metadata
LABEL maintainer="devops-team"
LABEL version="${BUILD_VERSION}"
LABEL build-date="${BUILD_DATE}"
LABEL commit-sha="${COMMIT_SHA}"
LABEL description="Next Hire Application"

WORKDIR /app

#####################################
# Runtime dependencies only         #
#####################################
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 curl netcat-openbsd \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

##################################
# Copy virtual environment       #
##################################
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application code
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /app
USER app

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health/ || exit 1

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "ai_next_hire.wsgi:application"]