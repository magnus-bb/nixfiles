#!/bin/sh

class=$(playerctl metadata --player=spotify --format '{{lc(status)}}')
icon=""

if [[ $class == "playing" ]]; then
  info=$(playerctl metadata --player=spotify --format '{{artist}} - {{title}} ({{ duration(position) }}/{{ duration(mpris:length) }})')
  if [[ ${#info} > 80 ]]; then
    info=$(echo $info | cut -c1-80)"..."
  fi
  text=$icon" "$info
elif [[ $class == "paused" ]]; then
  info=$(playerctl metadata --player=spotify --format '{{artist}} - {{title}} ({{ duration(position) }}/{{ duration(mpris:length) }})')
  if [[ ${#info} > 80 ]]; then
    info=$(echo $info | cut -c1-80)"..."
  fi
  text=$icon" "$info
elif [[ $class == "stopped" ]]; then
  text=$icon
fi

echo -e "{\"text\":\""$text"\", \"class\":\""$class"\"}"