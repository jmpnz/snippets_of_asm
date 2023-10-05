#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Compile assembly code."
    echo "Usage: $0 file.asm -o file"
    exit 1
fi

filename=$(basename -- "$1")
filename="${filename%.*}"

nasm -f elf64 "$1"
ld -o "$filename" "$filename".o

echo "Done..."
exit 0
