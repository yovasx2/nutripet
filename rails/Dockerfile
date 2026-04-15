FROM ruby:4.0.1-alpine

# Install dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    git \
    yaml-dev \
    curl

WORKDIR /app

# Copy Gemfile
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start Rails server
CMD ["sh", "-c", "rm -f /app/tmp/pids/server.pid && rails server -b 0.0.0.0"]
