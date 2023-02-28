FROM rakudo-star:2022.12
COPY . .
EXPOSE 8080
RUN apt-get update
RUN apt-get install openssl libssl-dev libpq-dev postgresql-client -y
RUN zef install --force-install --timeout=60000 --fetch-degree=1 .
CMD ["bin/librehouse", "start"]
