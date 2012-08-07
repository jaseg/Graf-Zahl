#!/usr/bin/env ruby

require File.dirname(__FILE__)+"/Graf Zahl.rb"

puts 1.character
i = 0
puts i.character
1000.times do
  i = i + 1
end
puts 1.character
puts i.character
=begin
class Foo
  def bar
    puts "bar called"
  end
end

f = Foo.new
f.bar
=end

#puts f.method(:bar).source_location
#puts Foo.inspect

