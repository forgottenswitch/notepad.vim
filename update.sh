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
  echo
}

nargs="$#"
arg1="$1"

mode=""
case "$arg1" in
  --off) mode=off ;;
  --help|-h) mode=help ;;
esac

test _"$mode" = _"help" && {
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

check_the_dir() {
  test _"$script_dir_base" != _"notepad.vim" && {
    echo "This script is not in bundle/notepad.vim directory"
    exit 1
  }
  test _"$script_dir_up_base" != _"bundle" && {
    echo "This script is inside notepad.vim, but not bundle/notepad.vim directory"
    exit 1
  }
  test _"$script_dir_up_real" != _"$current_dir_real" && {
    echo "You should run this command from $script_dir_up_real (not $current_dir_real)"
    exit 1
  }
}

check_not_a_path() {
  test ! -z "$1" || return 1
  local base=$(basename "$1")
  test _"$base" = _"$1" || return 1
  test _"$base" != _"/" || return 1
  local no_colons=$(echo "$1" | sed -e "s/://g")
  test _"$1" = _"$no_colons" || return 1
}

test _"$mode" = _"off" && {
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

strip_spaces() {
  l="$1"
  l1="${l#[ ]}"
  while test "$l" != "$l1"; do l="$l1"; l1="${l#[ ]}"; done
  l1="${l%[ ]}"
  while test "$l" != "$l1"; do l="$l1"; l1="${l%[ ]}"; done
  echo "$l"
}

update_git() {
  local url="$1"
  local repo="$2"
  shift 2
  echo "Updating $repo (git, $url) ..."
  if test -d "$repo"
  then
    echo " cd $repo && git pull --rebase"
    cd "$repo"
    git pull --rebase || {
      echo " Error pulling updates from $url ! $PROG: aborted." > /dev/stderr
      exit 1
    }
    cd - > /dev/null
  else 
    echo " git clone $url"
    git clone "$url" || {
      echo " Error cloning from $url ! $PROG: aborted." > /dev/stderr
      exit 1
    }
  fi
  echo
}

test _"$mode" = _"" && {
  test "$nargs" -ne "0" && { usage; exit 1; }
  check_the_dir
  site="github"
  deps_file="notepad.vim/dependencies"
  deps_file_real=$(realpath "$deps_file")
  lineno=0
  echo "Updating Vim plugins in $current_dir_real..."
  echo " Using plugin list $current_dir_real/$deps_file"
  echo
  test -e "$deps_file" || { echo "$PROG: fatal error: $deps_file does not exist!"; exit 1; }

  cat "$deps_file" |
  while read -r REPLY ; do
    line=$(strip_spaces "$REPLY")
    lineno=$((lineno+1))
    case "$line" in
      "[github]") site="github";;
      "["*) echo "$deps_file:$lineno: fatal error: unknown site $line" > /dev/stderr; exit 1;;
      "#"*|"") ;;
      *)
        author="${line%% *}"
        plugin="${line##* }"
        case "$site" in
          github) update_git "https://github.com/${author}/${plugin}.git" "${plugin}" ;;
          *) echo "$deps_file:$lineno: fatal error: unknown site $site" > /dev/stderr; exit 1;;
        esac
        ;;
    esac
  done

  echo "Done updating Vim plugins in $current_dir_real"
}

