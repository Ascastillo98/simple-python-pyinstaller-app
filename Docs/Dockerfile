FROM jenkins/jenkins
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
https://download.docker.com/linux/debian \
$(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli

#Nota: El docker de Jenkins necesita tener instalado python para las fases
#de ejecución y tests. Se ha instalado tal y como se muestra en el repositorio
#del tutorial

# 1. Update the package list.
# 2. Install necessary dependencies including Python, python3-venv and several Python-related packages.
RUN apt-get update && apt-get install -y --no-install-recommends \
    binutils ca-certificates curl git python3 python3-venv python3-pip python3-setuptools python3-wheel python3-dev wget \
    && rm -rf /var/lib/apt/lists/*

# Create an alias for python3 as python.
RUN ln -s /usr/bin/python3 /usr/bin/python

# Create a Python virtual environment in /opt/venv.
RUN python3 -m venv /opt/venv

# Activate the virtual environment by adding its bin directory to the PATH.
# This ensures that the virtual environment is activated for all subsequent RUN commands in the Dockerfile.
ENV PATH="/opt/venv/bin:$PATH"

# Install required Python packages in the virtual environment.
RUN pip install docker-py feedparser nosexcover prometheus_client pycobertura pylint pytest pytest-cov requests setuptools sphinx pyinstaller

USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"

















