#!/bin/sh

PROG="$0"
TAB="	"
echocmd() { 
  test "(" ! -z "$VERBOSE" ")" -o "(" ! -z "$DRYRUN" ")" && echo "$@"
  test -z "$DRYRUN" && "$@"
  return "$?"
}

usage() {
  echo "$PROG - Vim plugin management"
  echo " Usage: sh $PROG to update plugins"
  echo "        sh $PROG --off AUTHOR PLUGIN to disable AUTHOR's PLUGIN"
  echo "        sh $PROG --help to show this help"
  echo " VERBOSE=1 sh $PROG to show what is performed"
  echo " DRYRUN=1  sh $PROG to show what would be performed"
}

arg1="$1"
shift

mode=""
case "$arg1" in
  --off) mode=off ;;
  --help|-h) mode=help ;;
esac

test "$mode" == "help" && {
  usage
  exit 1
}

current_dir_real=$(realpath "$PWD")

script_dir=$(dirname "$0")
script_dir_real=$(realpath "$script_dir")
script_dir_base=$(basename "$script_dir_real")

script_dir_up=$(dirname "$script_dir")
script_dir_up_real=$(realpath "$script_dir_up")
script_dir_up_base=$(basename "$script_dir_up_real")

# echo "cwd: $PWD"
# echo "real cwd: $current_dir_real"
# echo "script dir: $script_dir"
# echo "real script dir: $script_dir_real"
# echo "upper real script dir: $script_dir_up_real"

check_the_dir() {
  test "$script_dir_base" != "notepad.vim" && {
    echo "This script is not in bundle/notepad.vim directory"
    exit 1
  }
  test "$script_dir_up_base" != "bundle" && {
    echo "This script is inside notepad.vim, but not bundle/notepad.vim directory"
    exit 1
  }
  test "$script_dir_up_real" != "$current_dir_real" && {
    echo "You should run this command from $script_dir_up_real (not $current_dir_real)"
    exit 1
  }
}

check_not_a_path() {
  test ! -z "$1" || return 1
  local base=$(basename "$1")
  test "$base" = "$1" || return 1
  test "$base" != "/" || return 1
  local no_colons=$(echo "$1" | sed -e "s/://g")
  test "$1" == "$no_colons" || return 1
}

test "$mode" == "off" && {
  check_the_dir
  usage="$PROG --off AUTHOR PLUGIN"
  author="$1"
  plugin="$2"
  check_not_a_path "$author" || { echo "$usage: invalid AUTHOR"; exit 1; }
  check_not_a_path "$plugin" || { echo "$usage: invalid PLUGIN"; exit 1; }
  shift 2
  plugin_dir="${script_dir_up}/$plugin"
  deps_line="[ ${TAB}]*${author}[ ${TAB}]\+$plugin[ ${TAB}]*"
  deps_file="${script_dir_real}/dependencies"
  echocmd command rm -rf "$plugin_dir"
  echocmd sed -i -e "s/^${deps_line}$/# &/g" $deps_file
  exit
}

