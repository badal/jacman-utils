#!/usr/bin/env ruby
# encoding: utf-8
#
# subscription_spec.rb

# (c) Kenji Lefevre & Michel Demazure

require_relative 'spec_helper.rb'
require_relative '../lib/jacman/core/components/electronic/octet_range.rb'
require_relative '../lib/jacman/core/components/electronic/ip_range.rb'
require_relative '../lib/jacman/core/components/electronic/subscription.rb'

include Electronic

describe Subscription do

  DEFAULT_TIERS = '1'
  # some default value
  DEFAULT_YEAR = '2000'
  # some default value
  DEFAULT_REVUE = 'AS'
  # some default value
  DEFAULT_RANGE_LIST = "1.2.3.\\n1.2.4.\\n \t\\n1.*.*\\ntoto\\n\#test"
  # some default value
  DEFAULT_BONUS = '04-01'

  it 'find the valid ranges' do
    valid = ["1\tAS\t1\t1\t2\t2\t3\t3\t0\t255\t2000-01-01\t2001-04-01",
             "1\tAS\t1\t1\t2\t2\t4\t4\t0\t255\t2000-01-01\t2001-04-01"]
    sub = Subscription.new(DEFAULT_TIERS, DEFAULT_REVUE, DEFAULT_YEAR,
                           DEFAULT_RANGE_LIST, DEFAULT_BONUS)
    sub.valid_ranges.must_equal valid
  end

  it 'find the invalid ranges' do
    # WARNING: do not replace %W with %w (\t *are* TABS)
    non_valid = %W(1\t1.*.* 1\ttoto)
    sub = Electronic::Subscription.new(DEFAULT_TIERS, DEFAULT_REVUE,
                                       DEFAULT_YEAR, DEFAULT_RANGE_LIST, DEFAULT_BONUS)
    sub.invalid_ranges.must_equal non_valid
  end

end
