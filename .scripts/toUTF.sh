#!/bin/bash
file -bi $1
iconv -f CP1251 -t UTF-8 $1 -o $1.utf

