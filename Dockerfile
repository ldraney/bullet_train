# Stage 1: Node.js
FROM node:bookworm as node

# Stage 2: PostgreSQL
FROM postgres:bookworm as postgres

# Stage 3: Ruby with Node.js and PostgreSQL
FROM ruby:bookworm

# Copy Node.js and Yarn from the node image
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /opt/yarn-* /opt/yarn
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn && \
    ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg

# Copy PostgreSQL binaries and libraries
COPY --from=postgres /usr/lib/postgresql /usr/lib/postgresql
COPY --from=postgres /usr/share/postgresql /usr/share/postgresql
COPY --from=postgres /usr/lib/postgresql/16/bin/postgres /usr/bin/postgres

# Install system dependencies
RUN apt-get update && apt-get install -y \
    graphviz \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# https://stackoverflow.com/questions/73125779/how-to-upgrade-the-version-of-yarn-on-nodelatest-docker-image
RUN yarn set version stable

# Set up the working directory
WORKDIR /app

# Copy application files
COPY . /app

# Update Ruby and Bundler
RUN gem update --system && \
    gem update bundler

# Install dependencies
RUN bundle update --bundler && bundle install

# Verify Node.js and Yarn installations
RUN node --version && \
    yarn --version

# Verify PostgreSQL installation
RUN postgres --version

# Set the entrypoint
ENTRYPOINT ["/bin/bash", "-c"]

# Default command (can be overridden at runtime)
CMD ["bin/setup"]
