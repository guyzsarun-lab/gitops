FROM python:3.14-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN pip install apprise

RUN adduser -S appuser
USER appuser

ENTRYPOINT [ "apprise" ]