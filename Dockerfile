ARG BUILDER_IMAGE=golang:1.24
ARG RUNTIME_IMAGE=alpine:3.22
FROM ${BUILDER_IMAGE} AS build

ARG VERSION=dev
ARG COMMIT=none
ARG DATE=unknown

WORKDIR /go/src/github.com/betterleaks/betterleaks
COPY . .
RUN VERSION="${VERSION:-$(git describe --tags --abbrev=0 2>/dev/null || echo dev)}" && \
CGO_ENABLED=0 go build -o bin/betterleaks \
  -ldflags "-s -w -X github.com/betterleaks/betterleaks/version.Version=${VERSION}"

FROM ${RUNTIME_IMAGE}
RUN apk add --no-cache bash git openssh-client
COPY --from=build /go/src/github.com/betterleaks/betterleaks/bin/* /usr/bin/

RUN git config --global --add safe.directory '*'

ENTRYPOINT ["betterleaks"]
