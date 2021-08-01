### adapted from https://docs.aws.amazon.com/lambda/latest/dg/go-image.html

FROM golang:1.16.6-alpine3.14 AS build
ADD . .
RUN GOPATH= go build -o /main

FROM alpine:3.14 AS download-lambda-rie
RUN apk add curl
USER 1000
RUN curl \
  -Lo /tmp/aws-lambda-rie \
  https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download/1.1/aws-lambda-rie
USER 0
RUN chown 0:0 /tmp/aws-lambda-rie
RUN chmod 0555 /tmp/aws-lambda-rie

FROM alpine:3.14 AS generate-entrypoint-script
# the AWS docs don't include a reference to the handler (/main) here
# not sure why.  it is required
RUN ( \
  echo '#!/bin/sh' ; \
  echo 'if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then' ; \
  echo '  exec /usr/bin/aws-lambda-rie /main "$@"' ; \
  echo 'else' ; \
  echo '  exec /main "$@"' ; \
  echo 'fi' \
) > /tmp/entrypoint.sh
RUN chmod 0555 /tmp/entrypoint.sh

# copy artifacts to a clean image
FROM alpine:3.14
COPY --from=build /main /main
COPY --from=download-lambda-rie /tmp/aws-lambda-rie /usr/bin/aws-lambda-rie
COPY --from=generate-entrypoint-script /tmp/entrypoint.sh /entrypoint.sh
RUN mkdir /var/task /opt/extensions
USER 1000
ENTRYPOINT [ "/entrypoint.sh" ]     
