FROM node:20-bookworm-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY gopro-extract.js ./
ENV PORT=8080
ENTRYPOINT ["node","/app/gopro-extract.js"]
