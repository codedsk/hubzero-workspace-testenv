# debian 7 container for workspace development

FROM debian:7


#####################################################
# install packages needed to run invokeapp
#
# package            needed to...
#
# bash               needed by invokeapp
# tcl                needed for toolparams
# tk                 needed by toolparams

# install packages needed for developement
#
# curl
# git
# subversion
# tar
# unzip
# wget

# add hubzero packages

# add packages to build rappture

# packages needed to build core rappture libraries
# curl
# gcc
# g++
# libssl-dev
# make
# patch
# subversion
# libx11-dev
# libxt-dev
# libxext-dev
# libfreetype6-dev
# libxft-dev
# libgl1-mesa-dev
# libxrandr-dev
# libpng12-dev
# libjpeg8-dev
# libtiff4-dev
# libxpm-dev
# libncurses5-dev
# libavcodec-dev
# libavformat-dev
#
## install packages needed to build language bindings for
## fortran, octave, perl, python, ruby, R, java
# gfortran
# octave
# liboctave-dev
# perl
# libperl-dev
# python
# python-dev
# ruby
# ruby-dev
# r-base
# openjdk-7-jdk
# openjdk-7-jre
#
## install extra support packages for rappture
# gdb
# libavutil-dev


# install packages for python testing
# python
# pyton-pip
# xvfb

# add openssh client and server so we can ssh into the container for debugging

RUN apt-get update && apt-get install -y \
        wget; \
    echo "deb http://packages.hubzero.org/deb ellie-deb7 main contrib non-free" \
        > /etc/apt/sources.list.d/hubzero.list; \
    wget http://packages.hubzero.org/deb/hubzero-signing-key.asc -q -O - \
        | apt-key add -; \
    apt-get update && apt-get install -y \
        bash \
        curl \
        g++ \
        gcc \
        gdb \
        gfortran \
        git \
        hubzero-chuse \
        hubzero-filexfer \
        hubzero-icewm \
        hubzero-icewm-captive \
        hubzero-icewm-themes \
        hubzero-invokeapp \
        hubzero-mw-session \
        hubzero-rappture \
        hubzero-ratpoison-captive \
        hubzero-tigervnc-server \
        hubzero-twm-captive \
        hubzero-use \
        hubzero-use-apps \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libfreetype6-dev \
        libgl1-mesa-dev \
        libjpeg8-dev \
        libncurses5-dev \
        liboctave-dev \
        libperl-dev \
        libpng12-dev \
        libtiff4-dev \
        libssl-dev \
        libx11-dev \
        libxext-dev \
        libxft-dev \
        libxpm-dev \
        libxrandr-dev \
        libxt-dev \
        make \
        octave \
        openjdk-7-jdk \
        openjdk-7-jre \
        openssh-client \
        openssh-server \
        patch \
        perl \
        python \
        python-dev \
        python-pip \
        ruby \
        ruby-dev \
        r-base \
        subversion \
        sudo \
        tar \
        tcl \
        tk \
        unzip \
        vim \
        wget \
        xterm \
        xvfb \
 && rm -rf /var/lib/apt/lists/*
#
#####################################################



#####################################################
# setup ssh login

RUN mkdir /var/run/sshd;

# create user accounts
# add guest user to sudo group
# update user passwords
RUN echo 'root:root' | chpasswd; \
    \
    useradd --create-home --home-dir /home/guest --shell /bin/bash guest; \
    echo 'guest:guest' | chpasswd; \
    usermod -a -G sudo guest; \
    \
    useradd --create-home --home-dir /home/apps --shell /bin/bash apps; \
    echo 'apps:apps' | chpasswd;

# open the container's port 22
EXPOSE 22
#####################################################


# create /apps directory
RUN mkdir -p /apps; \
    chown apps:apps /apps; \
    chmod 775 /apps;

# populate the /apps directory structure as the apps user
USER apps
COPY setup_mock_workspace_apps_directory.sh  /tmp/
RUN /tmp/setup_mock_workspace_apps_directory.sh

# install rappture
RUN basedir=`pwd`; \
    git clone https://github.com/hubzero/hapi; \
    cd hapi/scripts; \
    ./rappture-latest_install.sh; \
    cd /apps/share64/debian7/rappture; \
    rpdir=`find . -maxdepth 1 -type d -name '*tag_*' -print | tail -n1 | xargs basename`; \
    ln -s ${rpdir} dev; \
    ln -s ${rpdir} current; \
    ln -s current/bin bin; \
    ln -s current/doc doc; \
    ln -s current/examples examples; \
    ln -s current/include include; \
    ln -s current/lib lib; \
    ln -s current/man man; \
    ln -s current/share share; \
    cd /apps/share64/debian7/environ.d; \
    ln -s /apps/share64/debian7/rappture/bin/rappture.use rappture; \
    cd ${basedir}; \
    rm -rf hapi;

# switch back to root user
USER root

# upgrading pip removes /usr/bin/pip-2.7
# it may not matter if /usr/local/bin/pip is in the PATH
COPY requirements.txt  /tmp/
RUN pip install -U pip; \
    ln -s /usr/local/bin/pip2.7 /usr/bin/pip-2.7; \
    pip install -r /tmp/requirements.txt;


# use an entrypoint to allow for starting a command
# from "docker run ..."
COPY entry.sh /entry.sh
ENTRYPOINT ["/entry.sh"]


# start the sshd daemon as the default command
CMD ["/usr/sbin/sshd", "-D"]
