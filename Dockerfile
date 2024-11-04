ARG VERSION_DNG_SDK=1.7.1
ARG BASE_IMAGE=ubuntu:23.04

FROM ${BASE_IMAGE} as build
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential \
    zlib1g-dev \
    libexpat1-dev \
    libjpeg-dev \
    libjxl-dev \
    wget \
    unzip \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app-dng
ARG BRANCH=main
ARG REPO_URL=https://github.com/ai2ys/go-dng.git
#RUN git clone ${REPO_URL} -b ${BRANCH} --single-branch
WORKDIR /app-dng/go-dng/sdk
COPY build /app-dng/go-dng/build
COPY sdk /app-dng/go-dng/sdk
ARG VERSION_DNG_SDK
ENV VERSION_DNG_SDK_=${VERSION_DNG_SDK//./_}
RUN make

FROM ${BASE_IMAGE} as runtime
RUN apt-get update && apt-get install -y \
    libjpeg8 \
    libexpat1 \
    libjxl-tools \
    # check if required
    zlib1g \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /app-dng/go-dng/sdk/bin/dng_validate /usr/local/bin/

WORKDIR /images
ENTRYPOINT ["/usr/local/bin/dng_validate"]