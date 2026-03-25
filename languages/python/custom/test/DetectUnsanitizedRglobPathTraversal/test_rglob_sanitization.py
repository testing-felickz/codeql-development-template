import os
import pathlib

from flask import Flask, request

app = Flask(__name__)

JOBS_ROOT = pathlib.Path("/data/jobs")


@app.route("/unsanitized")
def unsanitized_rglob():
    """Detected: no sanitization at all."""
    job_id = request.args.get("job_id", "")
    job_dir = JOBS_ROOT / job_id
    matches = list(job_dir.rglob("summary.csv"))  # Alert: unsanitized path
    return str(matches)


@app.route("/sanitized_resolve_and_is_relative_to")
def sanitized_rglob():
    """resolve() + is_relative_to() properly sanitizes the rglob call."""
    job_id = request.args.get("job_id", "")
    job_dir = JOBS_ROOT / job_id
    resolved = job_dir.resolve()  # Alert on resolve() itself (it is a FileSystemAccess in stdlib)
    if not resolved.is_relative_to(JOBS_ROOT):
        raise ValueError("path escapes root")
    # NOT detected: resolve() normalized the path, is_relative_to() confirmed confinement
    matches = list(resolved.rglob("summary.csv"))
    return str(matches)


@app.route("/resolve_only")
def resolve_only_rglob():
    """Detected: resolve() without is_relative_to() is insufficient."""
    job_id = request.args.get("job_id", "")
    job_dir = JOBS_ROOT / job_id
    resolved = job_dir.resolve()  # Alert on resolve() itself (FileSystemAccess)
    matches = list(resolved.rglob("summary.csv"))  # Alert: normalized but not checked
    return str(matches)


@app.route("/is_relative_to_without_resolve")
def is_relative_to_without_resolve():
    """Detected: is_relative_to() without resolve() first is bypassable."""
    job_id = request.args.get("job_id", "")
    job_dir = JOBS_ROOT / job_id
    if not job_dir.is_relative_to(JOBS_ROOT):
        raise ValueError("path escapes root")
    matches = list(job_dir.rglob("summary.csv"))  # Alert: checked but not normalized
    return str(matches)


@app.route("/sanitized_open")
def sanitized_open():
    """resolve() + is_relative_to() properly sanitizes the open() call."""
    job_id = request.args.get("job_id", "")
    job_dir = JOBS_ROOT / job_id
    resolved = job_dir.resolve()  # Alert on resolve() itself (FileSystemAccess)
    if not resolved.is_relative_to(JOBS_ROOT):
        raise ValueError("path escapes root")
    # NOT detected: properly sanitized
    f = resolved.open()
    return f.read()


@app.route("/unsanitized_open")
def unsanitized_open():
    """Detected: unsanitized open()."""
    job_id = request.args.get("job_id", "")
    job_dir = JOBS_ROOT / job_id
    f = job_dir.open()  # Alert: unsanitized path
    return f.read()


@app.route("/realpath_startswith")
def realpath_startswith():
    """Not detected: os.path.realpath + startswith (existing sanitizer)."""
    job_id = request.args.get("job_id", "")
    path = os.path.join("/data/jobs", job_id)
    npath = os.path.realpath(path)
    if npath.startswith("/data/jobs"):
        f = open(npath)  # Not detected: properly sanitized by existing sanitizer
        return f.read()
    return "error"
