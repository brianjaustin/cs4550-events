#!/bin/bash

# This script was based on the one from hw06
export SECRET_KEY_BASE=insecure
export MIX_ENV=prod
export PORT=4796
export NODEBIN=`pwd`/assets/node_modules/.bin
export PATH="$PATH:$NODEBIN"

# Setup secret config file.
# From lecture notes
# https://github.com/NatTuck/scratch-2021-01/blob/master/4550/0212/hangman/deploy.sh
CFGD=$(readlink -f $HOME/.config/events)

if [ ! -d "$CFGD" ]; then
    mkdir -p "$CFGD"
fi

DATABASE_URL=$(cat "$CFGD/postgres")
export DATABASE_URL

echo "Building..."

mix local.hex --force
mix local.rebar --force
mix deps.get
mix compile

if [ ! -e "$CFGD/base" ]; then
    mix phx.gen.secret > "$CFGD/base"
fi

SECRET_KEY_BASE=$(cat "$CFGD/base")
export SECRET_KEY_BASE

(cd assets && npm install)
(cd assets && webpack --mode production)
mix phx.digest

echo "Generating release..."
mix release --force --overwrite

echo "Migrating database..."
mix ecto.migrate
