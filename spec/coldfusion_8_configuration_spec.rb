require 'fileutils'
require File.join(File.dirname(__FILE__), %w[spec_helper])

describe CaseCheck::Coldfusion8Configuration do
  before do
    @cf_root = "/tmp/cf_case_check/"
    
    neo_runtime = {
      :filename => "/tmp/cf_case_check/lib/neo-runtime.xml",
      :contents =>
      "<wddxPacket version='1.0'>        
        <data>
          <struct type='coldfusion.server.ConfigMap'>
            <var name='/WEB-INF/customtags1207698058868'><string>/tmp/cf_case_check/customtags</string></var>
            <var name='/WEB-INF/customtags1207758745211'><string>/tmp/cf_case_check/cfcs</string></var>
            <var name='/WEB-INF/customtags1207773084805'><string>/tmp/cf_case_check/misc</string></var>
          </struct>
        </data>
      </wddxPacket>"
    }
     
    create_file(neo_runtime[:filename], neo_runtime[:contents]) 
  end
  
  after do
    if File.exist?(@cf_root)
      FileUtils.rm_rf @cf_root
    end
  end
  
  def create_file(filename, contents)
    touch(filename)
    File.open(filename, 'w') { |f| f.write contents }
  end
  
  def touch(filename)
    FileUtils.mkdir_p File.dirname(filename)
    File.open(filename, 'w')
  end
  
  def build_config
    CaseCheck::Coldfusion8Configuration.new(@cf_root)
  end
  
  it "should read customtag directories from neo-runtime.xml" do
    touch('/tmp/cf_case_check/customtags/foo.cfm')
    touch('/tmp/cf_case_check/misc/bar.cfm')
    
    build_config
    
    CaseCheck::CustomTag.directories.should == %w(/tmp/cf_case_check/customtags /tmp/cf_case_check/misc)    
  end
  
  it "should read cfc directories from neo-runtime.xml" do
    touch('/tmp/cf_case_check/cfcs/bar.cfc')
    touch('/tmp/cf_case_check/misc/foo.cfc')
    
    build_config
    
    CaseCheck::CustomTag.directories.should == %w(/tmp/cf_case_check/cfcs /tmp/cf_case_check/customtags)
  end
  
end