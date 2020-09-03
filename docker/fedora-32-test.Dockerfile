FROM fedora:32

# Workaround Linuxbrew perl postinstall fail
RUN sudo ln -s /usr/include/locale.h /usr/include/xlocale.h

RUN dnf -y install ruby openssh openssh-clients zsh expat expat-devel

RUN adduser mstrap -G wheel
RUN echo 'mstrap ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER mstrap
RUN mkdir -p $HOME/.mstrap
CMD [ "workspace/docker/test.sh" ]
