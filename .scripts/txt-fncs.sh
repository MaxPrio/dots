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

cut_out_core () {
# gets rid of the file ($1) content, between the given pattern lines($2$3) .
    sed  "/$2/q" $1
    sed -n "/$3/,\$p" $1
}
cut_core () {
# saves the file ($1) content, between the given pattern lines($2$3) .
    sed -n "/$3/,\$p" $1 \
      | sed  "/$2/q" $1
}
injection () {
# inserts the first file content, into the second, in front of  the pattern line ($3) .
    sed -n "/$3/q;p" $2
    cat $1
    sed -n "/$3/,\$p" $2
}

