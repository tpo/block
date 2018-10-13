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
    articles_raw_html=$output_dir/html
    articles_html=$output_dir/articles
    articles_atom=$output_dir/atom
    # the following three must reside directly under $output_dir
    # see "rsync" below
    articles_one_page_html=$output_dir/one_page.html
    articles_landing_page_html=$output_dir/index.shtml
    articles_feed_atom=$output_dir/index.xml
    toc_articles_one_page_html=$output_dir/toc_one_page.html
    toc_html=$output_dir/toc.html
    block_bits=$output_dir/bits
    browser=${browser:-firefox}
    PATH="$block_home/bin:$PATH"
}

cat_template() {
    echo "cat << EOT"
    cat "$templates_dir/$1"
    echo EOT
}

cat_html_toc() {
    # TOC will be included server-side via
    # https://github.com/tpo/SSI-AJAX
    #
    echo '<ssi-ajax>include virtual="toc.html"</ssi-ajax>'
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

# build_from_template TITLE BODY TOC
#
build_html_page() {
  BLOCK_URL="$block_url"
  build_from_template "page.html" TITLE BODY TOC
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

# update_if_necessary command input_file output_file additional_dependency
#
# will do:
#
#   command input_file > output_file
#
# if 'output_file':
# * doesn't exist or
# * is older than 'input_file' or
# * is older than 'additional_dependency'
#
# returns true if updated
#
update_if_necessary() {
    if [ "$3" -ot "$2" -o \
	 "$3" -ot "$4"    ]; then
        log "rebuilding $3"
        "$1" "$2" > "$3"
        true
    else
        # log "skipped $3"
        false
    fi
}
