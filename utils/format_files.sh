#!/bin/sh

# Remove trailing spaces
sed -i '' 's/[[:blank:]]*$$//' "$@"
