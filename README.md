# container-com-laravel

Este repositório contém uma configuração mínima para executar uma aplicação Laravel usando Docker e Docker Compose.

Arquivos adicionados/alterados:

- `docker-compose.yml` : orquestra os serviços `app` (PHP-FPM), `web` (NGINX) e `db` (MySQL).
- `docker/php/Dockerfile` : imagem PHP-FPM personalizada com extensões e Composer.
- `docker/php/entrypoint.sh` : ajusta permissões e inicia o processo.
- `docker/nginx/default.conf` : configuração do Nginx para servir Laravel.
- `.env.example` : exemplo de variáveis de ambiente para desenvolvimento.

Como usar (passos rápidos):

1. Construir e subir os containers:

```bash
docker compose up -d --build
```

2. Criar um novo projeto Laravel (executar apenas uma vez):

```bash
docker compose run --rm app composer create-project laravel/laravel . "^10.0" --prefer-dist --no-interaction
```

3. Ajustar variáveis de ambiente: copie `.env.example` para `.env` e atualize DB_HOST para `db`.

```bash
cp .env.example .env
# editar .env e ajustar DB_* se necessário
docker compose run --rm app php artisan key:generate
```

4. Rodar migrations (opcional):

```bash
docker compose run --rm app php artisan migrate
```

5. Acesse a aplicação em `http://localhost:8000`.

Observações:
- O MySQL expõe a porta `3306` apenas para desenvolvimento local.
- Volumes montam o código no container para desenvolvimento (hot-reload de arquivos PHP).

Se quiser que eu gere o projeto Laravel automaticamente aqui no repositório, diga que eu executo os comandos necessários.