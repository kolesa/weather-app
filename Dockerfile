# Use an official Ruby runtime as a parent image
FROM ruby:3.1.0

# Set the working directory in the container
WORKDIR /app

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY $RAILS_MASTER_KEY

ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE $SECRET_KEY_BASE

ARG WEATHER_API_KEY
ENV WEATHER_API_KEY $WEATHER_API_KEY

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
