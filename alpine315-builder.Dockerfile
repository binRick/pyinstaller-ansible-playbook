FROM alpine:3.15 as alpine315-builder
ENV ANSIBLE_VERSION=4.9.0
RUN  echo ANSIBLE_VERSION=$ANSIBLE_VERSION
WORKDIR /compile
RUN     apk update
RUN     apk add --no-cache \
        git \
        tcpdump \
        ngrep \
        bash \
        zsh \
        rsync \
        sqlite \
        dnsmasq \
        nftables \
        iperf \
        curl \
        wget \
        tmux \
        file \
        gcompat \
        librrd \
        strace \
        openssh \
        npm \
        gcc \
        make python3 python3-dev musl-dev musl libffi-dev libffi py3-wheel coreutils py3-pip
COPY passh /bin/passh

#COPY ./bin ansi ansible-playbook.py ansible.spec Build.sh utils.sh /compile/
RUN python3 -m venv /root/.ansible-build-venv
RUN /bin/bash -c 'source /root/.ansible-build-venv/bin/activate && pip install -q -U pip'
RUN /bin/bash -c 'source /root/.ansible-build-venv/bin/activate && pip install pyinstaller'

#WORKDIR /
#RUN bash -c "source /root/.ansible-build-venv/bin/activate && pip install /ansible-$ANSIBLE_VERSION"
#RUN passh /compile/Build.sh
