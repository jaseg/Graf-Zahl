#!/usr/bin/env ruby

class BasicObject
  attr_reader :ethic     # good   [1:0] evil
  attr_reader :moral     # lawful [1:0] chaotic

  attr_reader :tau       #
  attr_reader :i         #
 
  attr_reader :agility   #        [1:0]
  attr_reader :strength  #        [1:0]
  attr_reader :stamina   #        [1:0]
  attr_reader :expertise #        [1:0]

  def self.process_call(inst, method, name, character, *args, &block)
    return unless @@armed
    @@armed = false
    puts "processing call: #{method} as #{name} on #{inst} which is a #{self} with #{character || "no character"} given #{args.size > 0?args:"no args"} and #{block || "no block"}"
    @@armed = true
  end

  def self.process_method(method, name)
    puts "procsessing method #{method} as #{name}" if @@armed
  end
  
  def self.infect_method(name)
    @@armed = false if @@armed
    begin
      new_method = self.instance_method(name.to_sym)
    rescue NameError
      puts "\t\t[!] cannot infect #{name}"
      @@armed = true if not @@armed.nil?
      return
    end
    character = process_method(new_method, name)
    handler = self.method(:process_call)
    define_method name do |*args, &block|
      handler.call(self, new_method, name, character, *args, &block)
      new_method.bind(self).call(*args, &block)
    end
    @@armed = true if not @@armed.nil?
  end
  
  def self.initialize_character
    #FIXME
  end

  def self.infect_all!
    self.instance_methods.each do |m|
      unless m == :call or m == :!
        #puts "\t-infecting #{m}"
        infect_method(m)
      end
    end
    self.initialize_character
  end

  def self.armed
    @@armed
  end

  class_variable_set(:@@armed, nil)

  def self.arm!
    class_variable_set(:@@armed, true)
  end

  def self.disarm!
    class_variable_set(:@@armed, nil)
  end

  def self.method_added(name)
    infect_method(name) if @@armed
  end
end

Method.infect_all!

#infect global objects
Module.constants.each do |c|
  unless c == :Method or c == :UnboundMethod
    #puts "+infecting #{c}"
    c = Module.const_get(c)
    c.infect_all! if c.is_a? Class
  end
end

puts "Graf Zahl resurrected."
Object.arm!
