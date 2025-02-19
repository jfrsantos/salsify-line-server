FROM ruby:3.3.7
RUN apt-get update -qq && apt-get install -y nodejs
RUN mkdir /line-server
WORKDIR /line-server
COPY Gemfile /line-server/Gemfile
COPY Gemfile.lock /line-server/Gemfile.lock
RUN bundle install
COPY . /line-server
# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]