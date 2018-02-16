FROM homeassistant/qemux86-64-homeassistant:0.63.2
# add env
ENV LANG C.UTF-8
RUN mkdir /usr/lib/python3.6/site-packages/hass_frontend/js/ \
	&& mkdir /usr/lib/python3.6/site-packages/hass_frontend_es5/js/
COPY jsapi.js /usr/lib/python3.6/site-packages/hass_frontend/js/jsapi.js
COPY jsapi.js /usr/lib/python3.6/site-packages/hass_frontend_es5/js/jsapi.js
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	&& mkdir /root/.pip \
	&& echo "[global]" > /root/.pip/pip.conf \
	&& echo "trusted-host =  mirrors.aliyun.com" >> /root/.pip/pip.conf \
	&& echo "index-url = http://mirrors.aliyun.com/pypi/simple" >> /root/.pip/pip.conf \
	&& sed -ie "s/^_GROUP_TYPES.*/_GROUP_TYPES = [(STATE_ON, STATE_OFF), (STATE_HOME, STATE_NOT_HOME),('雨','晴天'),('晴夜','多云'),('阴','雪'),('风','雾'),/g" /usr/lib/python3.6/site-packages/homeassistant/components/group/__init__.py \
	&& find / -name "frontend.html" | xargs sed -i "s/https:\/\/www.google.com\/jsapi/..\/..\/static\/js\/jsapi.js/g" \
	&& find / -name "frontend.html.gz" | xargs rm -f \
	&& gzip -c /usr/lib/python3.6/site-packages/hass_frontend_es5/frontend.html > /usr/lib/python3.6/site-packages/hass_frontend_es5/frontend.html.gz \
	&& gzip -c /usr/lib/python3.6/site-packages/hass_frontend/frontend.html > /usr/lib/python3.6/site-packages/hass_frontend/frontend.html.gz
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
