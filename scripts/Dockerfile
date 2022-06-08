FROM alpine:3
RUN apk add --update \
    curl \
    bash \
    && rm -rf /var/cache/apk/*
WORKDIR /app
COPY . .
ENTRYPOINT ["bash"]
