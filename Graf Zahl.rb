#!/usr/bin/env ruby

#require "flog"

=begin
TODO:
-method/symbol characters which are non-static
=end

class Character
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

  TRAITS = ["ethic","moral","tau","i","agility","strength","stamina","expertise"]
  attr_accessor :traits
  attr_accessor :traits_delta

  def initialize(traits = Array.new(TRAITS.size, 0), traits_delta = Array.new(TRAITS.size, 0))
    @traits = traits.to_a
    @traits_delta = traits_delta.to_a
  end

  def self.generate(something)
    num = doTehArithmancy(something)
    #puts "got a number: #{num} chr #{num.instance_variable_get(:@character)}"
    ch = num.character
    return ch.clone if ch
    return Character.new
  end

  def acc(chr, factor)
    return Character.new(@traits_delta) unless chr
    Character.new(@traits_delta) + (chr - self) * factor
  end

  #that stuff is still kinda indirect.
  def acc!(chr, factor)
    @traits_delta = acc(chr, factor).traits
  end

  def step()
    nc = self + Character.new(@traits_delta)
    #FIXME Constants ahead!
    nc.traits_delta = (Character.new(@traits_delta) * 0.1).traits
    nc.cap
  end

  def step!()
    nc = step
    @traits = nc.traits
    @traits_delta = nc.traits_delta
  end

  def -(c)
    Character.new @traits.zip(c.traits).map{|a| a[0]-a[1]}
  end

  def +(c)
    Character.new @traits.zip(c.traits).map{|a| a[0]+a[1]}
  end

  def *(s)
    Character.new @traits.map{|t| t*s}
  end
  
  def /(s)
    Character.new @traits.map{|t| t/s}
  end

  def length
    return Math::sqrt(@traits.inject(0){|a,e|a+e*e})
  end

  #returns a character
  def cap
    Character.new @traits.map! do |v|
      if v < 0
        0
      elsif v > 1
        1
      else
        v
      end
    end
  end

  def traits= (*params)
    @traits = params.zip(@traits).map{|a| a[0] || a[1]}
  end

  def to_s
    TRAITS.zip(@traits).map{|a| a[0]+": "+a[1].to_s }.join ","
  end

  def self.doTehArithmancy (something)
    #puts "dta called: #{something.class}"
    data = something.to_s.downcase.gsub(/[^a-z0-9]/,'')
    return 0 unless data.length > 0
    ary = data.chars.map do |c|
      case c
      when '0'..'9' then c.ord-'0'.ord
      when 'a'..'i' then c.ord-'a'.ord+1
      when 'j'..'r' then c.ord-'j'.ord+1
      when 's'..'z' then c.ord-'s'.ord+1
      end
    end
    if ary.size > 1
      return doTehArithmancy ary.reduce :+
    else
      #puts "returning #{ary[0]} (a #{ary[0].class})"
      #puts "chr: #{ary[0].instance_variable_get(:@character)}"
      return ary[0]
    end
  end
end

class BasicObject
  def character= (*params)
    @character = ::Character.new unless @character
    @character.traits = *(params[0])
    #puts "set character for #{self.to_s} to #{@character} according to #{params[0]}"
  end
end

#                              ethic ,                    moral ,    tau    , i,agility,strength,stamina,expertise
0.character=Character::Ethic::NEUTRAL, Character::Moral::CHAOTIC, 2*Math::PI, 0,      0,       1,      1,        0
1.character=Character::Ethic::NEUTRAL, Character::Moral::LAWFUL , 2*Math::PI, 0,      0,       1,      1,        0
2.character=Character::Ethic::NEUTRAL, Character::Moral::NEUTRAL, 2*Math::PI, 0,      0,       1,      1,        0
3.character=Character::Ethic::GOOD   , Character::Moral::LAWFUL , 2*Math::PI, 0,      0,       1,      1,        0
4.character=Character::Ethic::NEUTRAL, Character::Moral::LAWFUL , 2*Math::PI, 0,      0,       1,      1,        0
5.character=Character::Ethic::GOOD   , Character::Moral::CHAOTIC, 2*Math::PI, 0,      0,       1,      1,        0
6.character=Character::Ethic::GOOD   , Character::Moral::LAWFUL , 2*Math::PI, 0,      0,       1,      1,        0
7.character=Character::Ethic::GOOD   , Character::Moral::NEUTRAL, 2*Math::PI, 0,      0,       1,      1,        0
8.character=Character::Ethic::NEUTRAL, Character::Moral::LAWFUL , 2*Math::PI, 0,      0,       1,      1,        0
9.character=Character::Ethic::NEUTRAL, Character::Moral::LAWFUL , 2*Math::PI, 0,      0,       1,      1,        0

class BasicObject

  #this method is necessary so in case the object is frozen the character is computed on the fly
  def character ()
    return @character if @character
    #puts "generating character for #{self.to_s}"
    ch = ::Character.generate self.to_s
    @character = ch unless frozen?
    ch
  end

  def self.process_call(inst, method, name, chr, *args, &block)
    @@armed = false if @@armed
    puts method
    @@armed = true unless @@armed.nil?
    rv = method.bind(inst).call(*args, &block)
    return rv unless @@armed
    @@armed = false
    puts "processing call: #{method} which is #{chr || "uncharacteristic"} on #{inst} which is a #{self} with #{inst.character || "no character"} given #{args.size > 0?args:"no args"} and #{block || "no block"}"

    #avgargs = args.inject(:+) / args.size
    self.class.character.step!
    args.each{|a| character.acc! a.character, 0.001}
    self.class.character.acc! character, 0.0001
    args.each do |a| #FIXME constants ahead!
      a.character.acc! chr, 0.01
      a.character.acc! character, 0.01
      a.character.acc! self.class.character, 0.001
      rv.character.acc! a.character, 0.001
    end
    rv.character.acc! chr, 0.01
    rv.character.acc! character, 0.002
    rv.character.acc! self.class.character, 0.001

    @@armed = true
    rv
  end

  def self.process_method(method, name)
    ::Character.generate name
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
    chr = process_method(new_method, name)
    handler = self.method(:process_call)
    define_method name do |*args, &block|
      handler.call(self, new_method, name, chr, *args, &block)
    end
    @@armed = true if not @@armed.nil?
  end
  
  def self.infect_all!
    self.instance_methods.each do |m|
      unless m == :call or m == :! or m == :nil? or m == :to_ary or m == :respond_to? or m == :method or m == :instance_method or m == :to_s or m == :character or m == :process_method
        #puts "\t-infecting #{m}"
        infect_method(m)
      end
    end
  end
  
  def self.armed?
    @@armed
  end

  class_variable_set(:@@armed, nil)

  def self.arm!
    @@armed = true
  end

  def self.disarm!
    class_variable_set(:@@armed, nil)
  end

  def self.method_added(name)
    #puts "added: #{name}"
    infect_method(name) if @@armed
  end
end

#puts "+infecting Method"
#Method.infect_all!

#infect global objects
Module.constants.each do |c|
  unless c == :Method or c == :UnboundMethod or c == :Config or c == :Object or c == :BasicObject or c == :Character
    #puts "+infecting #{c}"
    cs = Module.const_get(c)
    cs.infect_all! if cs.is_a? Class
  end
end

puts "Graf Zahl resurrected."
Object.arm!

