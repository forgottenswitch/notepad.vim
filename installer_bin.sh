#!/bin/sh

PROG="$0"

usage() {
  echo "Usage: $PROG installation_dir dest_dir src_dir"
  echo " installation dir examples: ~/.notepad.vim, ~/.vim"
  echo " dest_dir examples: ~/bin, /usr/local/bin"
  echo " src_dir should be bin/ of notepad.vim source"
}

installation_dir="$1"
dest_dir="$2"
src_dir="$3"
shift 3

test "(" ! -z "$installation_dir" ")" -a "(" ! -z "$dest_dir" ")" -a "(" ! -z "$src_dir" ")" || { usage; exit 1; }

for f in "$src_dir"/*
do
  f1="$f"
  f0=$(basename "$f")
  f2="$dest_dir/$f0"
  echo "installing $f2"
  install -m 777 "$f1" "$f2" || exit 1
  sed -i -e "s#NOTEPAD-VIM#${installation_dir}#g" "$f2"
done
