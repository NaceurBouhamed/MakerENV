#Download base image ubuntu 16.04
FROM ubuntu:16.04

# Update Ubuntu Software repository
RUN apt-get update \
    && apt-get install -y curl \
    && curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh \
    && bash nodesource_setup.sh \
    && apt-get install -y nodejs

RUN npm install -g ganache-cli \
    && apt-get install -y cargo  \
    && apt-get install -y libudev-dev
    
RUN apt-get install -y git \
    && apt-get install -y build-essential 

ADD ./shell .

RUN chmod +x shell \
    && bash shell

RUN git clone https://github.com/dapphub/ethrun \
    && make link -C ethrun

ENV USER docker

RUN apt-get install sudo \
    && adduser --disabled-password --gecos '' docker \
    && adduser docker sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker

RUN curl https://nixos.org/nix/install | sh \
    && . /home/docker/.nix-profile/etc/profile.d/nix.sh \
    && nix-channel --add https://nix.dapphub.com/pkgs/dapphub \
    && nix-channel --update \
    && nix-env -iA dapphub.hevm \
    && nix-env -iA dapphub.seth

RUN sudo apt-get install -y software-properties-common \
    && sudo add-apt-repository ppa:ethereum/ethereum \
    && sudo apt-get update \
    && sudo apt-get install -y solc

RUN sudo git clone https://github.com/dapphub/dapp.git \
    && cd dapp \
    && sudo make link

RUN sudo git clone https://github.com/dapphub/token.git \
    && cd token \
    && sudo make install

RUN sudo mkdir project && cd project \
    && sudo git clone https://github.com/makerdao/sai.git \
    && cd sai \
    && sudo make link \
    && sudo chown -R docker:docker /project \
    && sudo chmod -R 755 /project

ADD project /project

RUN cd /project/sai \
    && npm install \
    && dapp update \
    && sudo apt-get install -y jshon \
    && sudo ln -s ~/.nix-profile/bin/seth /usr/local/bin/seth

EXPOSE 80 443 8545