# lambda-experiments

## shared Dockerfile

The top-level Dockerfile should be enough for most use-cases. Amazon's
suggested use of an Amazon Linux 2 base image is skipped in favour of
Alpine as the former results in a 300MB+ "hello world" image, vs. 22MB
for Alpine.

## local testing

### start the handler

```
$ docker run -it --rm -p 9000:8080 lambda-hi-m8
```

### submit a request

```
curl \
  -XPOST \
  -d '{"name":"glorp"}' \
  http://localhost:9000/2015-03-31/functions/function/invocations \
  ; echo
{"Message":"glorp! hi m8"}
```
