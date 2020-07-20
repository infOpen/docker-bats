FROM node:alpine as dependencies-solver
RUN apk add --no-cache git
COPY package.json /bats/
COPY yarn.lock /bats/
WORKDIR /bats
RUN yarn install

# Minimalistic image
FROM alpine:3.7
LABEL Maintainer="Alexandre CHAUSSIER <a.chaussier@infopen.pro>"
ENV BATS_HELPERS_DIR=/opt/bats-helpers

# Bats
COPY --from=dependencies-solver /bats/node_modules/bats /opt/bats

# Bats helpers
COPY --from=dependencies-solver /bats/node_modules/bats-assert /opt/bats-helpers/bats-assert
COPY --from=dependencies-solver /bats/node_modules/bats-file /opt/bats-helpers/bats-file
COPY --from=dependencies-solver /bats/node_modules/bats-mock /opt/bats-helpers/bats-mock
COPY --from=dependencies-solver /bats/node_modules/bats-support /opt/bats-helpers/bats-support

RUN apk add --no-cache bash ncurses rsync \
  && ln -s /opt/bats/libexec/bats-core/bats /sbin/bats

WORKDIR /tests

ENTRYPOINT ["/sbin/bats"]
CMD ["-v"]
