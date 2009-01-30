require 'pathname'
require "rexml/document"

module CaseCheck

class Coldfusion8Configuration
  PATH, CONFIG_FILENAME = 'lib', 'neo-runtime.xml'
  
  def initialize(cf_root)
    @cf_root = cf_root
    absolute_filename = File.join(@cf_root, PATH, CONFIG_FILENAME)
    config = File.new(absolute_filename)
    @doc = REXML::Document.new(config)
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
      (Dir["#{d}/**/*.cfm"] + Dir["#{d}/**/*.tem"]).empty?
    end
  end
  
  def cfc_directories
    absolutize_directories(read_all_dirs).reject do |d|
      Dir["#{d}/**/*.cfc"].empty?
    end
  end
  
  def all_dirs
    @doc.elements.collect("//var[contains(@name,'customtag')]/string") { |e| e.text }
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