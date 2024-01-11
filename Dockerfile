FROM ruby:3.3-alpine

RUN apk update && apk add --no-cache git

ADD 'https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h' skipcache

RUN gem install synvert

ENTRYPOINT ["synvert-ruby"]
