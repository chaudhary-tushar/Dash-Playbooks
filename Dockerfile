FROM ghcr.io/cirruslabs/flutter:latest

# Install development dependencies for all build targets
RUN apt-get update && apt-get install -y \
    clang \
    cmake \
    ninja-build \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-10-dev \
    git \
    curl \
    wget \
    unzip \
    xz-utils \
    zip \
    openjdk-11-jdk \
    android-sdk \
    build-essential \
    pkg-config \
    libssl-dev \
    python3 \
    python3-pip \
    vim \
    nano \
    python3-pytest \
    && rm -rf /var/lib/apt/lists/*

# Set Flutter environment variables
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV ANDROID_SDK_ROOT=$ANDROID_HOME
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Agree to Android licenses
RUN yes | flutter doctor --android-licenses 2>/dev/null || true

WORKDIR /workspace

# Pre-pull Flutter dependencies
RUN flutter config --enable-web && \
    flutter config --enable-linux-desktop && \
    flutter pub global activate build_runner

# Expose ports for development servers
EXPOSE 3000 8000 8080 9090

# Set entrypoint for development
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
