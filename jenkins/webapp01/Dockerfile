FROM node:14.0.0-alpine as build

WORKDIR /app

COPY package*.json /app/

RUN npm ci --prefer-offline --no-audit

COPY ./ /app/

RUN npm run build

FROM nginx:1.17.10-alpine

COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /app/nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080

ENTRYPOINT [ "nginx", "-g", "daemon off;" ]
