require "genecache/version"
require 'open-uri'
require 'zipruby'
require 'csv'
require 'tempfile'
require 'sqlite3'
require 'logger'
require 'open-uri'
require 'fileutils'

$log = Logger.new STDERR

# TODO: check we have working sqlite3 executable for fast import of data

class GeneCache
  def self.db_path
    FileUtils.mkdir_p ENV['HOME'] + "/.genecache"
    return ENV['HOME'] + "/.genecache/db.sqlite3"
  end

  class Mgi
    def self.download(db, from, to, io)
      map = { 'mgi_accession' => 0, 'mgi_symbol' => 2, 'mgi_name' => 3, 'ensembl_id' => 10 }
      # ID does no matter in this case
      io.puts [from, to] * "\t"
      open('ftp://ftp.informatics.jax.org/pub/reports/MGI_Gene_Model_Coord.rpt').each_line do |line|
        s = line.split("\t")
        next if s.first == "1. MGI accession id"

        f = s[map[from]]
        f = f[4..-1] if from == 'mgi_accession'

        t = s[map[to]]
        t = t[4..-1] if to == 'mgi_accession'

        io.puts [f, t] * "\t"
      end
    end
  end

  class Biodb
    def self.download(db, from, to, io)
      file = "#{db}_#{from}_#{to}"
      url = "http://biodb.jp/tmp/#{file}.zip"
      $log.info "Downloading #{url}..."
      zip_data = open(url).read

      Zip::Archive.open_buffer(zip_data) do |ar|
        ar.fopen(0) do |f|
          data = f.read.split("\n")[0..-5] * "\n"
          CSV.new(data, :headers => true, :col_sep => "\t").each do |r|
            io.puts r[from] + "\t" + r[to]
          end
       end
      end
    end
  end

  @@db = SQLite3::Database.new GeneCache.db_path
  @@tables = @@db.execute("SELECT name FROM sqlite_master where type = 'table'")

  def self.convert(db, from, to, id)
    provider, db = db.split(":")
    provider.capitalize!
    db ||= "default"

    table = "#{provider}_#{db}_#{from}_#{to}"

    unless @@tables.include?([table])
      # TODO: Update table sometimes!
      self.download!(provider, db, from, to)
    end

    r = @@db.execute "select #{to} from \"#{table}\" where #{from} = '#{id}'"
    r.flatten
  end

  def self.download!(provider, db, from, to)
    table = "#{provider}_#{db}_#{from}_#{to}"
    $log.info "Downloading table: #{table}"
    @@db.execute "drop table if exists \"#{table}\""
    @@db.execute "drop index if exists from_index"
    @@db.execute "drop index if exists to_index"

    @@db.execute "create table \"#{table}\" (#{from} VARCHAR(255), #{to} VARCHAR(255))"

    tmp = Tempfile.new 'genecache'
    Object.const_get("GeneCache").const_get(provider).download(db, from, to, tmp)
    tmp.close

    IO.popen("sqlite3 #{self.db_path}", 'w') do |io|
      io.puts ".mode tabs"
      io.puts ".import #{File.expand_path(tmp.path)} \"#{table}\""
      io.close_write
    end

    @@db.execute "create index from_index on \"#{table}\" (#{from})"
    @@db.execute "create index to_index on \"#{table}\" (#{to})"

    # Update local list of tables
    @@tables = @@db.execute("SELECT name FROM sqlite_master where type = 'table' and name = '#{table}'")
  end
end
