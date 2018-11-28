#!/bin/sh
docker build -t zzh1996/ctf_ubuntu_1804 - <<DOCKERFILE_EOF || exit 1
from ubuntu:18.04
run rm /etc/dpkg/dpkg.cfg.d/excludes
run sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
#run mkdir -p ~/.config/pip
#run printf "[global]\nindex-url = https://mirrors.ustc.edu.cn/pypi/web/simple\nformat = columns\n" > ~/.config/pip/pip.conf

run dpkg --add-architecture i386 && apt update && apt full-upgrade -y && apt clean

run apt install -y locales && apt clean && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
env LC_ALL en_US.UTF-8
env LANG en_US.UTF-8
env LANGUAGE en_US.UTF-8

run apt install -y git sudo bash make nano vim zsh tmux \
    binutils nasm gcc gdb g++ gcc-multilib g++-multilib \
    libc6-dev-i386 libc6-dbg libc6-dbg:i386 libstdc++6:i386 \
    python python-pip python3 python3-pip curl netcat \
    htop iotop iftop man strace ltrace wget \
    manpages-posix manpages-posix-dev \
    libgmp3-dev libmpfr-dev libmpc-dev \
    nmap libssl-dev \
    inetutils-ping dnsutils whois mtr \
    && apt clean

run pip3 install -U pip && \
    pip2 install -U pip
run pip3 install -U ipython pycrypto gmpy2 gmpy angr formatstring && \
    pip3 install -U git+https://github.com/arthaud/python3-pwntools.git && \
    pip2 install -U ipython pycrypto gmpy2 gmpy angr pwntools ropgadget

run useradd -ms /usr/bin/zsh ctf && \
    adduser ctf sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
user ctf
workdir /home/ctf

run git clone https://github.com/scwuaptx/peda.git ~/peda && cp ~/peda/.inputrc ~/ && \
    git clone https://github.com/scwuaptx/Pwngdb.git ~/Pwngdb && cp ~/Pwngdb/.gdbinit ~/

run sh -c "\$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true && \
    curl https://raw.githubusercontent.com/zzh1996/zshrc/master/zshrc.sh > ~/.zshrc.sh && \
    sed -i '/source \\\$ZSH\/oh-my-zsh.sh/isource ~/.zshrc.sh' ~/.zshrc && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    curl https://raw.githubusercontent.com/wklken/vim-for-server/master/vimrc > ~/.vimrc

entrypoint zsh -i
DOCKERFILE_EOF

docker run -it --rm --privileged --cap-add=SYS_PTRACE \
    --security-opt seccomp=unconfined \
    -v ${1:-`pwd`}:/root/ctf_docker \
    --hostname ctf_docker \
    --name ctf_ubuntu_1804 \
    zzh1996/ctf_ubuntu_1804
