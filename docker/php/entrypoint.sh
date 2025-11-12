#!/bin/sh
set -e

# Entrypoint: garante diretórios e permissões para uma instalação Laravel
# Ajusta permissões em mounts bindados sem falhar (usa || true onde necessário).

if [ ! -d /var/www/html ]; then
  mkdir -p /var/www/html
fi

# Criar diretórios esperados pelo Laravel
mkdir -p /var/www/html/storage /var/www/html/storage/logs /var/www/html/storage/framework/{sessions,views,cache} /var/www/html/bootstrap/cache

# Tentar ajustar dono para www-data (ignora erro se não for possível)
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache 2>/dev/null || true

# Ajustar permissões mais seguras: diretórios 775, arquivos 664
find /var/www/html/storage -type d -exec chmod 775 {} + 2>/dev/null || true
find /var/www/html/storage -type f -exec chmod 664 {} + 2>/dev/null || true
chmod -R 775 /var/www/html/bootstrap/cache 2>/dev/null || true

# Garantir arquivo de log existe e tem permissões corretas
touch /var/www/html/storage/logs/laravel.log 2>/dev/null || true
chown www-data:www-data /var/www/html/storage/logs/laravel.log 2>/dev/null || true
chmod 664 /var/www/html/storage/logs/laravel.log 2>/dev/null || true

exec "$@"
