require 'rubygems'
require 'bundler'

Bundler.setup(:default)

require 'mail'
require 'enumerable'

class Mbox
  include Enumerable

  DEFAULT_SEPARATOR = /^From [^\s]+@[^\s]+ .{24}$/

  attr_accessor :io, :messages

  def initialize(io)
    self.io = io

    parse
  end

  def size
    messages.size
  end

  def each(*args, &block)
    messages.each(*args, &block)
  end

  private

  def parse
    self.messages = []

    io.rewind
    lines = io.readlines.freeze

    current_message = nil

    lines.each_with_index do |line, index|
      next unless index.zero? || lines[index - 1] == $/

      if line =~ DEFAULT_SEPARATOR
        self.messages = messages.concat Mail.new(current_message.chomp) if current_message
        current_message = ""
      else
        current_message << line
      end
    end
  end
end
