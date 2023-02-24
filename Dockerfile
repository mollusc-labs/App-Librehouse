FROM rakudo-star:2022.12
COPY . .
EXPOSE 8080
RUN apt-get update
RUN apt-get install openssl libssl-dev libpq-dev postgresql-client -y
RUN zef install --deps-only --timeout=999999999 .
RUN bin/librehouse migrate up
CMD ["bin/librehouse", "start"]
