require File.expand_path(File.dirname(__FILE__) + "/..") + "/test_helper"
require 'find'
require 'tempfile'

RAILS_BASE_DIRS = ['app', 'db', 'config', 'lib', 'test'].map{|dir| Rails.root.join(dir) }

class CodeQualityTest < ActiveSupport::TestCase
  def setup
    @ruby_files = []
    RAILS_BASE_DIRS.each do |base_dir|
      Find.find(base_dir) do |path|
        @ruby_files << path if FileTest.file?(path) and path.end_with?('.rb')
      end
    end
  end

  # Does a static syntax check, but doesn't interpret the code
  def test_static_ruby_syntax
    @ruby_files.each do |ruby_file|
      IO.popen("ruby -cv #{ruby_file} 2>&1 > /dev/null | grep #{Rails.root}") do |io|
        line = io.read
        assert(false, "ruby -cv #{ruby_file} gave output\n#{line}") unless line.empty?
      end
    end
  end

  # Checks that no 'debugger' statement is present in ruby code
  def test_no_ruby_debugger_statement
    @ruby_files.each do |ruby_file|
      File.open(ruby_file).each_with_index do |line, number|
        assert(false, "#{ruby_file}:#{number + 1} 'debugger' statement found!") if line.match(/^\s*debugger/)
      end
    end
  end
end
