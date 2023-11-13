FROM archlinux

RUN pacman -Sy --needed --noconfirm base base-devel fish \
    jdk17-openjdk jdk11-openjdk git curl unzip \
    nodejs-lts-hydrogen yarn nano

RUN archlinux-java set java-17-openjdk
ARG CLI_TOOL_VERSION=commandlinetools-linux-10406996_latest.zip
ARG ANDROID_BUILD_VERSION=34
ARG ANDROID_TOOLS_VERSION=34.0.0
ARG NDK_VERSION=26.1.10909125
ARG CMAKE_VERSION=3.22.1

ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/$NDK_VERSION
ENV CMAKE_BIN_PATH=${ANDROID_HOME}/cmake/$CMAKE_VERSION/bin

ENV PATH=${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}

RUN curl -sS https://dl.google.com/android/repository/${CLI_TOOL_VERSION} -o /tmp/cli_tool.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/cli_tool.zip \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cli_tool.zip \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager "platform-tools" \
        "platforms;android-$ANDROID_BUILD_VERSION" \
        "build-tools;$ANDROID_TOOLS_VERSION" \
        "cmake;$CMAKE_VERSION" \
        "ndk;$NDK_VERSION" \
    && rm -rf ${ANDROID_HOME}/.android \
    && chmod 777 -R /opt/android

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
ENV PATH=${CMAKE_BIN_PATH}:${JAVA_HOME}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${PATH}
RUN pacman -Scc --noconfirm

ENV LANG=en_US.UTF-8
RUN echo "set fish_greeting" > /etc/fish/config.fish
CMD ["fish"]
