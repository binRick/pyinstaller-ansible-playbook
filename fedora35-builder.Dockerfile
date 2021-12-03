FROM fedora:35 as fedora35-builder
ARG LINODE_TOKEN=$LINODE_TOKEN
ARG ANSIBLE_VERSION=$ANSIBLE_VERSION
ENV ANSIBLE_VERSION=4.9.0
RUN echo ANSIBLE_VERSION=$ANSIBLE_VERSION LINODE_TOKEN=$LINODE_TOKEN
RUN dnf -y install binutils python3 python3-setuptools rsync findutils python3-wheel pv python3-pip python3-devel
RUN dnf -y install bat less patchelf glibc glibc-devel glibc-static glibc-utils
RUN python3 -m venv /root/.ansible-build-venv
RUN bash -c 'source /root/.ansible-build-venv/bin/activate && pip install -q -U pip && pip install six pyinstaller staticx -q'

WORKDIR /compile
COPY bin/passh ansi bin/staticx /compile/

RUN python3 -m pip install staticx
#COPY bin/passh ansi *.py *.spec *.sh /compile/
#RUN passh /compile/Build.sh

