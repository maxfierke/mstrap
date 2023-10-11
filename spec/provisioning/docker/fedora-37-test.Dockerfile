FROM fedora:37

RUN dnf -y install ruby openssh openssh-clients zsh expat expat-devel

RUN adduser mstrap -G wheel
RUN echo 'mstrap ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER mstrap
RUN mkdir -p $HOME/.mstrap
ADD --chown=mstrap config.hcl $HOME/.mstrap/
ADD test.sh test.sh
CMD [ "./test.sh" ]
