FROM fedora:38

RUN dnf -y install ruby openssh openssh-clients zsh expat expat-devel

# Workaround https://github.com/maxfierke/mstrap/issues/45
RUN dnf -y install crypto-policies-scripts && \
  sed -i "/s += RH_SHA1_SECTION.format('yes' if sha1_sig else 'no')/ s/\$/ if sha1_sig else ''/" /usr/share/crypto-policies/python/policygenerators/openssl.py && \
  update-crypto-policies --set DEFAULT:NO-SHA1

RUN adduser mstrap -G wheel
RUN echo 'mstrap ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER mstrap
ENV HOME=/home/mstrap
WORKDIR /home/mstrap

RUN mkdir -p $HOME/.mstrap
ADD --chown=mstrap --chmod=644 config.hcl $HOME/.mstrap/
ADD test.sh test.sh

CMD [ "./test.sh" ]
