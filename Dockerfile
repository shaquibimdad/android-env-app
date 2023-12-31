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
    && yes | sdkmanager "build-tools;30.0.3" \
            "build-tools;33.0.0" \
            "build-tools;34.0.0" \
            "cmake;3.22.1" \
            "emulator" \
            "ndk;23.1.7779620" \
            "ndk;26.1.10909125" \
            "platform-tools" \
            "platforms;android-33" \
            "platforms;android-34" \
    && rm -rf ${ANDROID_HOME}/.android \
    && chmod 777 -R /opt/android

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
ENV PATH=${CMAKE_BIN_PATH}:${JAVA_HOME}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${PATH}
RUN pacman -Scc --noconfirm

ENV LANG=en_US.UTF-8
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
