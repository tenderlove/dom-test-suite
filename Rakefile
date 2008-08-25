$LOAD_PATH << File.join(File.expand_path('~aaron'), 'git', 'nokogiri', 'lib')

require 'nokogiri'
require 'open-uri'

BASE = File.expand_path(File.dirname(__FILE__))
BUILD_DIR = File.join(BASE, "build")
TRANSFORMS_DIR = File.join(BASE, "transforms")
SPECS_DIR = File.join(BASE, 'lib', 'specs')
TEST_DIR = File.join(BASE, 'tests')
RUBY_DIR = File.join(BUILD_DIR, 'ruby')

FileUtils.mkdir_p(RUBY_DIR)
FileUtils.mkdir_p(SPECS_DIR)
FileUtils.mkdir_p(File.join(TEST_DIR, 'level1', 'core'))
FileUtils.mkdir_p(File.join(TEST_DIR, 'level1', 'html'))

DOM_ZIP = File.join(SPECS_DIR, 'DOM.zip')

#dom1-check-spec:
#
#get-dom1:
#    [mkdir] Created dir: /Users/aaron/git/DOM-Test-Suite/lib/specs/Level-1
#      [get] Getting: http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/DOM.zip
#      [get] To: /Users/aaron/git/DOM-Test-Suite/lib/specs/DOM.zip
file DOM_ZIP do
  open("http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/DOM.zip") do |f|
    File.open(File.join(SPECS_DIR, 'DOM.zip'), 'wb') { |dest|
      dest.write f.read
    }
  end
end
task :get_dom1 => DOM_ZIP

#dom1-init:
#    [unzip] Expanding: /Users/aaron/git/DOM-Test-Suite/lib/specs/DOM.zip into /Users/aaron/git/DOM-Test-Suite/lib/specs/Level-1
#    [unzip] Expanding: /Users/aaron/git/DOM-Test-Suite/lib/specs/Level-1/xml-source.zip into /Users/aaron/git/DOM-Test-Suite/lib/specs/Level-1
#
task :dom1_init => [:get_dom1] do
  chdir(SPECS_DIR)
  FileUtils.rm_rf("Level-1")
  sh("unzip DOM.zip -d Level-1")
  sh("unzip Level-1/xml-source.zip -d Level-1")
  wd_dom = File.read(File.join(SPECS_DIR, 'Level-1', 'xml', 'wd-dom.xml'))
  File.open(File.join(SPECS_DIR, 'Level-1', 'xml', 'wd-dom.xml'), 'wb') { |f|
    f.write wd_dom.gsub(/<spec>/, "<spec xmlns:xlink='http://www.w3.org/1999/xlink'>")
  }
end

#dom1-interfaces-init:
#
#dom1-interfaces-gen:
#
#dom1-interfaces-copy:
#     [copy] Copying 1 file to /Users/aaron/git/DOM-Test-Suite/build
task :dom_interfaces_copy => [:dom1_init] do
  dom1_int = File.join(BASE, 'patches' ,'dom1-interfaces.xml')
  cp(dom1_int, BUILD_DIR)
end

#dom1-interfaces:
task :dom1_interfaces => [:dom_interfaces_copy]

#dom1-dtd:
#    [style] Warning: the task name <style> is deprecated. Use <xslt> instead.
#    [style] Processing /Users/aaron/git/DOM-Test-Suite/build/dom1-interfaces.xml to /Users/aaron/git/DOM-Test-Suite/build/dom1.dtd
#    [style] Loading stylesheet /Users/aaron/git/DOM-Test-Suite/transforms/dom-to-dtd.xsl
#     [copy] Copying 1 file to /Users/aaron/git/DOM-Test-Suite/tests/level1/core
#     [copy] Copying 1 file to /Users/aaron/git/DOM-Test-Suite/tests/level1/html
task :dom1_dtd => :dom1_interfaces do
  doc = Nokogiri::XML.parse(
    File.read(File.join(BUILD_DIR, 'dom1-interfaces.xml'))
  )
  xslt = Nokogiri::XSLT.parse(
    File.read(File.join(TRANSFORMS_DIR, 'dom-to-dtd.xsl'))
  )
  dom1_dtd = File.join(BUILD_DIR, 'dom1.dtd')
  File.open(dom1_dtd, 'wb') do |f|
    f.write(
      xslt.apply_to(doc,
        [
          'schema-namespace', '"http://www.w3.org/2001/DOM-Test-Suite/Level-1"',
          'schema-location', '"dom1.xsd"'
        ]
      )
    )
  end
  cp(dom1_dtd, File.join(TEST_DIR, 'level1', 'core'))
  cp(dom1_dtd, File.join(TEST_DIR, 'level1', 'html'))
end

#
#dom1-core-gen-java:
task :dom1_schema => [:dom_interfaces_gen] do
  xsd_file = File.join(BUILD_DIR, 'dom1.xsd')
  doc = Nokogiri::XML.parse(
    File.read(File.join(BUILD_DIR, 'dom1-interfaces.xml'))
  )
  xslt = Nokogiri::XSLT.parse(
    File.read(File.join(TRANSFORMS_DIR, 'dom-to-xsd.xsl'))
  )
  File.open(xsd_file, 'wb') { |f|
    xsd = xslt.apply_to(doc)
    xsd.gsub!(/_xmlns/, 'xmlns')
    xsd.gsub!(/xmlns_test/, 'xmlns:test')
    f.write(xsd)
  }
  cp(xsd_file, File.join(TEST_DIR, 'level1', 'core'))
  cp(xsd_file, File.join(TEST_DIR, 'level1', 'html'))
end

task :to_ruby => :dom1_dtd do
  xslt = Nokogiri::XSLT.parse(
    File.read(File.join(TRANSFORMS_DIR, 'test-to-ruby.xsl'))
  )
  chdir(File.join(TEST_DIR, 'level1', 'core'))
  Dir['**/*.xml'].each do |f|
    doc = Nokogiri::XML.parse(File.read(f))
    filename = File.basename(f, '.xml')
    File.open(File.join(RUBY_DIR, "test_#{filename}.rb"), 'wb') do |test_file|
      test_file.write(
        xslt.apply_to(doc,
          ['interfaces-docname', "'#{File.join(BUILD_DIR, 'dom1-interfaces.xml')}'"]
        )
      )
    end
  end
end

task :test_ruby => :to_ruby do
  chdir(BASE)
  all = File.join(RUBY_DIR, 'test_alltests.rb')
  ruby("-I ruby:#{RUBY_DIR} #{all}")
end

task :default => [:to_ruby]
