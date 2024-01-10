FROM ruby:3.3-alpine

RUN apk update && apk add --no-cache git

RUN gem install synvert

ENTRYPOINT ["synvert-ruby"]
