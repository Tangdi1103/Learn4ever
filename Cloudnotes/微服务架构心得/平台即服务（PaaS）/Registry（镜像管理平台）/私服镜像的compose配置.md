
```
version: '3.1'
services:
  registry:
    image: registry
    restart: always
    container_name: registry
    ports:
      - 5000:5000
    volumes:
      - /usr/local/docker/registry/data:/var/lib/registry

  frontend:
    image: konradkleine/docker-registry-frontend:v2
    restart: always
    ports:
      - 8080:80
    volumes:
      - ./certs/frontend.crt:/etc/apache2/server.crt:ro
      - ./certs/frontend.key:/etc/apache2/server.key:ro
    environment:
      - ENV_DOCKER_REGISTRY_HOST=192.168.243.130
      - ENV_DOCKER_REGISTRY_PORT=5000
```


运行成功后访问http://192.168.243.130:8080/home