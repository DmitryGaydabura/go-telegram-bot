FROM golang:1.22 as builder
WORKDIR /go/src/app
COPY . .
# Виконуємо збірку всередині, або копіюємо готовий бінарник (залежить від підходу)
# Для цього завдання простіше скомпілювати зовні (через Makefile) і скопіювати сюди,
# АЛЕ краще multi-stage build, щоб він працював сам по собі:
RUN make build

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]
