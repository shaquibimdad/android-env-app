FROM archlinux

RUN pacman -Sy --needed --noconfirm base base-devel fish \
    git curl unzip zip ccache rsync tree neofetch \
    nano htop jq android-udev make

RUN mkdir -p ~/.config/fish
RUN echo 'set -U fish_greeting' >> ~/.config/fish/config.fish

RUN curl https://mise.run | sh
RUN echo '~/.local/bin/mise activate fish | source' >> ~/.config/fish/config.fish
ENV PATH=/root/.local/bin/:${PATH}

RUN mise use --global node@20
RUN mise use --global java@openjdk-17
RUN mise use --global python@3.12

ENV PATH=/root/.local/share/mise/installs/node/20/bin:${PATH}

RUN npm install -g yarn

ARG CLI_TOOL_VERSION=commandlinetools-linux-11076708_latest.zip
ARG ANDROID_BUILD_VERSION=34
ARG ANDROID_TOOLS_VERSION=34.0.0
ARG NDK_VERSION=26.1.10909125
ARG CMAKE_VERSION=3.22.1

ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/$NDK_VERSION
ENV CMAKE_BIN_PATH=${ANDROID_HOME}/cmake/$CMAKE_VERSION/bin
ENV JAVA_HOME=root/.local/share/mise/installs/java/openjdk-17

ENV PATH=${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}

RUN curl -sS https://dl.google.com/android/repository/${CLI_TOOL_VERSION} -o /tmp/cli_tool.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/cli_tool.zip \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cli_tool.zip \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager "build-tools;34.0.0" \
            "build-tools;35.0.0" \
            "cmake;3.22.1" \
            "ndk;26.1.10909125" \
            "platform-tools" \
            "platforms;android-31" \
            "platforms;android-32" \
            "platforms;android-33" \
            "platforms;android-34" \
            "platforms;android-35" \
    && rm -rf ${ANDROID_HOME}/.android \
    && chmod 777 -R /opt/android

ENV PATH=${CMAKE_BIN_PATH}:${JAVA_HOME}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${PATH}

ENV LANG=en_US.UTF-8

RUN curl -sS https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz -o /tmp/google-cloud-cli.tar.gz \
    && tar -xzf /tmp/google-cloud-cli.tar.gz -C /opt \
    && /opt/google-cloud-sdk/install.sh --quiet \
    && rm /tmp/google-cloud-cli.tar.gz

ENV PATH=/opt/google-cloud-sdk/bin:${PATH}

RUN pacman -Scc --noconfirm