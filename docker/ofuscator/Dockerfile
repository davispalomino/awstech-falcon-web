FROM node:9.5.0
WORKDIR /usr/bin
RUN npm install -g javascript-obfuscator
COPY /docker/ofuscator/config.js /tmp/config.js
# CMD ["javascript-obfuscator", "/app/webapp.js", "--output","/app/webapp.js","--config","/tmp/config.js"]