FROM ubuntu:20.04 AS vim-build

# NOTE(ycho): Avoid questions during build process.
ENV DEBIAN_FRONTEND=noninteractive

# Install vim dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    sudo \
    gnupg2 \
    curl \
    wget \
    ca-certificates \
    build-essential \
    cmake \
    git \
    g++ \
    gdb \
    python3-dev \
    libx11-dev \
    libxtst-dev \
    libxt-dev \
    libsm-dev \
    libxpm-dev \
    libncurses-dev \
    checkinstall \
    && rm -rf /var/lib/apt/lists*

# Install vim.
RUN git clone --depth 1 \
    https://github.com/vim/vim.git /tmp/vim \
    && cd /tmp/vim \
    && ./configure \
        --with-features=huge \
        --enable-pythoninterp=no \
        --enable-python3interp=yes \
        --with-python3-config-dir="$(python3-config --configdir)" \
        --with-x=yes \
        --enable-fail-if-missing \
        --enable-gui=auto \
        --enable-cscope \
        --enable-terminal \
    && mkdir -p /usr/local/bin \
    && make -j8 VIMRUNTIME=/usr/local/share/vim/vim91 VIMRUNTIMEDIR=/usr/local/share/vim/vim91 \
    && sudo checkinstall -D --install=no --fstrans=no make install \
    && mv vim_*.deb /tmp \
    && cd ../ && rm -rf /tmp/vim \
    && rm -rf /tmp/vim


# -- BUILD from isaaclab:latest. --
FROM corn:latest AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_NO_CACHE_DIR=1
ARG USERNAME=user

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Install vim.
COPY --from=vim-build /tmp/vim_*.deb /tmp/
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    /tmp/vim_*.deb \
    && sudo apt-mark hold vim \
    && sudo rm -rf /var/lib/apt/lists/* \
    && dpkg -c /tmp/vim_*.deb \
    && sudo rm /tmp/vim_*.deb

# Install vim plugins & YouCompleteMe.
# https://stackoverflow.com/a/54477179
SHELL ["/bin/bash", "-c"]
RUN git clone --depth 1 \
    https://github.com/VundleVim/Vundle.vim.git /home/user/.vim/bundle/Vundle.vim \
    && wget "https://raw.githubusercontent.com/yycho0108/dotfiles/master/.vimrc" \
        -O /home/user/.vimrc \
    && /usr/local/bin/vim +PluginInstall +qall
RUN /home/user/.vim/bundle/YouCompleteMe/install.py --clang-completer

# Also install QoL packages.
RUN python3 -m pip install \
    mypy pyflakes autopep8 flake8

# Also bind inputrc.
RUN wget "https://raw.githubusercontent.com/yycho0108/dotfiles/master/.inputrc" \
    -O /home/user/.inputrc

# Install other QoL packages.
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    fd-find \
    autojump \
    && sudo rm -rf /var/lib/apt/lists*
RUN echo -e '\nsource /usr/share/autojump/autojump.sh' >> "${HOME}/.bashrc"

# Ensure .cache is owned by `user`.
RUN mkdir /home/user/.cache
