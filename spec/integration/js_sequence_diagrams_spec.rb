require 'spec_helper'
require 'sequence_diagram/method_invocation/whitelist_filter'
require 'sequence_diagram/method_invocation/tracer'
require 'sequence_diagram/js_sequence_diagram_formatter'
require 'fixtures/class_a'

describe 'js-sequence-diagrams' do
  let(:tracer) { SequenceDiagram::MethodInvocation::Tracer.new }

  let(:paths) { Dir['spec/fixtures/class_*.rb'] }
  let(:filter) { SequenceDiagram::MethodInvocation::WhitelistFilter.new(paths) }

  let(:io) { StringIO.new }
  let(:formatter) { SequenceDiagram::JsSequenceDiagramFormatter.new(io) }

  context 'when class method is called from class method in same class' do
    let(:block) { -> {
      ClassA.execute(:scenario_1)
    }}

    it 'generates line for the call, but not the return' do
      expect(output_from(&block)).to eq([
        'ClassA->ClassA: class_method_1'
      ])
    end
  end

  context 'when class method is called from class method in another class' do
    let(:block) { -> {
      ClassA.execute(:scenario_2)
    }}

    it 'generates lines for both the call and the return' do
      expect(output_from(&block)).to eq([
        'ClassA->ClassB: class_method_1',
        'ClassB-->ClassA: class_method_1'
      ])
    end
  end

  context 'when instance method is called from class method in same class' do
    let(:block) { -> {
      ClassA.execute(:scenario_3)
    }}

    it 'generates lines for both the call and the return' do
      expect(output_from(&block)).to eq([
        'ClassA->ClassA(1): instance_method_1',
        'ClassA(1)-->ClassA: instance_method_1'
      ])
    end
  end

  context 'when instance method is called from instance method in another class' do
    let(:block) { -> {
      ClassA.execute(:scenario_4)
    }}

    it 'generates lines for both the call and the return' do
      expect(output_from(&block)[1..2]).to eq([
        'ClassA(1)->ClassB(1): instance_method_1',
        'ClassB(1)-->ClassA(1): instance_method_1'
      ])
    end
  end

  context 'when two methods are called from another class one after the other' do
    let(:block) { -> {
      ClassA.execute(:scenario_5)
    }}

    it 'generates a line for the return for the first call before the second call' do
      expect(output_from(&block)).to eq([
        'ClassA->ClassB: class_method_1',
        'ClassB-->ClassA: class_method_1',
        'ClassA->ClassB: class_method_2',
        'ClassB-->ClassA: class_method_2'
      ])
    end
  end

  context 'when two methods are called from another class one inside the other' do
    let(:block) { -> {
      ClassA.execute(:scenario_6)
    }}

    it 'generates nested lines for the calls and the returns' do
      expect(output_from(&block)).to eq([
        'ClassA->ClassB: class_method_3',
        'ClassB->ClassC: class_method_1',
        'ClassC-->ClassB: class_method_1',
        'ClassB-->ClassA: class_method_3'
      ])
    end
  end

  def output_from(&block)
    tracer.trace(&block)
    events = filter.filter(tracer.events)
    formatter.write(events)
    io.rewind
    io.each_line.map(&:chomp)
  end
end
