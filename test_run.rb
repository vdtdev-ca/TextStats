require './lib/document_processor.rb'
require 'YAML'

module TestRun
  
  BREAKPOINTS = false

  ##
  # Create new instance of DocumentProcessor with custom options
  def self.create_processor(filename)
    options = {ignore_symbols: true, case_sensitive: false}
    DocumentProcessor.new(filename, options)
  end
  
  ##
  # Execute process method in processor and show success/fail message
  # @param [DocumentProcessor] processor Instance of DocumentProcessor
  # @return [Hash|Boolean] Hash of word counts if successful, false otherwise
  def self.process(processor)
    success = processor.process()
#     puts("Dictionary created with values: #{success}")
    binding.pry if BREAKPOINTS
    if success
      return processor.dictionary()
    else
      return false
    end
  end
  
  ##
  # Load expected word count hash from YAML file
  # @param [String] filename File name of expected word count yaml
  # @return [Hash] Hash of expected word counts loaded from file
  def self.load_expectations(filename)
    source = nil
    File.open(filename) { |f| source = f.read() }
    yaml = YAML.load(source)
    return yaml
  end
  
  ##
  # Run test
  # @param [DocumentProcessor] processor Instance of document processor
  # @param [Hash] expectations Expected word count hash generated by load_expectations
  # @return [Boolean|Hash] true if all words match expectations, hash of match results otherwise
  def self.run(processor, expectations)
    dict = process(processor)

    successful = true # used to track overall success
    results = expectations.dup # dup expectations for result storage
    all_keys = true # whether same key count in expected and processed

    if dict == false
      puts "Failed to get any words"
    else
      
      expectations.keys.each do |k|
        success_included = dict.keys.include?(k)
        success_match = (dict[k] == expectations[k]) && success_included
        results[k] = success_included && success_match # store match result
        successful &= results[k] # track whether any mismatches occur
        # Show message indicating expected word not found
        unless success_included
          puts "[!] Expected word '#{k.to_s}' not included in results."
        end
        # Show message indicating match number mismatch
        unless success_match || !success_included
          puts "[!] Word '#{k.to_s}' not found expected number of times. " +
            "\n\t#{expectations[k]} vs. #{dict[k]}"
        end
      end
#       all_keys = (dict.keys.length == expectations.keys.length)
      if successful
        # Show success message
        puts "All expected words found in results with expected counts."
#         puts "Expected and found word counts " + ((!all_keys)? "not " : "") + "equal."
        return true
      else
        # Show failure message
        puts "One or more mismatches with expectations."
        results.keys.each do |k|
          puts "'#{k.to_s}' > Expected: #{expectations[k]}; Found: #{dict[k].to_i}" unless results[k]
        end
        return results
      end
    end
        
  end
    
  ##
  # Execute test using 'sample.txt' as source and 'sample_expect.yaml' as expectations
  def self.test1()
    processor = create_processor("sample.txt")
    expects = load_expectations("sample_expect.yaml")
    result = run(processor, expects)
    processor.export_dictionary("sample_generated.yaml")
    return result
  end
    
end