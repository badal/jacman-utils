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

      # @param [String] message message of mail
      # @param [Array<String>] dest destination addresses
      # @param [String] subject subject of mail
      def initialize(dest, subject, message)
        super()
        add_content(message)
        self.to = Array(dest).join(',')
        self.from = MAIL_MODE[:from]
        self.subject = subject
      end

      # @param [String] message content message in utf-8
      def add_content(message)
        part = ::Mail::Part.new
        part.content_type = 'text/plain; charset=UTF-8'
        part.body = message
        add_part part
      end

      # send the mail
      def send
        deliver!
      end

      # for compatibility
      def demo
        to_s
      end
    end
  end
end
