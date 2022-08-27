FROM vaultwarden/server:1.25.2-alpine

ADD start-heroku.sh /start-heroku.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/bin/sh", "/start-heroku.sh"]
