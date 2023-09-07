#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
FROM eclipsecbi/centos:7

# ius-release required for python36u
RUN yum install -y \
    https://repo.ius.io/ius-release-el7.rpm \
    http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
  yum install -y --setopt=skip_missing_names_on_install=False \
    autoconf \
    automake \
    boost-test \
    blas \
    blas-devel \
    clang \
    cmake \
    cppcheck \
    createrepo \
    curl \
    doxygen \
    e2fsprogs-devel \
    gcc \
    gcc-c++ \
    git236 \
    gtk3 \
    ImageMagick \
    ImageMagick-devel \
    jq \
    lapack \
    lapack-devel \
    libtool \
    libXtst \
    lsof \
    mailx \
    make \
    mariadb-libs \
    metacity \
    mutter \
    net-snmp-devel.x86_64 \
    okular \
    java-11-openjdk-devel \
    openssl-devel.x86_64 \
    patch \
    perl \
    perl-LDAP \
    python36\
    rpm-build \
    rsync \
    strace \
    subversion \
    sysstat \
    tcl \
    tcpdump \
    tcsh \
    telnet \
    texlive \
    texlive-latex \
    texlive-tex4ht \
    tigervnc \
    tigervnc-server \
    tk \
    unzip \
    vino \
    webkitgtk3 \
    webkitgtk4 \
    wget \
    xmlstarlet \
    xorg-x11-apps.x86_64 \
    xorg-x11-drv-dummy.x86_64 \
    xorg-x11-drv-evdev.x86_64 \
    xorg-x11-drv-fbdev.x86_64 \
    xorg-x11-drv-keyboard.x86_64 \
    xorg-x11-drv-mouse.x86_64 \
    xorg-x11-drv-synaptics.x86_64 \
    xorg-x11-drv-vmmouse.x86_64 \
    xorg-x11-drv-void.x86_64 \
    xorg-x11-server-Xvfb.x86_64 \
    xterm \
    xz \
    zip \
    zsh \
  && yum clean all \
  && rm -rf /var/cache

RUN ln -s /usr/bin/git /usr/local/bin/git \
  && ln -s /bin/bash /usr/local/bin/hipp_shell \
  && if [ ! -a /etc/machine-id ] || [ ! -s /etc/machine-id ]; then dbus-uuidgen > /etc/machine-id; fi

ENV DISPLAY :0

RUN mkdir -p %(home)s/.vnc && chmod -R 775 %(home)s \
  && echo "123456" | vncpasswd -f > %(home)s/.vnc/passwd \
  && chmod 600 %(home)s/.vnc/passwd

# Create a custom vnc xstartup file
COPY scripts/xstartup_mutter.sh %(home)s/.vnc/xstartup.sh
RUN chmod 755 %(home)s/.vnc/xstartup.sh

# explicitly set locale
ENV LANG=en_US.UTF-8
