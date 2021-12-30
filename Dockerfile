FROM paritytech/ci-linux:staging AS builder
ARG PROFILE=release
WORKDIR /imbue
ADD . .
RUN cargo build --${PROFILE}
RUN cp target/${PROFILE}/imbue-collator /


FROM parity/polkadot:v0.9.13 AS polkadot
FROM parity/subkey:latest AS subkey
# to copy polkadot binaries only; no other directives required


FROM node:16
ARG APT_PACKAGES
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y\
        gnupg2 ca-certificates\
        ${APT_PACKAGES}

RUN yarn global add polkadot-launch

COPY --from=builder /imbue-collator /
COPY --from=polkadot /usr/bin/polkadot /
COPY --from=subkey /usr/local/bin/subkey /

EXPOSE 30330-30345 9933-9960 8080 3001