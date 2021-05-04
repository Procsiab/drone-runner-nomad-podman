# Build the sources
FROM golang:1.14.15 AS golang-builder

WORKDIR /go/src
COPY . .

RUN sh scripts/build.sh

# Get the certificates
FROM alpine:3.6.5 AS alpine-certs
RUN apk add -U --no-cache ca-certificates

# Create the container
FROM alpine:3.6.5
LABEL maintainer "Lorenzo Prosseda <lerokamut@gmail.com>"

EXPOSE 3000

ENV GODEBUG netdns=go

COPY --from=alpine-certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
LABEL com.centurylinklabs.watchtower.stop-signal="SIGINT"

COPY --from=golang-builder /go/src/release/linux/amd64/drone-runner-nomad-podman /bin/

ENTRYPOINT ["/bin/drone-runner-nomad-podman"]
