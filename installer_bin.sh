#!/bin/sh

PROG="$0"

usage() {
  echo "Usage: $PROG installation_dir binaries_dir binary_file..."
  echo " installation dir examples: ~/.notepad.vim, ~/.vim"
  echo " binaries dir examples: ~/bin, /usr/local/bin"
  echo " binary_file should be one from bin/ of notepad.vim source"
}

installation_dir="$1"
binaries_dir="$2"
shift 2

test "(" ! -z "$installation_dir" ")" -a "(" ! -z "$binaries_dir" ")" || { usage; exit 1; }

for f
do
  f=$(basename "$f")
  echo "installing $binaries_dir/$f"
  install -m 777 "$f" "$binaries_dir"
  sed -i -e "s/NOTEPAD-VIM/${installation_dir}/g" "$binaries_dir"/"$f"
done
