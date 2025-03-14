FROM lissy93/dashy:release-3.1.1

COPY config.yml /app/user-data/conf.yml
COPY ./assets /app/public/item-icons

EXPOSE 8080

RUN yarn build

CMD [ "yarn", "start" ]