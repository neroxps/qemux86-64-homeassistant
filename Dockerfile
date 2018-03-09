FROM homeassistant/qemux86-64-homeassistant:0.65.0
# add env
ENV LANG C.UTF-8
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	&& mkdir /root/.pip \
	&& echo "[global]" > /root/.pip/pip.conf \
	&& echo "trusted-host =  mirrors.aliyun.com" >> /root/.pip/pip.conf \
	&& echo "index-url = http://mirrors.aliyun.com/pypi/simple" >> /root/.pip/pip.conf \
	&& sed -ie "s/^_GROUP_TYPES.*/_GROUP_TYPES = [(STATE_ON, STATE_OFF), (STATE_HOME, STATE_NOT_HOME),('雨','晴天'),('晴夜','多云'),('阴','雪'),('风','雾'),/g" /usr/lib/python3.6/site-packages/homeassistant/components/group/__init__.py 
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
