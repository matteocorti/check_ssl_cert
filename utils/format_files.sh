#!/bin/sh

# Remove trailing spaces (see https://unix.stackexchange.com/questions/92895/how-can-i-achieve-portability-with-sed-i-in-place-editing)
case $(sed --help 2>&1) in
    *GNU*)
        sed -i'' 's/[[:blank:]]*$//' "$@"
        ;;
    *)
        sed -i '' 's/[[:blank:]]*$//' "$@"
        ;;
esac

