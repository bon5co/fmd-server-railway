# FMD Server for Railway.
#
# FMD Server (gitlab.com/fmd-foss/fmd-server, GPL-3.0) is the server half of FMD ("Find My Device", the open-source
# phone-locating app): it stores the location points, pictures and remote commands that the phone and the web client
# exchange as opaque ciphertext. This wrapper keeps the upstream Alpine image and binary unchanged and adds what a
# public Railway deploy driven by an agent needs.
#
# 1. Registration is open upstream (an empty RegistrationToken lets anyone who finds the domain create accounts and
#    store data). railway-entrypoint.sh always sets FMD_REGISTRATIONTOKEN and refuses to start without one.
# 2. The server listens on 8080 from its own config and ignores Railway's injected PORT; the entrypoint binds PORT.
# 3. Railway mounts the volume root-owned, and the server runs as uid 1000 (fmd-server) with a 0770 database
#    directory, so it cannot write to a fresh volume. The entrypoint chowns the mount as root, then drops privileges.
#
# upstream: none gitlab.com/fmd-foss/fmd-server is hosted on GitLab, not GitHub; newest release v0.17.1 (2026-10-30), checked by hand on 2026-11-13
FROM registry.gitlab.com/fmd-foss/fmd-server:0.17.1-alpine@sha256:9ba9fb9a04075d5404b858eae5d3d9659ffb1ca99308da3fc33244ece04c16c4

USER root
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN apk add --no-cache su-exec && chmod +x /usr/local/bin/railway-entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
