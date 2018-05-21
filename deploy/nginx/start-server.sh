#!/bin/bash

# certbot --nginx --agree-tos --domains $DOMAINS --email $EMAIL --non-interactive

# certbot --agree-tos --manual \
#     --domains $DOMAINS \
#     --email $EMAIL \
#     --preferred-challenges dns certonly

echo 'Staring nginx server'
nginx -g "daemon off;"
