FROM homeassistant/qemux86-64-homeassistant:0.74.2
# add env
ENV LANG C.UTF-8
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	&& mkdir /root/.pip \
	&& echo "[global]" > /root/.pip/pip.conf \
	&& echo "trusted-host =  mirrors.aliyun.com" >> /root/.pip/pip.conf \
	&& echo "index-url = http://mirrors.aliyun.com/pypi/simple" >> /root/.pip/pip.conf 
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
