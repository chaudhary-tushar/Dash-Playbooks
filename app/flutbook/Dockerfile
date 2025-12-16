FROM ghcr.io/cirruslabs/flutter:latest

# Install development dependencies for all build targets
RUN apt-get update && apt-get install -y \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-12-dev \
    mesa-utils \
    git \
    curl \
    wget \
    unzip \
    xz-utils \
    zip \
    openjdk-11-jdk \
    build-essential \
    libssl-dev \
    python3 \
    python3-pip \
    python3-pytest \
    && rm -rf /var/lib/apt/lists/*


# Set Flutter environment variables
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV ANDROID_SDK_ROOT=$ANDROID_HOME
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Agree to Android licenses
RUN yes | flutter doctor --android-licenses 2>/dev/null || true

USER root
RUN chown -R ubuntu:ubuntu /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

# Fix ownership if needed
RUN sudo chown -R ubuntu:ubuntu /sdks/flutter || true && \
    sudo chown -R ubuntu:ubuntu /opt/flutter || true

# Allow Git operations on flutter SDK paths
RUN git config --global --add safe.directory /opt/flutter && \
    git config --global --add safe.directory /sdks/flutter && \
    git config --global --add safe.directory /sdks/flutter/.git

# Pre-pull Flutter dependencies
RUN flutter config --enable-web && \
    flutter config --enable-linux-desktop && \
    flutter pub global activate build_runner && \
    dart pub global activate very_good_cli

# Expose ports for development servers
EXPOSE 3000 8000 8080 9090

# Set entrypoint for development
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
