# MinIO for demo development and tests

The local Compose services build MinIO and `mc` from pinned upstream source
because their former public images and binary downloads are unavailable.
The commits correspond to the same releases previously used here:

- [MinIO RELEASE.2025-09-07T16-13-09Z](https://github.com/minio/minio/tree/07c3a429bfed433e49018cb0f78a52145d4bedeb)
- [mc RELEASE.2025-08-13T08-35-41Z](https://github.com/minio/mc/tree/7394ce0dd2a80935aded936b09fa12cbb3cb8096)

`docker compose -f docker/docker-compose-local.yml up` builds one local image
containing both programs. The server, bucket setup, and fixture copy services
reuse it. No private registry login or published replacement image is needed.
The first build compiles Go dependencies and takes longer than pulling an image;
subsequent builds use Docker's build cache. Upstream licenses are included in
`/licenses` in the image. This setup is for the existing development/test services;
the deployed Rails and renderer images are unaffected.
