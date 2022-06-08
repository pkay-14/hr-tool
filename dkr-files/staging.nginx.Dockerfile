FROM nginx:1.13.8-alpine

EXPOSE 80

COPY staging.nginx.default.conf /etc/nginx/conf.d/default.conf
