#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

cd $1

ls | sed 's/.*\.//' | sort | uniq -c
find . -name '*.tsv'  | xargs md5sum | sort
find . -name '*.json'  | xargs md5sum | sort
find . -name '*.h5'  | xargs md5sum | sort