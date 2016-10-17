FROM node:4.2.5
ADD . /opt/ui
WORKDIR /opt/ui
RUN npm install --production
CMD ["npm", "start"]
