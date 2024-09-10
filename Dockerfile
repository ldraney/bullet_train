# Stage 1: Node.js
FROM node:bookworm as node

# Stage 2: Ruby with Node.js
FROM ruby:bookworm

# Copy Node.js and Yarn from the node image
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/include/node /usr/local/include/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /opt/yarn-* /opt/yarn
COPY --from=node /usr/local/bin/yarn /usr/local/bin/yarn

# Install system dependencies
RUN apt-get update && apt-get install -y \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

# Set up the working directory
WORKDIR /app

# Copy application files
COPY . /app

# Update Ruby and Bundler
RUN gem update --system && \
    gem update bundler

# Install dependencies
RUN bundle update --bundler && bundle install

# Set the entrypoint
ENTRYPOINT ["/bin/bash", "-c"]

# Default command (can be overridden at runtime)
CMD ["bin/setup"]
