FROM openjdk:25-jdk-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends adduser ca-certificates curl \
    && rm -rf /var/lib/apt/lists/* \
    && addgroup --system appgroup \
    && adduser --system --group appuser

WORKDIR /app

ARG SERVICE_NAME=config-server
ARG PROFILE=dev
ARG SERVER_PORT=8888
ARG REDIS_HOST=redis
ARG REDIS_PORT=6379

ENV SPRING_PROFILES_ACTIVE=${PROFILE}
ENV SERVER_PORT=${SERVER_PORT}
ENV REDIS_HOST=${REDIS_HOST}
ENV REDIS_PORT=${REDIS_PORT}

COPY --chown=appuser:appgroup build/libs/${SERVICE_NAME}.jar app.jar

RUN chmod 755 app.jar
USER appuser

EXPOSE ${SERVER_PORT}

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
    CMD curl --fail http://localhost:${SERVER_PORT}/health/${SERVICE_NAME}/status || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
