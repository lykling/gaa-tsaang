FROM archlinux:latest

ARG UID=1139
ARG GID=1139
ARG USER=umbra
ARG GROUP=umbra

# update package db
RUN pacman -Sy

# install base tools
RUN pacman -S --noconfirm \
        base-devel \
        which \
        curl \
        make \
        cmake \
        automake \
        ca-certificates \
        wget \
        git \
        zsh \
        gcc

# create work account
RUN groupadd -g "${GID}" "${GROUP}"
RUN useradd -m -s /bin/zsh -d /home/${USER} -u "${UID}" -g "${GID}" -G wheel "${USER}"
RUN sed -e 's/# \(%wheel ALL=.* NOPASSWD.*\)/\1/' -i /etc/sudoers

# install yay
USER ${USER}
RUN git clone https://aur.archlinux.org/yay-bin.git /home/${USER}/yay-bin && cd /home/${USER}/yay-bin && makepkg -si --noconfirm

# install network tools
RUN yay -S --noconfirm --cleanafter \
        strace \
        ltrace \
        iproute2 \
        iputils \
        proxychains-ng \
        tcpdump \
        traceroute \
        openbsd-netcat \
        websocat \
        bind \
        nmap \
        tcpping \
        hping

# install common apps
RUN yay -S --noconfirm --cleanafter \
        openssh \
        vim \
        docker \
        dive \
        helm \
        kubectl \
        rlwrap

RUN yay -S --noconfirm --cleanafter \
        mysql-clients \
        mongodb-bin \
        mongodb-tools-bin \
        redis

# install bosfs
RUN yay -S --noconfirm --cleanafter \
        fuse2
RUN wget -c -O /tmp/bosfs-1.0.0.13.2.tar.gz https://sdk.bce.baidu.com/console-sdk/bosfs-1.0.0.13.2.tar.gz
COPY bosfs.patch /tmp/
RUN tar -zxf /tmp/bosfs-1.0.0.13.2.tar.gz -C /tmp && pushd /tmp/bosfs-1.0.0.13.2 && patch -p1 < /tmp/bosfs.patch && sudo bash build.sh && popd && sudo rm -rf /tmp/bosfs*

RUN yay -S --noconfirm --cleanafter \
        the_silver_searcher \
        tmux \
        bc
USER root
