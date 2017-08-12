# docker-boca

Container with Boca, an administration system to held programming contests (e.g. ACM-ICPC, Maratona de Programação da SBC).

# docker-compose.yml

Create a `docker-compose.yml` and include the following contet.

```Dockerfile

version: '2'

services:
  boca:
    image: decomp:boca
    container_name: boca
    privileged: true
    ports:
      - 80:80
    environment:
      LOG_NAME: boca.host.com
      SERVERNAME: boca.host.com
      DBHOST: postgres-boca
      DBPASS: boca
    links:
      - postgres-boca
  postgres-boca:
    image: postgres
    container_name: postgres-boca
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: bocauser
      POSTGRES_PASSWORD: boca
```

Run `docker-compose up -d`.

Wait the initialization. You can access `docker logs boca` to monitor the progress of the init process.

Access `http://locahost/boca`.


