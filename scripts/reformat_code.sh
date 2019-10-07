#!/bin/sh
cd src && ls | grep "\.[ch]" | awk -F ' ' '{ print($9) }' | xargs clang-format -i
