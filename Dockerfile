FROM mikefarah/yq:3 AS builder

RUN apk add git bash

WORKDIR /src

COPY . .

RUN mkdir -p repos/ && ./scripts/gitpkg.sh

FROM ghcr.io/joshrwolf/minigit/minigit:0.0.1

COPY --from=builder /src/repos/ .

EXPOSE 9696

ENTRYPOINT [ "/usr/local/bin/minigit" ]
