# container-com-laravel

Configuração mínima para executar uma aplicação Laravel usando Docker Compose.

Resumo das alterações importantes

- Código da aplicação: em `./src` (o Compose monta `./src` em `/var/www/html`).
- `docker/php/entrypoint.sh`: reforçado para criar diretórios e corrigir permissões (evita erros "Permission denied" ao gravar em `storage` e `bootstrap/cache`).
- Projeto Laravel pode ser criado dentro de `./src` usando Composer (ex.: `composer create-project`).

Arquivos principais criados/alterados

- `docker-compose.yml` — orquestra `app` (PHP-FPM), `web` (NGINX) e `db` (MySQL).
- `docker/php/Dockerfile` — imagem PHP com extensões e Composer.
- `docker/php/entrypoint.sh` — entrypoint que garante permissões em startup.
- `docker/nginx/default.conf` — configuração Nginx para Laravel.
- `.env.example` — variáveis de ambiente de exemplo.

Requisitos

- Docker e Docker Compose (Compose V2 / `docker compose` recomendado).

Uso (passos recomendados)

1) Subir containers (constrói imagens):

```bash
docker compose up -d --build
```

2) (Opcional) Criar projeto Laravel em `./src` — execute apenas se `./src` estiver vazio:

```bash
# cria o projeto diretamente no bind mount (use --entrypoint "" para evitar que o entrypoint crie arquivos antes)
docker compose run --rm --entrypoint "" app \
	composer create-project laravel/laravel . "^10.0" --prefer-dist --no-interaction
```

3) Copiar e ajustar `.env` (em `./src`):

```bash
cp .env.example src/.env
# edite src/.env para confirmar DB_HOST=db e outras chaves
docker compose run --rm app php artisan key:generate
```

4) Rodar migrations:

```bash
docker compose run --rm app php artisan migrate
```

5) Acesse a aplicação:

- Abra `http://localhost:8000` (Nginx expõe a porta `8000` no host).

Problemas comuns e correções aplicadas

- Erro: "Project directory ... is not empty" ao rodar `composer create-project` — causa: o diretório alvo do bind mount continha arquivos (por exemplo `bootstrap`/`storage`). Solução: garantir que `./src` esteja vazio antes ou criar o projeto em um diretório temporário e mover os arquivos.
- Erro: "Permission denied" ao escrever em `storage/logs/laravel.log` ou `storage/framework/views/*` — solução aplicada: o `entrypoint` foi atualizado para criar os diretórios necessários, garantir o arquivo de log e aplicar `chown/chmod` (para `www-data`) com tolerância a erros.

Comandos úteis para corrigir permissões manualmente

```bash
# ajustar dono e permissões (executar se houver problemas de escrita)
docker compose run --rm app sh -c "chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap || true && \
	find /var/www/html/storage -type d -exec chmod 775 {} + && \
	find /var/www/html/storage -type f -exec chmod 664 {} + && \
	chmod -R 775 /var/www/html/bootstrap/cache || true"
```

Se o `entrypoint` for alterado (já foi), reconstrua a imagem `app` e recrie o container:

```bash
docker compose build app
docker compose up -d --no-deps --force-recreate app
```

Notas finais

- O repositório foi configurado para desenvolvimento local. Em produção recomenda-se ajustar usuários, permissões e variáveis de ambiente (ex.: não expor `3306` publicamente e usar senhas seguras).
- Se quiser, eu posso:
	- rodar as migrations aqui,
	- adicionar `phpmyadmin`/`adminer` para facilitar acesso ao banco,
	- ou mover o projeto do `./src` para a raiz do repositório (atenção: isso altera a estrutura do repo).

Se preferir, eu acrescento um atalho `Makefile` ou uma entrada no `README` com um comando `fix-perms` automatizado.

---

Atualizações realizadas no repositório durante esta sessão:

- Gerei o projeto Laravel em `./src` (via Composer) e corrigi permissões.
- Atualizei `docker/php/entrypoint.sh` para garantir permissões na inicialização.

Qualquer dúvida ou se quer que eu rode as migrations agora, diga "rode migrations".