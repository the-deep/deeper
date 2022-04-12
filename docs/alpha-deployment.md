# Alpha deployment using docker-compose-alpha.yml

### Generate self-signed certificate for nginx
```bash
# Create a directory (shared to nginx container)
mkdir nginx-certs
cd nginx-certs
# Generate the certificate
openssl req -x509 -nodes -newkey rsa:2048 -keyout server.key -out server.crt
```

### Create .env file
```bash
cp .env-alpha-sample .env
# Modify as needed, make sure empty value are provided
```


### Start
```bash
docker-compose -f docker-compose-alpha.yml -d up
docker-compose -f docker-compose-alpha.yml logs -f
```
