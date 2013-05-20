## block: the static blog creation software

_block_ is an integrated script for blog creation. It offers:

* writing articles in
  [Markdown](http://daringfireball.net/projects/markdown/)
  in vim
* generation of
  * html
  * atom feed 
* synchronization with the web server
* display of the generated web page

block doesn't do much itself but relies on other tools to do
most of its work. It depends on:

### dependencies

* vim
* rsync
* Markup.pl
* a browser

### installation (under Debian)

    apt-get install rsync vim markdown
    git clone https://github.com/tpo/block.git
    cd block
    mkdir ~/.block && cp config ~/.block/config
    vim ~/.block/config  # configure to match your
                         # local context

now you can write your first article:

    bin/block

### usage

    article new                     # Write a new article
    article to html "article"       # Output article in html form
                                    # to stdout.
    article to atom "article.html"  # Output html in atom form
                                    # to stdout.
    block                           # Edit new article and generate
                                    # blog and preview.
    block home                      # Show block's home directory
                                    # use as: cd "`block home`".
    block publish                   # Publish blog.
    block rebuild                   # Rebuild blog from articles.

### configuration

    ~/.block/config                 # Configuration file. Needs to
                                    # set the following variables:
    block_home=/home/joe/block      - Path to block directory
    block_dst=srv.example.org:website/
                                    # Rsync style destination, where
                                    # the generated site will be
                                    # rsynced to.
    block_url=http://www.example.org/
                                    # Site URL
                                    # rsynced to.

### directory layout
    block/input/articles            # your articles
    block/input/bits                # stuff (images etc.) that you can
                                    # refer to from youryour articles
    block/input/parts               # parts from which the html pages
                                    # and the atom feed will be
                                    # assembled. You'll want to edit
                                    # these.

project home: https://github.com/tpo/block

