FROM fedora35-builder as fedora35-yaml2json
ARG LINODE_TOKEN=$LINODE_TOKEN
ENV LOG_LEVEL=ERROR
ARG LOG_LEVEL=$LOG_LEVEL
ENV SPEC_FILE=yaml2json.spec
ARG SPEC_FILE=$SPEC_FILE

RUN bash -c 'source /root/.ansible-build-venv/bin/activate && pip install -q -U pip && pip install json2yaml'
RUN bash -c '[[ -d /compile/dist-static ]] || mkdir -p /compile/dist-static'

COPY yaml2json.py yaml2json.spec /compile/
RUN bash -c 'source /root/.ansible-build-venv/bin/activate && pyinstaller yaml2json.spec'
RUN bash -c 'python3 -m pip install staticx && find /compile/dist -type f | while read -r f; do staticx --strip --loglevel $LOG_LEVEL /compile/dist/$(basename $f) /compile/dist-static/$(basename $f); done'
RUN bash -c 'find /compile/dist /compile/dist-static -type f > /files.txt'
