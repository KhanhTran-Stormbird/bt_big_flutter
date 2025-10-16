import io
import os
from typing import List, Optional

import numpy as np
import cv2
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="Face API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

FACE_MODEL_NAME = os.getenv("FACE_MODEL_NAME", "buffalo_l")
DET_SIZE = int(os.getenv("FACE_DET_SIZE", "320"))
PROVIDERS = os.getenv("FACE_PROVIDERS", "CPUExecutionProvider").split(",")

face_app = None


def _init_insightface():
    global face_app
    from insightface.app import FaceAnalysis

    face_app = FaceAnalysis(name=FACE_MODEL_NAME, providers=PROVIDERS)
    # det_size can be a tuple (w,h) or int
    face_app.prepare(ctx_id=0, det_size=(DET_SIZE, DET_SIZE))


@app.on_event("startup")
def on_startup():
    _init_insightface()


@app.get("/health")
def health():
    return {"status": "ok", "model": FACE_MODEL_NAME}


def _read_image(file: UploadFile) -> np.ndarray:
    data = file.file.read()
    if not data:
        raise HTTPException(status_code=400, detail="empty image")
    img_array = np.frombuffer(data, dtype=np.uint8)
    img = cv2.imdecode(img_array, cv2.IMREAD_COLOR)
    if img is None:
        raise HTTPException(status_code=400, detail="invalid image format")
    return img


def _largest_face(faces) -> Optional[object]:
    if not faces:
        return None
    # choose face with largest bbox area
    def area(face):
        box = getattr(face, "bbox", None)
        if box is None:
            return 0
        x1, y1, x2, y2 = box
        return max(0, x2 - x1) * max(0, y2 - y1)

    return max(faces, key=area)


class MatchBody(BaseModel):
    source: List[float]
    target: List[float]


@app.post("/extract")
def extract(image: UploadFile = File(...)):
    img = _read_image(image)
    faces = face_app.get(img)
    best = _largest_face(faces)
    if best is None:
        raise HTTPException(status_code=422, detail="no face detected")

    # Some insightface versions expose normed_embedding or embedding
    emb = getattr(best, "normed_embedding", None)
    if emb is None:
        emb = getattr(best, "embedding", None)
    if emb is None:
        raise HTTPException(status_code=500, detail="embedding not available")

    # Convert to python list
    if hasattr(emb, "tolist"):
        emb = emb.tolist()
    else:
        emb = list(emb)

    return {"embedding": emb}


@app.post("/match")
def match(body: MatchBody):
    a = np.asarray(body.source, dtype=np.float32)
    b = np.asarray(body.target, dtype=np.float32)
    if a.size == 0 or b.size == 0:
        raise HTTPException(status_code=400, detail="empty embedding")

    # If embeddings are L2-normalized, cosine distance is 1 - dot(a,b)
    # Fallback to normalized vectors to be safe
    def _normalize(x):
        n = np.linalg.norm(x) + 1e-12
        return x / n

    a_n = _normalize(a)
    b_n = _normalize(b)
    cos_sim = float(np.dot(a_n, b_n))
    distance = float(1.0 - cos_sim)
    return {"distance": distance}

