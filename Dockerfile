FROM ruby:3.4.8

WORKDIR /app

COPY Gemfile ./
COPY Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 4567

CMD ["ruby", "app.rb", "-o", "0.0.0.0"]