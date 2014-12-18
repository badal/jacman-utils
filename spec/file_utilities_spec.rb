#!/usr/bin/env ruby
# encoding: utf-8

# File: file_utilities_spec.rb
# Created: 13/08/13
#
# (c) Michel Demazure <michel@demazure.com>

require_relative 'spec_helper.rb'
require_relative '../lib/jacman/utils/file_utilities.rb'

include JacintheManagement::Core

describe Utils do

  it 'should extract with a simple regexp' do
    in_file = File.join(File.dirname(__FILE__),
                        'test_files', 'Articles.csv')
    out_file = File.join(File.dirname(__FILE__),
                         'test_files', 'Articles_extracted.csv')
    produced_file = File.join(File.dirname(__FILE__),
                              'test_files', 'Articles_extracted_prod.csv')
    regexp = /^(K|N)/
    Utils.extract_lines(in_file, produced_file, regexp)
    FileUtils.compare_file(produced_file, out_file).must_equal true
    # File.delete(produced_file)
  end

  it 'should extract with a block' do
    in_file = File.join(File.dirname(__FILE__),
                        'test_files', 'Stock.csv')
    out_file = File.join(File.dirname(__FILE__),
                         'test_files', 'Stock-NV.csv')
    produced_file = File.join(File.dirname(__FILE__),
                              'test_files', 'Stock-nv-prod.csv')
    regexp = /^(?<item>N\w*)\t+(?<qty>\d*).*/
    Utils.extract_lines(in_file, produced_file, regexp) do |mtch|
      "#{mtch[:item]}\t#{mtch[:qty]}"
    end
    FileUtils.compare_file(produced_file, out_file).must_equal true
    # File.delete(produced_file)
  end
end
