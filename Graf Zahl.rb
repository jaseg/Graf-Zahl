#!/usr/bin/env ruby

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
    #puts "creating character with #{traits.join(',')}"
    @traits = traits.to_a
    @traits_delta = traits_delta.to_a
  end

  def self.generate(something)
    ch = doTehArithmancy(something).character
    #puts "got a number: #{num} chr #{num.instance_variable_get(:@character)}"
    return ch.clone if ch
    return Character.new
  end

  def acc(chr, factor)
    return @traits_delta unless chr
    tplus (tmult (tminus chr.traits, traits), factor), traits_delta
  end

  #that stuff is still kinda indirect.
  def acc!(chr, factor)
    @traits_delta = acc(chr, factor)
  end

  def step! ()
    @traits = tplus @traits, @traits_delta
    @traits_delta = tmult @traits_delta, 0.1
    cap!
  end

  def tminus (a,b)
    a.zip(b).map{|c| c[0]-c[1]}
  end

  def tplus (a,b)
    a.zip(b).map{|c| c[0]+c[1]}
  end

  def tmult (a,s)
    a.map{|t| t*s}
  end

  def tdiv (a,s)
    a.map{|t| t/s}
  end

  def length
    return Math::sqrt(@traits.inject(0){|a,e|a+e*e})
  end

  #returns a character
  def cap! ()
    @traits = @traits.each_with_index.map do |v, i|
      next v if ["tau", "i"].include? TRAITS[i]
      if v < 0
        0
      elsif v > 1
        1
      else
        v
      end
    end
  end

  def traits= (params)
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

module Characterizable
  def character= (*params)
    @character = Character.new unless @character
    @character.traits = params[0]
    #puts "set character for #{self.to_s} to #{@character} according to #{params[0]}"
  end

  def character ()
    return @character if @character
    #puts "generating character for #{self.to_s}"
    ch = Character.generate self.to_s
    @character = ch unless frozen?
    ch
  end
end

class Fixnum
  include Characterizable 
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
end

class Symbol
  include Characterizable 
  all_symbols.each do |sym|
    sym.character
  end
end

class Method
  def character ()
    name.to_sym.character
  end
end

class BasicObject
  def character ()
    self.class.name.to_sym.character
  end

  def process_call(method, name, *args, &block)
    rv = method.bind(self).call(*args, &block)
    if @@armed
      @@armed = false
      #puts "processing call: #{method} which is #{method.character || "uncharacteristic"} on #{self} which is a #{self.class} with #{character || "no character"} given #{args.size > 0?args:"no args"} and #{block || "no block"}"

      #character.step!
      #rv.character.step!
      #name.character.step!
      args.each do |a| #FIXME constants ahead!
        a.character.step!
        a.character.acc! name.character, 0.01
        a.character.acc! character, 0.01
        character.acc! a.character, 0.001
        rv.character.acc! a.character, 0.001
        name.character.acc! a.character, 0.001
      end
      rv.character.acc! name.character, 0.01
      rv.character.acc! character, 0.002
      character.acc! name.character, 0.001

      @@armed = true
    end
    return rv
  end

  def self.infect_method(name)
    @@armed = false if @@armed
    raw_method = self.instance_method(name.to_sym)
    define_method name do |*args, &block|
      self.process_call(raw_method, name, *args, &block)
    end
    @@armed = true if not @@armed.nil?
  end
  
  def self.infect_all!
    self.instance_methods.each do |m|
      unless [:process_call, :bind, :call].include? m
        #puts "\t-infecting #{m}"
        infect_method(m)
      end
    end
  end

  def self.method_added(name)
    infect_method(name) if @@armed
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

  #infect global objects
  ::Module.constants.each do |c|
    unless [:Config].include? c
      #puts "+infecting #{c}"
      cs = ::Module.const_get(c)
      cs.infect_all! if cs.is_a? ::Class
    end
  end
end

puts "Graf Zahl resurrected."
BasicObject.arm!

