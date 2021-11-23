FROM fedora:latest as fedora
RUN dnf -y install bash zsh

WORKDIR /test
COPY ./dist/ansible /test/ansible
COPY ./dist/ansible-playbook /test/ansible-playbook

RUN /test/ansible-playbook --help
RUN /test/ansible --help
RUN /test/ansible-playbook --version
RUN /test/ansible --version
