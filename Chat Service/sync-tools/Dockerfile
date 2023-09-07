# SPDX-FileCopyrightText: 2023 eclipse foundation
# SPDX-License-Identifier: EPL-2.0

FROM node:current AS builder

WORKDIR /app
COPY . .

ENV NODE_ENV=development

RUN npm ci --only=prod --prefer-offline --progress=false --no-audit \
    && npm install --only=dev --prefer-offline --progress=false --no-audit \
    && npm run build \
    && npm prune production

FROM node:current

WORKDIR /app

COPY --from=builder /app/config /app/config
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/node_modules /app/node_modules
 
ENV NODE_ENV=production 

CMD [ "node", "./dist/index.js" ]