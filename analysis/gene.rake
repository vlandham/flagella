require 'zlib'
require 'open-uri' 

namespace 'gene' do
  
  desc 'Returns total number of Genes in database'
  task :total do
    puts Gene.all.size
  end

  desc 'Loads the protein sequences into the databases'
  task :load => :clear do
    file_name = "protein.fasta.gz"
    file_gz = File.join(File.expand_path('../../data/', __FILE__), file_name)
    puts "Loading Gene File: #{file_gz}"
    Zlib::GzipReader.open(file_gz) do |file|
      Bio::FlatFile.auto(file).each {|entry| Gene.create_from_flatfile entry }
    end
  end
  
  desc 'Deletes all sequences from Database. Flat files are left untouched'
  task :clear do
    Gene.delete_all
  end
  
end