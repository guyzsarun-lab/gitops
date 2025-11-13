FROM python:3.14-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN pip install apprise

RUN adduser -D -H -s /sbin/nologin appuser
USER appuser

ENTRYPOINT [ "apprise" ]