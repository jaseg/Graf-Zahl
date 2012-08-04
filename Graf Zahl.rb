#!/usr/bin/env ruby

class Class
  def infect!()
    #alias old_new new #FIXME this is ugly
    old_new = self.instance_method(:new) if self.respond_to? :new
    define_method "new" do|*args, &block|
      self.class.process_new(self, *args, &block)
      old_new.bind(self).call(*args, &block)
    end
  end

  infect!

  def self.process_new(instance, *args, &block)
    puts "processing new: #{instance}, #{args}, #{block}"
  end
end

class Object
  attr_reader :ethic     # good   [1:0] evil
  attr_reader :moral     # lawful [1:0] chaotic

  armed = true
  attr_reader :tau       #
  attr_reader :i         #
 
  attr_reader :agility   #        [1:0]
  attr_reader :strength  #        [1:0]
  attr_reader :stamina   #        [1:0]
  attr_reader :expertise #        [1:0]

  attr_accessor :armed

  protected_class_methods = self.methods;
  
  def self.process_call(method, name, character, *args, &block)
    return if @@protected_class_methods.include? name
    #puts "processing call: #{method} as #{name} with #{character} given #{args} and #{block}"
  end

  def self.process_method(method, name)
    return if @@protected_class_methods.include? name
    puts "procsessing method #{method} as #{name}"
  end
  
  def self.infect_method(name)
    begin
      new_method = self.instance_method(name.to_sym)
    rescue NameError
    #  puts "cannot infect #{name}: #{e}"
    #  @armed = true if not @armed.nil?
      return
    end
    character = process_method(new_method, name)
    handler = self.method(:process_call)
    define_method name do |*args, &block|
      handler.call(new_method, name, character, *args, &block)
      new_method.bind(self).call(*args, &block)
    end
  end
  
  def self.initialize_character()
    #FIXME
  end

  def self.infect_all()
    puts @@protected_class_methods
    self.methods.each do |m|
      #puts "\t-infecting #{m}"
      infect_method(m)
    end
    self.initialize_character
  end

  class_variable_set(:@@protected_class_methods, self.methods - protected_class_methods)

  def self.method_added(name)
    infect_method(name) if @armed
  end
end

#infect global objects
Module.constants.each do |c|
  #puts "+infecting #{c}"
  c = Module.const_get(c)
  c.infect_all() if c.is_a? Class
end

