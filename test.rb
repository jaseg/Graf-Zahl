#!/usr/bin/env ruby

require File.dirname(__FILE__)+"/Graf Zahl.rb"

puts "character of 1:"
puts 1.character
i = 0
puts "character of i:"
puts i.character
100.times do
  i = i + 1
end
puts "character of 1:"
puts 1.character
puts "character of i:"
puts i.character
