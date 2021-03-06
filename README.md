# Genecache

Simple and fast conversion of GENE IDs. Conversion tables are downloaded and stored in local SQLite database for very fast access.

Two sources are supported right now:
* Hyperlink management system (http://biodb.jp)
* Mouse genome informatics (http://www.informatics.jax.org)

## Installation

Add this line to your application's Gemfile:

    gem 'genecache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install genecache

If SQLite is installed in a non-default location, then:

    $ gem install sqlite3 -- \
        --with-sqlite3-include=$SQLITE3/include \
        --with-sqlite3-lib=$SQLITE3/lib
    $ gem install genecache

## Usage

    require 'genecache'

    GeneCache.convert('biodb::hsa', 'ensg_id', 'omim_id', 'ENSG00000142192') # APP 
    # returns ['104300', '104760', '605714']

    GeneCache.convert('mgi', 'mgi_accession', 'ensembl_id', '87853')
    # returns ['ENSMUSG00000027596']

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
