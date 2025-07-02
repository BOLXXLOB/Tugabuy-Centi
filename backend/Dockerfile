# Base image for the docker image
FROM node:lts-alpine
 
# Creates work directory
WORKDIR /code
ENV NODE_OPTIONS=--max_old_space_size=8192
 
# Copy from the local folder to the container
COPY package.json package-lock.json ./
 
# Runs the CMD commands to install all dependencies
#RUN npm install \
#    && npm install typescript -g
RUN npm install
 
# Copy to the container
COPY . .
 
# Compile typescript code
RUN npx tsc
 
# Starts application
CMD ["npm", "start"]