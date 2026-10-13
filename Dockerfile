FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM node:22-alpine AS frontend

WORKDIR /frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
# Match frontend/Makefile's production rewrite for API and lazy asset URLs.
RUN npm run build \
    && sed -i 's/assets/fs\/public\/assets/g;s/http:\/\/0.0.0.0:8840//g' dist/assets/index.js \
    && ! grep -q 'http://0.0.0.0:8840' dist/assets/index.js

FROM --platform=$BUILDPLATFORM golang:1.25.1-alpine AS builder

COPY --from=xx / /

WORKDIR /src

COPY backend/go.mod backend/go.sum ./
RUN go mod download

COPY backend/ .
COPY --from=frontend /frontend/dist/assets/ ./internal/web/public/assets/

ARG TARGETPLATFORM
RUN CGO_ENABLED=0 xx-go build -ldflags='-w -s' -o /WatchYourLAN ./cmd/WatchYourLAN


# Preserve the upstream 2.1.4 runtime and its ARP scanner dependencies.
FROM aceberg/watchyourlan:2.1.4@sha256:f77532ca7c3c9a4398cb094df7674013a3d7fcf4699386f1e456c24df6fef00e

WORKDIR /app

COPY --from=builder /WatchYourLAN /app/

ENTRYPOINT ["./WatchYourLAN"]
