require 'fixtures/class_b'

class ClassA
  class InnerClass
    def self.class_method_1
    end
  end

  def self.execute(scenario)
    case scenario
    when :scenario_1
      class_method_1
    when :scenario_2
      ClassB.class_method_1
    when :scenario_3
      new.instance_method_1
    when :scenario_4
      new.instance_method_2
    when :scenario_5
      ClassB.class_method_1
      ClassB.class_method_2
    when :scenario_6
      ClassB.class_method_3
    when :scenario_7
      ClassB.class_method_4
    when :scenario_8
      ClassB.class_method_5
    when :scenario_9
      InnerClass.class_method_1
    end
  end

  def self.class_method_1
  end

  def instance_method_1
  end

  def instance_method_2
    ClassB.new.instance_method_1
  end
end
