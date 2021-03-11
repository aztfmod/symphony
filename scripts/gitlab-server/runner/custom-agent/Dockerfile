FROM aztfmod/rover-agent:0.13.6-2103.0304-gitlab


COPY ./gitlab.sh .
COPY ./gitlab.crt /usr/local/share/ca-certificates/gitlab.crt

RUN sudo chmod +x ./gitlab.sh && \
    sudo update-ca-certificates 
    

ENTRYPOINT ["./gitlab.sh"]
