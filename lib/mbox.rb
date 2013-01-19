require 'rubygems'
require 'bundler'

Bundler.setup(:default)

require 'mail'

class Mbox
  include Enumerable

  DEFAULT_SEPARATOR = /^From [^\s]+@[^\s]+ .{24}$/

  attr_accessor :io, :messages, :path

  def initialize(path_or_messages)
    if path_or_messages.is_a? Array
      self.messages = path_or_messages
    else
      self.path = File.expand_path(path_or_messages)
      self.io = File.open(path, 'r+:ASCII-8BIT')
      read
    end
  end

  def write(path)
    File.open(path, 'w+') do |f|
      f.write map { |m| "From #{m.raw_envelope}\r\n#{m.raw_source}" }.join("\r\n" * 2)
    end
  end

  def size
    messages.size
  end

  def each(*args, &block)
    messages.each(*args, &block)
  end

  private

  def read
    return if io.nil?

    self.messages = []

    io.rewind

    self.messages = io.slice_before(empty: true) do |line, state|
      previous_line_empty = state[:empty]
      state[:empty] = line.chomp.empty?
      previous_line_empty && line.start_with?("From ")
    end.map do |mail|
      mail.pop if mail.last.chomp.empty?
      Mail.new(mail.join(""))
    end
  end
end
