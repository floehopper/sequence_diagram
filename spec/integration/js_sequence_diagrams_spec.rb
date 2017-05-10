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

    context 'but ClassB is in library code' do
      let(:paths) { ['spec/fixtures/class_a.rb', 'spec/fixtures/class_c.rb'] }

      it 'generates nested lines for the calls and the returns' do
        expect(output_from(&block)).to eq([
          'ClassA->Library(1): class_method_3',
          'Library(1)->ClassC: class_method_1',
          'ClassC-->Library(1): class_method_1',
          'Library(1)-->ClassA: class_method_3'
        ])
      end
    end
  end

  context 'when three methods are called from another class each inside the last' do
    let(:block) { -> {
      ClassA.execute(:scenario_7)
    }}

    it 'generates nested lines for the calls and the returns' do
      expect(output_from(&block)).to eq([
        'ClassA->ClassB: class_method_4',
        'ClassB->ClassC: class_method_2',
        'ClassC->ClassD: class_method_1',
        'ClassD-->ClassC: class_method_1',
        'ClassC-->ClassB: class_method_2',
        'ClassB-->ClassA: class_method_4'
      ])
    end

    context 'but ClassB & ClassC are in library code' do
      let(:paths) { ['spec/fixtures/class_a.rb', 'spec/fixtures/class_d.rb'] }

      it 'generates nested lines for the calls and the returns' do
        expect(output_from(&block)).to eq([
          'ClassA->Library(1): class_method_4',
          'Library(1)->ClassD: class_method_1',
          'ClassD-->Library(1): class_method_1',
          'Library(1)-->ClassA: class_method_4'
        ])
      end
    end
  end

  context 'when four methods are called from another class each inside the last' do
    let(:block) { -> {
      ClassA.execute(:scenario_8)
    }}

    it 'generates nested lines for the calls and the returns' do
      expect(output_from(&block)).to eq([
        'ClassA->ClassB: class_method_5',
        'ClassB->ClassC: class_method_3',
        'ClassC->ClassD: class_method_2',
        'ClassD->ClassE: class_method_1',
        'ClassE-->ClassD: class_method_1',
        'ClassD-->ClassC: class_method_2',
        'ClassC-->ClassB: class_method_3',
        'ClassB-->ClassA: class_method_5'
      ])
    end

    context 'but ClassB, ClassC & CLassD are in library code' do
      let(:paths) { ['spec/fixtures/class_a.rb', 'spec/fixtures/class_e.rb'] }

      it 'generates nested lines for the calls and the returns' do
        expect(output_from(&block)).to eq([
          'ClassA->Library(1): class_method_5',
          'Library(1)->ClassE: class_method_1',
          'ClassE-->Library(1): class_method_1',
          'Library(1)-->ClassA: class_method_5'
        ])
      end
    end

    context 'but ClassB & ClassD are in library code' do
      let(:paths) { ['spec/fixtures/class_a.rb', 'spec/fixtures/class_c.rb', 'spec/fixtures/class_e.rb'] }

      it 'generates nested lines for the calls and the returns' do
        expect(output_from(&block)).to eq([
          'ClassA->Library(1): class_method_5',
          'Library(1)->ClassC: class_method_3',
          'ClassC->Library(2): class_method_2',
          'Library(2)->ClassE: class_method_1',
          'ClassE-->Library(2): class_method_1',
          'Library(2)-->ClassC: class_method_2',
          'ClassC-->Library(1): class_method_3',
          'Library(1)-->ClassA: class_method_5'
        ])
      end
    end
  end

  context 'when method is called on namespaced class' do
    let(:block) { -> {
      ClassA.execute(:scenario_9)
    }}

    it 'replaces double-colons with tildes' do
      expect(output_from(&block)).to eq([
        'ClassA->ClassA~InnerClass: class_method_1',
        'ClassA~InnerClass-->ClassA: class_method_1'
      ])
    end
  end

  def output_from(&block)
    tracer.trace(&block)
    events = filter.filter(tracer.events)
    events.shift
    events.pop
    formatter.write(events)
    io.rewind
    io.each_line.map(&:chomp)
  end
end
