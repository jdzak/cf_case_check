require 'pathname'
require "rexml/document"

module CaseCheck

class Coldfusion8Configuration
  PATH, FILENAME = 'lib', 'neo-runtime.xml'
  
  def initialize(cf_root)
    @cf_root = cf_root
    absolute_filename = File.join(@cf_root, PATH, FILENAME)
    f = File.new(absolute_filename)
    @doc = REXML::Document.new(f)
    apply
  end
  
  private
  
  def apply
    read_custom_tag_dirs
    read_cfc_dirs
  end
  
  def read_custom_tag_dirs
    CustomTag.directories = absolutize_directories(custom_tag_directories || [])
  end
  
  def read_cfc_dirs
    Cfc.directories = absolutize_directories(cfc_directories || [])
  end
  

  
  private
  def custom_tag_directories
    absolutize_directories(read_all_dirs).reject do |d|
      Dir["#{d}/**/*.cfm"].empty?
    end
  end
  
  def cfc_directories
    absolutize_directories(read_all_dirs).reject do |d|
      Dir["#{d}/**/*.cfc"].empty?
    end
  end
  
  def read_all_dirs
    custom_elements = []
    @doc.elements.each("//var") { |elt| custom_elements << elt if elt.attributes["name"] =~ /customtags/ }
    custom_elements.inject([]){ |dirs, c| dirs << c.elements["string/child::text()"].to_s }
  end
  
  def absolutize_directories(dirs)
    dirs.to_a.collect { |d|
      p = Pathname.new(d)
      if p.absolute?
        p
      else
        Pathname.new(File.dirname(@filename)) + p
      end
    }.collect { |p| p.to_s }
  end
end

end