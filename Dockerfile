FROM ruby:3.3-alpine

RUN gem install synvert

ENTRYPOINT ["synvert-ruby"]
