# FMD Server

Railway template for [FMD Server](https://gitlab.com/fmd-foss/fmd-server) (GPL-3.0), the server for the FMD "Find My Device" Android app. It stores client-side-encrypted locations, pictures and commands.

- Wrapper image: `ghcr.io/bon5co/fmd-server-railway:0.17.1` (source in this folder and in bon5co/fmd-server-railway), on the upstream Alpine image `registry.gitlab.com/fmd-foss/fmd-server:0.17.1-alpine` pinned by digest.
- Port: the entrypoint sets `FMD_PORTINSECURE` to `$PORT` (Railway injects 8080) and turns the server's own TLS listener off. Health: `/version`.
- Volume: mount `/var/lib/fmd-server/db` (SQLite). Railway mounts it root-owned and the server runs as uid 1000, so the entrypoint chowns the mount to `1000:65533` as root and starts the server through `su-exec`. It logs the owner before and after.
- Variables: `FMD_REGISTRATIONTOKEN` (generated, 32; the entrypoint refuses to start without at least 16 characters, because upstream treats an empty token as open registration). Optional: `FMD_LOGLEVEL`.
- There is no administrator account: users register from the app or the web client with the token.
- Build the spec: `uv run --no-project fmd-server/make-spec.py sha256:<wrapper digest>`.
