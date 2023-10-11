FROM archlinux:base

RUN pacman --noconfirm -Syu && pacman --noconfirm -S ruby openssh zsh expat sudo

RUN useradd -m -G wheel mstrap
RUN echo 'mstrap ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER mstrap
ENV HOME=/home/mstrap
WORKDIR /home/mstrap

RUN mkdir -p $HOME/.mstrap
ADD --chown=mstrap config.hcl $HOME/.mstrap/
ADD test.sh test.sh

CMD [ "./test.sh" ]
