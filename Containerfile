FROM ghcr.io/ublue-os/config:latest@sha256:687cf5efabd2b61a688288a34e2d57c18d4cad066359919a98b47fd568a524de AS config
FROM ghcr.io/centos-workstation/main:${MAJOR_VERSION:-latest}

ARG IMAGE_NAME="${IMAGE_NAME:-achillobator}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-centos-workstation}"
ARG MAJOR_VERSION="${MAJOR_VERSION:-latest}"
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT:-}"

COPY system_files /
COPY build_scripts /var/tmp/build_scripts

RUN --mount=type=tmpfs,dst=/tmp --mount=type=bind,from=config,src=/rpms,dst=/tmp/rpms /var/tmp/build_scripts/build.sh
