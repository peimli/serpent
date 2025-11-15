FROM nginx:latest
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/nginx.conf
RUN mkdir /usr/share/nginx/serpent
COPY frontend/ /usr/share/nginx/serpent/
CMD ["nginx", "-g", "daemon off;"]
