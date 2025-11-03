FROM node:20-bookworm-slim
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev
COPY gopro-extract.js ./
ENTRYPOINT ["node","/app/gopro-extract.js"]
