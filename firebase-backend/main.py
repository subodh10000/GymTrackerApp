from typing import Any, Dict
from datetime import datetime
import json

from firebase_functions import https_fn
from firebase_admin import credentials, firestore, initialize_app

# ---- Firebase Admin ----
try:
    cred = credentials.Certificate("serviceAccountKey.json")
    initialize_app(cred)
except FileNotFoundError:
    initialize_app()

# ---- Firestore Client ----
fs = firestore.client()

# ---- Helpers ----
def json_resp(payload: Any, status: int = 200) -> https_fn.Response:
    return https_fn.Response(
        json.dumps(payload),  # Serialize to JSON
        status=status,
        headers={"Content-Type": "application/json"}
    )

def parse_json_body(request: https_fn.Request) -> Dict[str, Any]:
    try:
        if request.data:
            return json.loads(request.data.decode("utf-8"))
        return {}
    except Exception:
        return {}

def require_user_id(request: https_fn.Request) -> str:
    return request.headers.get("x-user-id", "")

# ================= Endpoints =================

# POST /create_activity
@https_fn.on_request(region="us-central1")
def create_activity(request: https_fn.Request) -> https_fn.Response:
    uid = require_user_id(request)
    body = parse_json_body(request)
    ref = fs.collection("activities").document()
    ref.set({
        "userId": uid,
        "exerciseDetails": body.get("exercise_details", {}),
        "isPublic": body.get("is_public", True),
        "createdAt": firestore.SERVER_TIMESTAMP
    })
    return json_resp(ref.get().to_dict(), 201)

# GET /get_activity?id=<activityId>
@https_fn.on_request(region="us-central1")
def get_activity(request: https_fn.Request) -> https_fn.Response:
    activity_id = request.args.get("id")
    if not activity_id:
        return json_resp({"error": "Missing id"}, 400)
    snap = fs.collection("activities").document(activity_id).get()
    return json_resp(snap.to_dict())

# POST /follow
@https_fn.on_request(region="us-central1")
def follow(request: https_fn.Request) -> https_fn.Response:
    uid = require_user_id(request)
    body = parse_json_body(request)
    target = body.get("target_uid")
    if not target:
        return json_resp({"error": "Missing target_uid"}, 400)
    fs.collection("follows").document(uid).collection("following").document(target)\
      .set({"createdAt": firestore.SERVER_TIMESTAMP})
    return json_resp({"ok": True})

# DELETE /unfollow
@https_fn.on_request(region="us-central1")
def unfollow(request: https_fn.Request) -> https_fn.Response:
    uid = require_user_id(request)
    body = parse_json_body(request)
    target = body.get("target_uid")
    if not target:
        return json_resp({"error": "Missing target_uid"}, 400)
    fs.collection("follows").document(uid).collection("following").document(target).delete()
    return json_resp({"ok": True})

# GET /get_feed
@https_fn.on_request(region="us-central1")
def get_feed(request: https_fn.Request) -> https_fn.Response:
    uid = require_user_id(request)
    following_snaps = fs.collection("follows").document(uid).collection("following").limit(10).stream()
    following = [s.id for s in following_snaps]
    q = (fs.collection("activities")
         .where("userId", "in", following)
         .order_by("createdAt", direction=firestore.Query.DESCENDING)
         .limit(25))
    docs = list(q.stream())
    out = [d.to_dict() for d in docs]  # Return raw Firestore data
    return json_resp(out)

# GET /search_users?q=<query>
@https_fn.on_request(region="us-central1")
def search_users(request: https_fn.Request) -> https_fn.Response:
    query = request.args.get("q")
    if not query:
        return json_resp({"error": "Missing q"}, 400)
    q_lower = query.lower()
    q = (fs.collection("users")
         .where("searchName", ">=", q_lower)
         .where("searchName", "<=", q_lower + "\uf8ff")
         .limit(20))
    docs = list(q.stream())
    results = [d.to_dict() for d in docs]
    return json_resp(results)
