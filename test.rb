#!/usr/bin/env ruby

require File.dirname(__FILE__)+"/Graf Zahl.rb"

class Foo
  def bar
    puts "bar called"
  end
end

f = Foo.new
f.bar

#puts f.method(:bar).source_location
#puts Foo.inspect

