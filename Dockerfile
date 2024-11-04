ARG BASE_IMAGE=ubuntu:23.04

FROM ${BASE_IMAGE} as build
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential \
    zlib1g-dev \
    libexpat1-dev \
    libjpeg-dev \
    wget \
    unzip \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app-dng
ARG BRANCH=main
ARG REPO_URL=https://github.com/ai2ys/go-dng.git
RUN git clone ${REPO_URL} -b ${BRANCH} --single-branch
WORKDIR /app-dng/go-dng/sdk
RUN make

FROM ${BASE_IMAGE} as runtime
RUN apt-get update && apt-get install -y \
    libjpeg8 \
    libexpat1 \
    # check if required
    zlib1g \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /app-dng/go-dng/sdk/bin/dng_validate /usr/local/bin/

WORKDIR /images
ENTRYPOINT ["/usr/local/bin/dng_validate"]