FROM golang:1.24.2-bookworm AS build

ENV CGO_ENABLED=0 GOTOOLCHAIN=local

# These commits are the releases previously consumed as public MinIO images:
# minio RELEASE.2025-09-07T16-13-09Z; mc RELEASE.2025-08-13T08-35-41Z.
RUN go install github.com/minio/minio@07c3a429bfed433e49018cb0f78a52145d4bedeb \
    && go install github.com/minio/mc@7394ce0dd2a80935aded936b09fa12cbb3cb8096
RUN mkdir /licenses \
    && cp /go/pkg/mod/github.com/minio/minio@v0.0.0-20250907161309-07c3a429bfed/LICENSE /licenses/minio-LICENSE \
    && cp /go/pkg/mod/github.com/minio/mc@v0.0.0-20250813083541-7394ce0dd2a8/LICENSE /licenses/mc-LICENSE

FROM alpine:3.22
RUN apk add --no-cache ca-certificates
COPY --from=build /go/bin/minio /go/bin/mc /usr/bin/
COPY --from=build /licenses /licenses
ENV MC_CONFIG_DIR=/tmp/.mc
ENTRYPOINT ["/usr/bin/minio"]
CMD ["server", "/data", "--console-address", ":9001"]
