FROM homeassistant/qemux86-64-homeassistant:0.103.2
# add env
ENV LANG C.UTF-8
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories 
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
