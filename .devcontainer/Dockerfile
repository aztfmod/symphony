FROM aztfmod/rover:0.13.6-2104.1611

RUN sudo apt-get update \
  && sudo apt-get install -y wget jq nano

# Install GO Lang for testing using Terratest
RUN sudo wget https://golang.org/dl/go1.16.linux-amd64.tar.gz \
  && sudo tar -C /usr/local -xzf go1.16.linux-amd64.tar.gz
