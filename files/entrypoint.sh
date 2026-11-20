#!/bin/bash

if [ "$QUEUE_ADAPTER" != "solid_queue" ]; then
	echo "⚠️ Solid Queue is disabled because QUEUE_ADAPTER is not solid_queue"
fi

if [ -z "$SOLID_QUEUE_IN_PUMA" ]; then
	echo "⚠️ Solid Queue is not configured in Puma"
else
	echo "✅ Solid Queue is configured in Puma"
fi

# Puma's configured PID file is under tmp/pids, which is removed during image cleanup.
mkdir -p tmp/pids

# Check all the gems are installed or fails.
bundle check
if [ $? -ne 0 ]; then
	echo "❌ Gems in Gemfile are not installed, aborting..."
	exit 1
else
	echo "✅ Gems in Gemfile are installed"
fi

# Check no migrations are pending migrations
if [ -z "$SKIP_MIGRATIONS" ]; then
	bundle exec rails db:migrate || exit 1
	echo "✅ Migrations are all up"
	bundle exec rails data:migrate || exit 1
	echo "✅ Data migrations are all up"
else
	echo "⚠️ Skipping migrations"
fi

echo "🚀 $@"
exec "$@"
