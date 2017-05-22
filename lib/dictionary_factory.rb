module DictionaryFactory
  
  BREAKPOINTS = false
  
  ##
  # Construct a Hash word dictionary from given data and options
  # @param [Hash] data Data hash containing document body and word data
  # @param [Hash] options Options hash pre processed by DocumentProcessor
  # @return [Boolean,Hash] built dictionary hash, or false if nothing found
  def self.build(data, options)
    
    use_breaks = true
    
    words = {}
    
    source = data[:document_body].dup
    
    source.downcase! unless options[:case_sensitive]
    source.gsub!(/[\$\!\@\#\%\^\&\*\(\)\,\<\>\/\\\?\;\:\'\"\.]*/,'') if options[:ignore_symbols]
    source = source.gsub(/[[:cntrl:]]*/,'').gsub('  ', ' ')
    source = source.split(" ")
    
    binding.pry if BREAKPOINTS
    
    source.each do |word|
      if word.length >= options[:minimum_word_length]
        unless words.keys.include?(word)
          words[word] = 1
        else
          words[word] = words[word] + 1
        end
      end
    end
    
    binding.pry if BREAKPOINTS
    
    # return false if no words were counted
    return false if words.length == 0
    
    # store words in data and return them
    data[:words] = words
    return words
      
  end
  
end