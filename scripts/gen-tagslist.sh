#!/bin/bash
blogRoot=$(realpath "$0")
blogRoot=${blogRoot%/*/*}

formatSpaces() {
    cat - | tr '[:blank:]' ' ' | tr -s ' '
}

retriveTagNames() {
    cat - | cut -d ' ' -f3 | tr ':' '\n' | sed '/^$/d'
}

cat $blogRoot/posts/*.org | sed '{
    /#+begin_src/,/#+end_src/d
    /:PROPERTIES:/,/:END/!d
    /:TAGS:/!d
    }' | formatSpaces | retriveTagNames | sort -u
