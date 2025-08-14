FROM node:22-alpine
WORKDIR /app
COPY package.json package-lock.json* pnpm-lock.yaml* ./
RUN npm i --omit=dev || true
COPY src ./src
EXPOSE 8080
CMD ["node","src/index.js"]
