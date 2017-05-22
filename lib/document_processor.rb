require './lib/dictionary_factory.rb'

class DocumentProcessor
  
#   BREAKPOINTS = true
  
  attr_accessor :data, :settings
  
  @settings = {
    filename: '',
    options: {}
  }
  
  @data = {
    document_body: [],
    words: nil
  }
  

  
  ##
  # Class constructor
  # @param [String] document_filename Filename of document to process
  # @param [Hash] options Optional option overrides
  # @see parse_options
  def initialize(document_filename, options = {})
    parsed_options = parse_options(options)
    # initialize @settings and @data
    @settings = {
      filename: document_filename,
      options: parse_options(options)
    }
    @data = {
      document_body: '',
      words: nil
    }
    File.open(@settings[:filename])  { |f| @data[:document_body] = f.read() }
  end
  
  ##
  # Process document and construct dictionary
  # @return [Boolean] true if any words are found, false otherwise
  # @note Constructed dictionary is also stored in @data[:word_data]
  def process()
    
    dict = DictionaryFactory::build(@data, @settings[:options])
    
    unless dict == false
      @data[:words] = dict
      return true
    else
      return false
    end
    
  end
  
  ##
  # Public method for accessing collected word dictionary
  # @return [Hash] generated word count dictionary (from @data[:words])
  def dictionary()
    return @data[:words]
  end
  
  ##
  # Export generated wordcount dictionary to a YAML file
  # @param [String] filename Filename to write to
  def export_dictionary(filename)
    unless @data[:words].nil?
      File.open(filename, 'w') { |f| f.write(@data[:words].to_yaml) }
    end
  end
  
  private
  
    ##
  # Parse optional option params, applying defaults where not defined
  # @param [Hash] custom_options Hash of option overrides
  # @option custom_options :case_sensitive Whether case is respected, default true
  # @option custom_options :ignore_symbols Whether special chars (punctuation, etc) are ignored, default false
  # @option custom_options :minimum_word_length Minimum letter count for dictionary words, default 2
  # @return [Hash] options hash with default values added for excluded options
  def parse_options(custom_options)
    options = {}
    options[:case_sensitive] = custom_options.fetch(:case_sensitive, true)
    options[:ignore_symbols] = custom_options.fetch(:ignore_symbols, false)
    options[:minimum_word_length] = custom_options.fetch(:minimum_word_length, 2)
    return options
  end
  
end