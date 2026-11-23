#!/bin/bash

if [ -z "$QUEUE_ADAPTER" ]; then
	echo "⚠️ QUEUE_ADAPTER is not set, defaulting to solid_queue"
fi
export QUEUE_ADAPTER="${QUEUE_ADAPTER:-solid_queue}"

if [ "$QUEUE_ADAPTER" != "solid_queue" ]; then
	echo "⚠️ Solid Queue is disabled because QUEUE_ADAPTER is not solid_queue"
fi

SOLID_QUEUE_IN_PUMA="${SOLID_QUEUE_IN_PUMA:-true}"
case "${SOLID_QUEUE_IN_PUMA,,}" in
	1|true|yes)
		if [ "$QUEUE_ADAPTER" = "solid_queue" ]; then
			echo "✅ Solid Queue is configured in Puma"
		else
			echo "⚠️ Solid Queue is not configured in Puma"
		fi
		;;
	*) echo "⚠️ Solid Queue is not configured in Puma" ;;
esac

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
