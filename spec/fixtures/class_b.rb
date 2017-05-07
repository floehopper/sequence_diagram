require 'fixtures/class_c'

class ClassB
  def self.class_method_1
  end

  def self.class_method_2
  end

  def self.class_method_3
    ClassC.class_method_1
  end

  def instance_method_1
  end
end
