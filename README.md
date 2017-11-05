# docker-boca

Container with Boca, an administration system to held programming contests (e.g. ACM-ICPC, Maratona de Programação da SBC).

# docker-compose.yml

Create a `docker-compose.yml` and include the following contet.

```Dockerfile

# docker-compose.yml

version: '2'

services:
  boca:
    image: decomp/boca
    container_name: boca
    ports:
      - 8090:80
    depends_on:
      - postgres-boca
    environment:
      DBHOST: postgres-boca
      DBUSER: bocauser
      DBNAME: bocadb
      DBPASS: boca
    links:
      - postgres-boca
    networks:
      - boca-network  
  boca-jail:
    image: decomp/boca-jail
    container_name: boca-jail
    privileged: true
    depends_on:
      - boca
      - postgres-boca
    environment:
      DBHOST: postgres-boca
      DBUSER: bocauser
      DBNAME: bocadb
      DBPASS: boca
    links:
      - postgres-boca
    networks:
      - boca-network  
  postgres-boca:
    image: postgres
    container_name: postgres-boca
    environment:
      POSTGRES_USER: bocauser
      POSTGRES_PASSWORD: boca
    networks:
      - boca-network  
networks:
 boca-network:
   driver: bridge
   ipam:
     config:
       - subnet: 192.169.1.1/16
```

Run `docker-compose up -d`.

Wait the initialization. You can access `docker logs boca` to monitor the progress of the init process.

Access `http://locahost/boca`.


