FROM node:23-alpine AS build

RUN corepack enable
RUN apk add openssl

WORKDIR /app

COPY package*.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile


COPY . .
RUN pnpm prisma generate
RUN pnpm build

FROM node:23-alpine AS runtime

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist

COPY docker ./docker
COPY prisma ./prisma

RUN chmod +x ./docker/run.sh

ENTRYPOINT ["./docker/run.sh"]