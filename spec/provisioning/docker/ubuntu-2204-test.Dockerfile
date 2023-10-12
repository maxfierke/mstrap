FROM ubuntu:22.04

RUN apt-get update && \
  apt-get -y install \
    curl expat libexpat1-dev lsb-release ruby ruby-bundler \
    openssh-client sudo zsh && \
  apt-get clean all

RUN useradd -m -s /bin/bash -G sudo mstrap
RUN echo 'mstrap ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER mstrap
RUN mkdir -p $HOME/.mstrap
ADD --chown=mstrap --chmod=644 config.hcl $HOME/.mstrap/
ADD test.sh test.sh
CMD [ "./test.sh" ]
