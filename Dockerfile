FROM ubuntu:20.04

RUN apt update && apt install unzip wget sudo dpkg -y
RUN wget -q https://s3.amazonaws.com/publicsctdownload/Ubuntu/aws-schema-conversion-tool-1.0.latest.zip &&\
    unzip aws-schema-conversion-tool-1.0.latest.zip && \
    sudo dpkg -i aws-schema-conversion-tool**.deb

WORKDIR /app
CMD ["/bin/bash"]