FROM golang:1.24 AS build

ARG VERSION=dev
ARG COMMIT=none
ARG DATE=unknown

WORKDIR /go/src/github.com/betterleaks/betterleaks
COPY . .
RUN VERSION="${VERSION:-$(git describe --tags --abbrev=0 2>/dev/null || echo dev)}" && \
CGO_ENABLED=0 go build -o bin/betterleaks \
  -ldflags "-s -w -X github.com/betterleaks/betterleaks/version.Version=${VERSION}"

FROM alpine:3.22
RUN apk add --no-cache bash git openssh-client
COPY --from=build /go/src/github.com/betterleaks/betterleaks/bin/* /usr/bin/

RUN git config --global --add safe.directory '*'

ENTRYPOINT ["betterleaks"]
