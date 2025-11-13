FROM python:3.14-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN pip install apprise==1.9.5

RUN adduser -D -H -s /sbin/nologin appuser
USER appuser

ENTRYPOINT [ "apprise" ]