FROM alpine:3.19 as BUILDER
ARG VERSION=v10.19.4
WORKDIR /app

RUN wget https://github.com/gchq/CyberChef/releases/download/${VERSION}/CyberChef_${VERSION}.zip && \
    unzip CyberChef_${VERSION}.zip && \
    mv CyberChef_${VERSION}.html index.html

FROM nginx:stable-alpine
COPY --from=BUILDER /app /usr/share/nginx/html

EXPOSE 80