# docker-backup-mariadb

Docker image of MariaDB, cron and tini for scheduling database dumps.

## Usage

This repository is used to create a Docker image that can be used to backup a MariaDB database. The image is based on the official MariaDB image and adds cron and tini to the image. The image is used to create a container that will run a cron job to backup a MariaDB database.

The image is available on Docker Hub at [dimitriosdockerhub/backup-mariadb](https://hub.docker.com/r/dimitriosdockerhub/backup-mariadb).

## Manual Build

To build the image manually, clone the repository and run the following command:

```sh
docker build -t backup-mariadb .
```

## Docker Compose

The following is an example of a `docker-compose.yml` file that can be used to create a MariaDB container and a backup container. The backup container will run a cron job to backup the MariaDB database.

If the dump fails, the error file will contain the error message. Otherwise, it will be empty. You may want to check the error file to see if the dump was successful using monitoring tools like Zabbix or Prometheus.

```yml
version: "3.9"

services:
  mariadb:
    container_name: ${MARIADB_CONTAINER_NAME:-mariadb}
    image: mariadb:${MARIADB_IMAGE_VERSION:-latest}
    hostname: ${MARIADB_CONTAINER_NAME:-mariadb}
    environment:
      MARIADB_ROOT_PASSWORD: ${MARIADB_ROOT_PASSWORD:-password}
      MARIADB_DATABASE: ${MARIADB_DATABASE:-default_database}
      MARIADB_USER: ${MARIADB_USER:-user}
      MARIADB_PASSWORD: ${MARIADB_PASSWORD:-user_password}
    volumes:
      - mariadb_data:/var/lib/mysql
    ports:
      - "${MARIADB_EXT_PORT-10000:-3306}:3306"
    restart: unless-stopped
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "mariadb-admin ping -h localhost -u root -p$${MARIADB_ROOT_PASSWORD:-password}",
        ]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s
    networks:
      - mariadb_network

  backup_mariadb:
    container_name: backup_${MARIADB_CONTAINER_NAME:-mariadb}
    image: dimitriosdockerhub/backup-mariadb:${MARIADB_IMAGE_VERSION:-latest}
    restart: unless-stopped
    depends_on:
      - mariadb
    volumes:
      - ${MARIADB_PATH_TO_DUMP:-/backups}:/backups:rw
    environment:
      CRONTAB: |
        ${MARIADB_CRONTAB:-50 5 * * *} bash -c "mariadb-dump --host=${MARIADB_CONTAINER_NAME:-mariadb} --user=root --password=${MARIADB_ROOT_PASSWORD:-password} --all-databases > ${MARIADB_PATH_TO_DUMP:-/backups}/${MARIADB_BACKUP_NAME:-all-databases-backup}.sql 2>${MARIADB_PATH_TO_DUMP:-/backups}/${MARIADB_BACKUP_NAME:-backup-name}.err && gzip -9 -f ${MARIADB_PATH_TO_DUMP:-/backups}/${MARIADB_BACKUP_NAME:-all-databases-backup}.sql"
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "ps aux | grep cron | grep -v grep && command -v mariadb-dump",
        ]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s
    networks:
      - mariadb_network

volumes:
  mariadb_data:

networks:
  mariadb_network:
    driver: bridge
```

### Environment Variables

The following environment variables can be used to configure the MariaDB container and the backup container:

```txt
MARIADB_CONTAINER_NAME=mariadb-container
MARIADB_IMAGE_VERSION=latest
MARIADB_ROOT_PASSWORD=password
MARIADB_DATABASE=default_database
MARIADB_USER=user
MARIADB_PASSWORD=user_password
MARIADB_EXT_PORT=10002
MARIADB_PATH_TO_DUMP=/backups
MARIADB_BACKUP_NAME=all-databases-backup
MARIADB_CRONTAB=*/2 * * * *
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
