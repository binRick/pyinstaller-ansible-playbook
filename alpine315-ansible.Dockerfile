FROM alpine315-builder as alpine315-ansible

WORKDIR /compile
COPY ansible.spec ansible-playbook.py /compile/

RUN apk add gcc make python3 python3-dev musl-dev musl libffi-dev libffi py3-wheel coreutils py3-pip
RUN bash -c "source /root/.ansible-build-venv/bin/activate && pip install six watchdog"
ADD src/ansible-4.9.0.tar.gz /
RUN bash -c "source /root/.ansible-build-venv/bin/activate && pip install /ansible-4.9.0"
RUN bash -c "source /root/.ansible-build-venv/bin/activate && pyinstaller ansible.spec"

#RUN python3 -m pip install staticx
#RUN bash -c "find /compile/dist -type f | while read -r f; do staticx --strip --loglevel ERROR /compile/dist/$(basename \$f) /compile/dist-static/$(basename \$f); done"

#RUN bash -c "source /root/.ansible-build-venv/bin/activate && pip install /ansible-$ANSIBLE_VERSION"
#RUN passh /compile/Build.sh
