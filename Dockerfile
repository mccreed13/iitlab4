FROM nginx

LABEL maintainer = "a.lapushenko13@gmail.com"
LABEL version = "0.1"
LABEL description = "This is custom Docker Image for lab4"

COPY index.html /usr/share/nginx/html/index.html
