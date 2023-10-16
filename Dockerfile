# Use an official Ruby runtime as a parent image
FROM ruby:3.1.0

# Set the working directory in the container
WORKDIR /app

ENV RAILS_ENV production

RUN apt-get update && apt-get install -y nodejs yarn

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./


# Copy the rest of the application code into the container
COPY . .

# Install dependencies
RUN bundle install

RUN bundle exec rails assets:precompile

# Expose port 3000 to the host
EXPOSE 3000

# Start the Rails application
CMD ["rails", "server", "-b", "0.0.0.0"]
