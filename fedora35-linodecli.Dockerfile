FROM fedora35-builder as fedora35-linodecli
ARG LINODE_TOKEN=$LINODE_TOKEN
ARG ANSIBLE_VERSION=$ANSIBLE_VERSION
ENV LOG_LEVEL=ERROR
ARG LOG_LEVEL=$LOG_LEVEL
ENV SPEC_FILE=ansible.spec
ARG SPEC_FILE=$SPEC_FILE

RUN bash -c 'source /root/.ansible-build-venv/bin/activate && pip install -q -U pip && pip install linode-cli'
RUN bash -c '[[ -d /compile/dist-static ]] || mkdir -p /compile/dist-static'

COPY linodecli.spec /compile
WORKDIR /compile
RUN bash -c 'source /root/.ansible-build-venv/bin/activate && pyinstaller linodecli.spec'
RUN bash -c 'python3 -m pip install staticx && find /compile/dist -type f | while read -r f; do staticx --strip --loglevel $LOG_LEVEL /compile/dist/$(basename $f) /compile/dist-static/$(basename $f); done'
RUN bash -c 'find /compile/dist /compile/dist-static -type f > /files.txt'
