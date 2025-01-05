FROM nginx:alpine
LABEL maintainer="Rajesh Huria <rajesh.huria@gmail.com>"

COPY website /website
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
