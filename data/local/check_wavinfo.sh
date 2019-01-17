#!/usr/bin/env bash
cat $1 | while read line;do
  sox --i "$line"
done
