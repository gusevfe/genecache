require "genecache/version"
require 'open-uri'
require 'zipruby'
require 'csv'
require 'tempfile'
require 'sqlite3'
require 'logger'
require 'fileutils'

$log = Logger.new STDERR

# TODO: check we have working sqlite3 executable for fast import of data

class GeneCache
  def self.db_path
    FileUtils.mkdir_p ENV['HOME'] + "/.genecache"
    return ENV['HOME'] + "/.genecache/db.sqlite3"
  end

  @@db = SQLite3::Database.new GeneCache.db_path
  @@tables = @@db.execute("SELECT name FROM sqlite_master where type = 'table'")

  def self.convert(species, from, to, id)
    table = "#{species}_#{from}_#{to}"
    unless @@tables.include?([table])
      # TODO: Update table sometimes!
      self.download!(species, from, to)
    end

    r = @@db.execute "select #{to} from #{table} where #{from} = '#{id}'"
    r.flatten
  end

  def self.download!(species, from, to)
    table = "#{species}_#{from}_#{to}"
    $log.info "Downloading table: #{table}"
    @@db.execute "drop table if exists #{table}"
    @@db.execute "drop index if exists from_index"
    @@db.execute "drop index if exists to_index"

    url = "http://biodb.jp/tmp/#{table}.zip"
    zip_data = open(url).read

    Zip::Archive.open_buffer(zip_data) do |ar|
      ar.fopen(0) do |f|
        tmp = Tempfile.new 'biodb'
        data = f.read.split("\n")
        header = data.first.split
        throw "Invalid header!" if header.sort != [from, to].sort
        @@db.execute "create table #{table} (#{header.first} VARCHAR(255), #{header.last} VARCHAR(255))"

        rest = data[1..-5] * "\n"
        tmp.write rest
        tmp.close

        system(%$echo -e ".mode tabs \\n.import #{File.expand_path(tmp.path)} #{table}" | sqlite3 #{self.db_path}$)
        @@db.execute "create index from_index on #{table} (#{header.first})"
        @@db.execute "create index to_index on #{table} (#{header.last})"
      end

      # Update local list of tables
      @@tables = @@db.execute("SELECT name FROM sqlite_master where type = 'table' and name = '#{table}'")
    end
  end
end
