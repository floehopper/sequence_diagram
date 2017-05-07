require 'fixtures/class_b'

class ClassA
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
