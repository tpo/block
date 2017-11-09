#!/bin/bash
#
# functionality, and variables shared by the
# `block` and `article` executables
#
# see the `block` executable for more info
#
# (c) licensed under the GPLv2 license by Tomáš Pospíšek
#

check_config_or_fail() {
    [ -n "$block_home" ]   || missing_fail "block_home"
    [ -n "$block_dst" ]    || missing_fail "block_dst"
    [ -n "$block_url" ]    || missing_fail "block_url"
}

log() {
    echo "$1" >&2
}

fail() {
    echo "$1" >&2
    exit -1
}

configure_paths() {
    # init block data paths
    articles_src_dir=$block_home/input/articles
    templates_dir=$block_home/input/templates
    bits_dir=$block_home/input/bits
    article_signature=$templates_dir/signature.html
    output_dir=$block_home/output
    articles_html=$output_dir/html
    articles_atom=$output_dir/atom
    # the following three must reside directly under $output_dir
    # see "rsync" below
    articles_all_html=$output_dir/index.html
    articles_feed_atom=$output_dir/index.xml
    block_bits=$output_dir/bits
    browser=${browser:-firefox}
    PATH="$block_home/bin:$PATH"
}

cat_template() {
    echo "cat << EOT"
    cat "$templates_dir/$1"
    echo EOT
}

# build_from_template template VAR_NAME1 VAR_NAME2 ...
#
build_from_template() {
  cat_template2_sub() {
      local template="$1"; shift
      local var_content=
      
      for var_name in "$@"; do
          # construct here something like this:
          #
          #     BODY=$(cat <<'EOVARIABLE'
          #     here comes the
          #     content of BODY
          #     EOVARIABLE
          #     )
          #
          echo "$var_name=\$(cat <<'EOVARIABLE'"
          var_content="${!var_name}"
          echo "$var_content"
          echo "EOVARIABLE"
          echo ")"
      done
      cat_template "$template"
  }

  cat_template2_sub "$@" | bash
}

# see http://feedvalidator.org/docs/error/InvalidRFC3339Date.html
# fix broken format delivered by `date --rfc3339=seconds` ("date")
#                         and by `stat --format %z`       ("stat")
time_to_rfc3339(){
    # 1. replace first space with a 'T'   (date and stat)
    # 2. throw away fractions of a second (stat)
    # 3. offset is missing a collon       (stat)
    sed 's/ /T/;
         s/\.[0-9]* //;
         s/\([+-]\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1\2:\3/;'
}
