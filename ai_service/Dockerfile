FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    # tắt check version của albumentations (tránh gọi mạng)
    ALBU_DISABLE_VERSION_CHECK=1 \
    # nơi insightface sẽ tìm models
    INSIGHTFACE_HOME=/root/.insightface

# System deps for OpenCV + unzip
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential g++ gcc make wget unzip \
    libgl1 libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy code
COPY app ./app

# Copy và giải nén model vào ${INSIGHTFACE_HOME}/models/buffalo_l
COPY models/buffalo_l.zip /tmp/buffalo_l.zip
RUN mkdir -p ${INSIGHTFACE_HOME}/models && \
    unzip -o /tmp/buffalo_l.zip -d ${INSIGHTFACE_HOME}/models && \
    rm /tmp/buffalo_l.zip

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
