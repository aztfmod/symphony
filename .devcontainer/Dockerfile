FROM aztfmod/rover:0.13.6-2103.0304

RUN sudo apt-get update \
    && sudo apt-get install -y wget jq nano

RUN sudo wget https://golang.org/dl/go1.16.linux-amd64.tar.gz \
    && sudo tar -C /usr/local -xzf go1.16.linux-amd64.tar.gz
