FROM golang:1.19-alpine as build

RUN apk add --no-cache \
    git \
    make

WORKDIR /src

COPY Makefile ./
# go.mod and go.sum if exists
COPY go.* ./
COPY cmd/ ./cmd
COPY web ./web

ARG BUILD_VERSION=unknown

ENV GODEBUG="netdns=go http2server=0"

RUN make build BUILD_VERSION=${BUILD_VERSION}

FROM alpine:3.18.3
LABEL org.opencontainers.image.source https://github.com/Aparavi-Operations/subspace
LABEL org.opencontainers.image.description="Subspace - A simple WireGuard VPN server GUI"
LABEL org.opencontainers.image.licenses=MIT

COPY --from=build  /src/subspace /usr/bin/subspace
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY bin/my_init /sbin/my_init

ENV DEBIAN_FRONTEND noninteractive

RUN chmod +x /usr/bin/subspace /usr/local/bin/entrypoint.sh /sbin/my_init

RUN apk add --no-cache \
    iproute2 \
    iptables \
    ip6tables \
    dnsmasq \
    socat  \
    wireguard-tools \
    runit

ENTRYPOINT ["/usr/local/bin/entrypoint.sh" ]

CMD [ "/sbin/my_init" ]
