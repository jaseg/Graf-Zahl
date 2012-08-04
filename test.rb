#!/usr/bin/env ruby

require File.dirname(__FILE__)+"/Graf Zahl.rb"

class Foo
  def bar
    puts "bar called"
  end
end

puts "class Foo defined"

f = Foo.new

puts "Foo instantiated"

f.bar

for i in 0..10
  puts "forloop: #{i}"
end

foo = 10
10 + 2

puts 1.ethic

