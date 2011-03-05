class Gene < ActiveRecord::Base
  validates_format_of :sequence, :with => /^ATG[ATGC\n]+(TAG|TAA|TGA)$/im, :on => :create
  
  # entry is a Bio::FlatFile from bio-ruby
  def self.create_from_flatfile(entry)
    gene = Gene.new
    gene.name = entry.definition.split(/\s+/).first
    gene.sequence = entry.data

    if gene.valid?
      gene.save!
    else
      puts "#{gene.name} does not contain a valid sequence "
      # Could raise an error here instead
      # Or even better write to an error log
    end
  end
  
  def self.mean_length
    Gene.all.map{|gene| gene.sequence.length}.to_statarray.mean
  end

  def self.sd_length
    Gene.all.map{|gene| gene.sequence.length}.to_statarray.stddev
  end

  def self.bin_sequence_length(n_bins)
    lengths = Gene.all.map{|gene| gene.sequence.length}
    min = lengths.min
    max = lengths.max
    bin_size = (max - min) / n_bins

    frequencies = Hash.new
    n_bins.times do |i|
      frequencies.store(Range.new(i*bin_size + min, i*bin_size + bin_size + min, true) , 0)
    end

    lengths.each do |length|
      frequencies.each_key { |range| frequencies[range] += 1 if range.include? length }
    end

    frequencies
    
  end  
end