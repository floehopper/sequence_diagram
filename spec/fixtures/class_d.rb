require 'fixtures/class_e'

class ClassD
  def self.class_method_1
  end

  def self.class_method_2
    ClassE.class_method_1
  end
end
