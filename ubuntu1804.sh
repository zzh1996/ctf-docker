#!/bin/sh
docker build -t ctf_ubuntu_1804 - <<DOCKERFILE_EOF || exit 1
from ubuntu:18.04
run rm /etc/dpkg/dpkg.cfg.d/excludes
run sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
#run mkdir -p ~/.config/pip
#run printf "[global]\nindex-url = https://mirrors.ustc.edu.cn/pypi/web/simple\nformat = columns\n" > ~/.config/pip/pip.conf

run dpkg --add-architecture i386
run apt update && apt full-upgrade -y

run apt install -y locales
run sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
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
    nmap libssl-dev

run pip3 install -U pip
run pip2 install -U pip
run pip3 install -U ipython pycrypto gmpy2 gmpy angr formatstring
run pip3 install -U git+https://github.com/arthaud/python3-pwntools.git
run pip2 install -U ipython pycrypto gmpy2 gmpy angr pwntools ropgadget

run git clone https://github.com/scwuaptx/peda.git ~/peda
run cp ~/peda/.inputrc ~/
run git clone https://github.com/scwuaptx/Pwngdb.git ~/Pwngdb
run cp ~/Pwngdb/.gdbinit ~/

run sh -c "\$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true
run curl https://raw.githubusercontent.com/zzh1996/zshrc/master/zshrc.sh > ~/zshrc.sh
run sed -i '/source \\\$ZSH\/oh-my-zsh.sh/isource ~/zshrc.sh' ~/.zshrc
run chsh -s /usr/bin/zsh

run curl https://raw.githubusercontent.com/wklken/vim-for-server/master/vimrc > ~/.vimrc

cmd zsh -i
DOCKERFILE_EOF

docker run -it --rm --privileged --cap-add=SYS_PTRACE \
    --security-opt seccomp=unconfined \
    -v ${1:-`pwd`}:/root/ctf_docker \
    -w /root/ctf_docker \
    ctf_ubuntu_1804
