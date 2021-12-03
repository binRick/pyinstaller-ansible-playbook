FROM fedora35-builder as fedora35-ansible
ARG LINODE_TOKEN=$LINODE_TOKEN
ARG ANSIBLE_VERSION=$ANSIBLE_VERSION
ENV LOG_LEVEL=ERROR
ARG LOG_LEVEL=$LOG_LEVEL
ENV SPEC_FILE=ansible.spec
ARG SPEC_FILE=$SPEC_FILE

RUN bash -c 'source /root/.ansible-build-venv/bin/activate && pip install -q -U pip && pip install six watchdog'
RUN bash -c '[[ -d /compile/dist-static ]] || mkdir -p /compile/dist-static'

COPY ansible-playbook.py ansible.spec /compile/
ADD src/ansible-4.9.0.tar.gz /
RUN bash -c 'source /root/.ansible-build-venv/bin/activate && pip install /ansible-4.9.0'

RUN bash -c 'source /root/.ansible-build-venv/bin/activate && pyinstaller ansible.spec'
RUN bash -c 'python3 -m pip install staticx && find /compile/dist -type f | while read -r f; do staticx --strip --loglevel $LOG_LEVEL /compile/dist/$(basename $f) /compile/dist-static/$(basename $f); done'
RUN bash -c 'find /compile/dist /compile/dist-static -type f > /files.txt'
