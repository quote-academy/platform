FROM nginx:1-alpine

EXPOSE 80 443

ADD ./vhosts/api.conf /etc/nginx/conf.d/api.conf

CMD ["nginx", "-g", "daemon off;"]
