#imagem rep:versão
FROM node:20.18 AS base

RUN npm i -g pnpm

FROM base AS dependencies

# Criando um workspace do nosso app
WORKDIR /usr/src/app

# o `./` referencia o WORKDIR
COPY package.json pnpm-lock.yaml ./

RUN pnpm install

FROM base AS build

WORKDIR /usr/src/app

# copiar tudo da raiz do projeto para a raíz do WORKDIR
COPY . .
# Copia a node modules gerada no passo de install (dependencies)
COPY --from=dependencies /usr/src/app/node_modules ./node_modules

RUN pnpm build
# descarta as devDependencies
RUN pnpm prune --prod 

# Nós precisamos usar o path completo se não for do dockerhub
FROM gcr.io/distroless/nodejs20-debian12 AS deploy

USER 1000

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json

# Cria uma variável de ambiente dentro do container
ENV CLOUDFLARE_ACCESS_KEY_ID="#"
ENV CLOUDFLARE_SECRET_ACCESS_KEY="#"
ENV CLOUDFLARE_BUCKET="#"
ENV CLOUDFLARE_ACCOUNT_ID="#"
ENV CLOUDFLARE_PUBLIC_URL="http://localhost"


EXPOSE 3333

# Comando que vai segurar a execução do container
CMD ["dist/server.mjs"]