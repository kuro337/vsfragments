FROM alpine:latest

WORKDIR /app

RUN apk upgrade && apk update

COPY ./alpine_test.js /app/

RUN apk add --no-cache \
  build-base \
  curl \
  git \
  linux-headers \
  npm \
  py3-pip \
  python3 \
  python3-dev \
  sqlite \
  libffi-dev \
  nodejs 


RUN npm init -y && npm i vsfragments_node@latest

RUN ls 

RUN node /app/alpine_test.js