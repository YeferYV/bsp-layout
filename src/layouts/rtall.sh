#!/usr/bin/env bash

source "$ROOT/utils/common.sh";
source "$ROOT/utils/layout.sh";
source "$ROOT/utils/config.sh";

master_size=$TALL_RATIO;

node_filter="!hidden";

execute_layout() {
  while [[ ! "$#" == 0 ]]; do
    case "$1" in
      --master-size) master_size="$2"; shift; ;;
      *) echo "$x" ;;
    esac;
    shift;
  done;



  # # ID=$(bspc query -N -n)
  # RECEPTACLEID=$(bspc query -N -n .leaf.\!window)
  # # [ -z "$RECID" ] && exit 1
  # if [ -n "$RECEPTACLEID" ]; then
  #   notify-send "$RECEPTACLEID"
  #   bspc subscribe node_add | while read line
  #   do
  #     # bspc node $(echo "$line" | awk '{print $5}') -t fullscreen
  #     # bspc node $ID -n $(bspc query -N -n .leaf.\!window)
  #     # bspc node $(echo "$line" | awk '{print $5}') -n $(bspc query -N -n .leaf.\!window)
  #     bspc node $(echo "$line" | awk '{print $5}') -n $(bspc query -N -n .leaf.\!window) && break;
  #   done
  # else
  # fi

    # ensure the count of the master child is 1, or make it so
    local nodes=$(bspc query -N '@/2' -n .descendant_of.window.$node_filter);
    local win_count=$(echo "$nodes" | wc -l);

    if [ $win_count -ne 1 ]; then
      local new_node=$(bspc query -N '@/2' -n last.descendant_of.window.$node_filter | head -n 1);

      if [ -z "$new_node" ]; then
        new_node=$(bspc query -N '@/1' -n last.descendant_of.window.$node_filter | head -n 1);
      fi

      local root=$(echo "$nodes" | head -n 1);

      # move everything into 2 that is not our new_node
      for wid in $(bspc query -N '@/2' -n .descendant_of.window.$node_filter | grep -v $root); do
        bspc node "$wid" -n '@/1';
      done

      bspc node "$root" -n '@/2';
    fi

    rotate '@/' vertical 90;
    rotate '@/2' horizontal 90;

    local stack_node=$(bspc query -N '@/1' -n);
    for parent in $(bspc query -N '@/1' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
      rotate $parent horizontal 90;
    done

    auto_balance '@/1';

    local mon_width=$(jget width "$(bspc query -T -m)");

    local want=$(echo "$master_size * $mon_width" | bc | sed 's/\..*//');
    local have=$(jget width "$(bspc query -T -n '@/2')");

    bspc node '@/2' --resize left $((have - want)) 0;

    # I'm adding this line based on the default bspwm
    # bspc node -{f,s} {west,south,north,east}
    bspc node -s east
}

cmd=$1; shift;
case "$cmd" in
  run) execute_layout "$@" ;;
  *) ;;
esac;
