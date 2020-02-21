FROM adoptopenjdk:8-hotspot-bionic

RUN apt-get update && apt-get upgrade -y && apt-get install -y git python3 wget build-essential zip unzip && rm -rf /var/lib/apt/lists/*

# Clone bazel source
ARG BAZEL_VERSION=2.1.0
ENV BAZEL_VERSION=$BAZEL_VERSION
RUN wget --no-check-certificate --no-cookies https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-dist.zip \
    && wget --no-check-certificate --no-cookies https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-dist.zip.sha256 \
    && echo "$(cat bazel-${BAZEL_VERSION}-dist.zip.sha256)" | sha256sum -c \
    && mkdir -p bazel-src \
    && unzip bazel-${BAZEL_VERSION}-dist.zip -d bazel-src \
    && rm -f bazel-${BAZEL_VERSION}-dist.zip \
    && rm -f bazel-${BAZEL_VERSION}-dist.zip.sha256

COPY patch_for_s390x.diff /bazel-src/
WORKDIR bazel-src
RUN git apply patch_for_s390x.diff && rm -f patch_for_s390x.diff

RUN env BAZEL_JAVAC_OPTS="-J-Xms1024m -J-Xmx2048m" EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh