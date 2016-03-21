#!/usr/bin/env bash
cd /srv/odania

echo "Generating web config"
pwd
ls -lha
rake web:generate

# Only run once. This will wait until signaled
exec kill -STOP "$$";
