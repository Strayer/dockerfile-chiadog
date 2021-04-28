#!/usr/bin/env bash
set -eo pipefail

pushd /tmp >>/dev/null

cp /chiadog/config-example.yaml config.yaml

if [[ -n "${PING_URL}" ]]; then
  yq e '.keep_alive_monitor.enable_remote_ping = true' -i config.yaml
  yq e ".keep_alive_monitor.ping_url = \"${PING_URL}\"" -i config.yaml
fi

if [[ -n "${DAILY_STATS_TIME_OF_DAY}" ]]; then
  yq e ".daily_stats.time_of_day = ${DAILY_STATS_TIME_OF_DAY}" -i config.yaml
fi

if [[ -n "${NOTIFIER_TELEGRAM_BOT_TOKEN}" ]]; then
  yq e '.notifier.telegram.enable = true' -i config.yaml
  yq e ".notifier.telegram.credentials.bot_token = \"${NOTIFIER_TELEGRAM_BOT_TOKEN}\"" -i config.yaml
  yq e ".notifier.telegram.credentials.chat_id = \"${NOTIFIER_TELEGRAM_CHAT_ID}\"" -i config.yaml
fi

popd >>/dev/null

exec "$@"
