#!/usr/bin/env ruby

#require "flog"

def doTehArithmancy (something)
  ary = something.to_s.downcase.gsub(/[^a-z0-9]/,'').bytes.map do |c|
    case c
    when '0'.ord..'9'.ord then c-'0'.ord
    when 'a'.ord..'i'.ord then c-'a'.ord+1
    when 'j'.ord..'r'.ord then c-'j'.ord+1
    when 's'.ord..'z'.ord then c-'s'.ord+1
    end
  end
  if ary.size > 1
    return doTehArithmancy ary.reduce :+
  else
    return ary[0]
  end
end

module Moral
  LAWFUL = 1
  NEUTRAL = 0.5
  CHAOTIC = 0
end

module Ethic
  GOOD = 1
  NEUTRAL = 0.5
  EVIL = 0
end

class BasicObject
  TRAITS = [:ethic, :moral, :tau, :i, :agility, :strength, :stamina, :expertise]
  attr_reader *TRAITS

  def character= (hash, *params)
    params.each_with_index{|i, e| instance_variable_set(TRAITS[i], e || instance_variable_get(TRAITS[i]))}
    hash.each_pair{|k, v| instance_variable_set(k, v) if TRAITS.include? k}
  end

  def self.process_call(inst, method, name, character, *args, &block)
    return unless @@armed
    @@armed = false
    #puts "processing call: #{method} as #{name} on #{inst} which is a #{self} with #{character || "no character"} given #{args.size > 0?args:"no args"} and #{block || "no block"}"
    file, line = method.source_location
    if file
        #score = 2/(1+@files[file].totals["#{method.owner}##{method.name}"])-1;
    end
    @@armed = true
  end

  def self.process_method(method, name)
    puts "procsessing method #{method} as #{name}" if @@armed
    file, line = method.source_location
    return unless file
    @files = ::Hash.new unless @files
    if @files.has_key? file
        #flogger = @files[file] 
    else
        #flogger = ::Flog.new
        #@files[file] =  flogger
        #flogger.flog file
    end
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

0..9.each{|n| n.character = :tau => Math::PI, :i => 0, :ethic => Ethic::NEUTRAL }
0.character = :moral => Moral::CHAOTIC
1.character = :moral => Moral::LAWFUL
2.character = :moral => Moral::NEUTRAL
3.character = :moral => Moral::LAWFUL,  :ethic => Ethic::GOOD
4.character = :moral => Moral::LAWFUL
5.character = :moral => Moral::CHAOTIC, :ethic => Ethic::GOOD
6.character = :moral => Moral::LAWFUL,  :ethic => Ethic::GOOD
7.character = :moral => Moral::NEUTRAL, :ethic => Ethic::GOOD
8.character = :moral => Moral::LAWFUL
9.character = :moral => Moral::LAWFUL

puts "Graf Zahl resurrected."
#Object.arm!
