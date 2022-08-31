FROM codercom/enterprise-java:ubuntu

# Run everything as root
USER root

# Packages required for multi-editor support
RUN DEBIAN_FRONTEND="noninteractive" apt-get update -y --no-install-recommends && \
    apt-get install -y \
    libxtst6 \
    libxrender1 \
    libfontconfig1 \
    libxi6 \
    libgtk-3-0

# Install intellij
RUN mkdir -p /opt/idea
RUN curl -L "https://download-cdn.jetbrains.com/idea/ideaIC-2022.2.1.tar.gz" | tar -C /opt/idea --strip-components 1 -xzvf -

# Add a binary to the PATH that points to the intellij startup script.
RUN ln -s /opt/idea/bin/idea.sh /usr/bin/intellij-idea-community

# Install projector: download and extract to IDE's lib folder
RUN curl -L "https://github.com/JetBrains/projector-server/releases/download/v1.8.1/projector-server-v1.8.1.zip" -o /tmp/projector-server-1.8.1.zip && \
    unzip /tmp/projector-server-1.8.1.zip -d /opt/idea/lib/ && \
    rm -f /tmp/projector-server-1.8.1.zip

# Add Coder-specific scripts and metadata to the image
COPY ["./coder", "/coder"]

# Copy and munge Idea startup script
RUN cp /opt/idea/bin/idea.sh /opt/idea/bin/idea-projector.sh && \
    chmod +x /opt/idea/bin/idea-projector.sh
RUN sed -i 's|\(-classpath "$CLASS_\?PATH\)|\1:/opt/idea/lib/projector-server-1.8.1/lib/*|g' /opt/idea/bin/idea-projector.sh
RUN sed -i 's|com.intellij.idea.Main|-Dorg.jetbrains.projector.server.port=8888 -Dorg.jetbrains.projector.server.classToLaunch=com.intellij.idea.Main org.jetbrains.projector.server.ProjectorLauncher|g' /opt/idea/bin/idea-projector.sh

# Set back to coder user
USER coder

EXPOSE 8082