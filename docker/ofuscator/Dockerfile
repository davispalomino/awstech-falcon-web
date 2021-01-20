FROM node:9.5.0
WORKDIR /usr/bin
RUN npm install -g javascript-obfuscator
COPY /docker/ofuscator/config.js /tmp/config.js
CMD ["javascript-obfuscator", "/app/dist/", "--output","/app/dist/","--config","/tmp/config.js"]