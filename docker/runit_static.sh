#!/usr/bin/env bash
cd /srv/odania

echo "Generating web config"
pwd
ls -lha
rake web:generate

echo "Starting nginx"
exec nginx -g 'daemon off;'
