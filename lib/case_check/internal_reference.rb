# Models of various sorts of file references within CF code

require 'activesupport'

module CaseCheck

# base class
class InternalReference < Struct.new(:source, :text, :line)
  # abstract methods
  # - expected_path
  #   returns the exact relative path to which this reference refers
  # - resolved_to
  #   returns the absolute file to which this reference seems to point, if one could be found

  # Returns :exact, :case_insensitive, or nil depending on whether
  # the reference could be resolved on a case_sensitive FS, 
  # only on a case_insensitive FS, or not at all 
  def resolution
    return nil unless resolved_to
    case_sensitive_match? ? :exact : :case_insensitive
  end
  
  def message
    start = 
      case resolution
      when :exact
        "Exactly resolved"
      when :case_insensitive
        "Case-insensitively resolved"
      else
        "Unresolved"
      end
    msg = "#{start} #{type_name} on line #{line}"
    if resolution
      "#{msg} from #{text} to #{resolved_to}"
    else
      "#{msg}: #{text}"
    end
  end
  
  def type_name
    self.class.name.underscore.gsub('_', ' ')
  end
  
  protected
  
  def case_sensitive_match?
    resolved_to[-1 * expected_path.size, expected_path.size] == expected_path
  end
end

# Reference as cf_name (or CF_name)
class CustomTagReference < InternalReference
  attr_reader :expected_path, :resolved_to
  
  class << self
    attr_accessor :directories
    
    def search(source)
      refs = []
      char_offset = 0
      /<(CF_(\w+))/i.scan(source.content) do |md|
        refs << CustomTagReference.new(source, md[1], source.line_of(char_offset + md.begin(0)))
        char_offset += md[0].size + md.pre_match.size
        remaining = md.post_match
      end
      refs
    end
  end
  
  def initialize(source, text, line)
    super
    @expected_path = text[3, text.size] + ".cfm"
    @resolved_to = resolve
  end
  
  def type_name
    'customtag'
  end
  
  private
  
  def resolve
    [File.dirname(source.filename), self.class.directories].flatten.inject(nil) do |resolved, dir|
      resolved || resolve_in(dir)
    end
  end
  
  def resolve_in(dir)
    exact_path = File.expand_path(expected_path, dir)
    return exact_path if File.exists_exactly?(exact_path)
    File.case_insensitive_canonical_name(exact_path)
  end
end

end # module CaseCheck