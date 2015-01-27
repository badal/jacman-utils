#!/usr/bin/env ruby
# encoding: utf-8

# File: mail.rb, created 31/12/14
#
# (c) Michel Demazure

module JacintheManagement
  module Utils
    # delivery method
    ::Mail.defaults do
      delivery_method :smtp, address: Conf.mail_mode[:server]
    end

    # Methods for e-subscriptions notification
    class SmfMail < ::Mail::Message
      MAIL_MODE = Conf.mail_mode
      MAIL_MODE[:from] = Core::Defaults.defaults[:from]

      # @param [String] message content of mail
      # @param [Array<String>] dest destination addresses
      # @param [String] subject subject of mail
      def initialize(dest, subject, content)
        super()
        add_content(content)
        self.to = Array(dest).join(',')
        self.from = MAIL_MODE[:from]
        self.subject = subject
      end

      # @param [String] content content in utf-8
      def add_content(content)
        part = ::Mail::Part.new
        part.content_type = 'text/plain; charset=UTF-8'
        part.body = content
        add_part part
      end

      # send the mail
      def send
        deliver!
      end

      # useless, for compatibility
      def demo
        to_s
      end
    end
  end
end

