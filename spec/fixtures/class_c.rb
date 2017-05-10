require 'fixtures/class_d'

class ClassC
  def self.class_method_1
  end

  def self.class_method_2
    ClassD.class_method_1
  end

  def self.class_method_3
    ClassD.class_method_2
  end
end
