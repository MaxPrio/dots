fout-hash (){
# end the line in front of "#"
# remove empty lines and trailing spaces

  [ -z $1 ]\
    && src='-'\
    || src="$1"
sed -e 's/#.*$//;/^\s*$/d;s/\s\+$//' $src
}

# one WORD per line
fout-hash $1 | sed 's/\s\+/\n/g' -
