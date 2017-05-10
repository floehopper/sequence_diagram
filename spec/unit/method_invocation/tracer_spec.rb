require 'spec_helper'
require 'sequence_diagram/method_invocation/tracer'

describe SequenceDiagram::MethodInvocation::Tracer do
  class A
    def x
      :x
    end

    def y
      x
    end
  end

  class B
    def initialize(o)
      @o = o
    end

    def z
      @o.x
    end
  end

  describe '#trace' do
    context 'when a call to A#x is traced' do
      it 'returns two events' do
        a = A.new
        subject.trace do
          a.x
        end

        expect(subject.events.length).to eq(2)
      end

      it 'returns a call event for A#x as the first event' do
        a = A.new
        subject.trace do
          a.x
        end

        e = subject.events[0]
        expect(e).to be_call
        expect(e.invoker.object).to eq(subject)
        expect(e.invokee.object).to eq(a)
        expect(e.method_name).to eq(:x)
      end

      it 'returns a return event for A#x as the second event' do
        a = A.new
        subject.trace do
          a.x
        end

        e = subject.events[1]
        expect(e).to be_return
        expect(e.invoker.object).to eq(subject)
        expect(e.invokee.object).to eq(a)
        expect(e.method_name).to eq(:x)
      end
    end

    context 'when a call to A#y (which calls A#x) is traced' do
      it 'returns four events' do
        a = A.new
        subject.trace do
          a.y
        end

        expect(subject.events.length).to eq(4)
      end

      it 'returns a call event for A#y as the first event' do
        a = A.new
        subject.trace do
          a.y
        end

        e = subject.events[0]
        expect(e).to be_call
        expect(e.invoker.object).to eq(subject)
        expect(e.invokee.object).to eq(a)
        expect(e.method_name).to eq(:y)
      end

      it 'returns a call event for A#x as the second event' do
        a = A.new
        subject.trace do
          a.y
        end

        e = subject.events[1]
        expect(e).to be_call
        expect(e.invoker.object).to eq(a)
        expect(e.invokee.object).to eq(a)
        expect(e.method_name).to eq(:x)
      end

      it 'returns a return event for A#x as the third event' do
        a = A.new
        subject.trace do
          a.y
        end

        e = subject.events[2]
        expect(e).to be_return
        expect(e.invoker.object).to eq(a)
        expect(e.invokee.object).to eq(a)
        expect(e.method_name).to eq(:x)
      end

      it 'returns a return event for A#y as the fourth event' do
        a = A.new
        subject.trace do
          a.y
        end

        e = subject.events[3]
        expect(e).to be_return
        expect(e.invoker.object).to eq(subject)
        expect(e.invokee.object).to eq(a)
        expect(e.method_name).to eq(:y)
      end
    end

    context 'when a call to B#z (which calls A#x) is traced' do
      it 'returns four events' do
        a = A.new
        b = B.new(a)
        subject.trace do
          b.z
        end

        expect(subject.events.length).to eq(4)
      end

      it 'returns a call event for B#z as the first event' do
        a = A.new
        b = B.new(a)
        subject.trace do
          b.z
        end

        e = subject.events[0]
        expect(e).to be_call
        expect(e.invoker.object).to eq(subject)
        expect(e.invokee.object).to eq(b)
        expect(e.method_name).to eq(:z)
      end

      it 'returns a call event for A#x as the second event' do
        a = A.new
        b = B.new(a)
        subject.trace do
          b.z
        end

        e = subject.events[1]
        expect(e).to be_call
        expect(e.invoker.object).to eq(b)
        expect(e.invokee.object).to eq(a)
        expect(e.method_name).to eq(:x)
      end

      it 'returns a return event for A#x as the third event' do
        a = A.new
        b = B.new(a)
        subject.trace do
          b.z
        end

        e = subject.events[2]
        expect(e).to be_return
        expect(e.invoker.object).to eq(b)
        expect(e.invokee.object).to eq(a)
        expect(e.method_name).to eq(:x)
      end

      it 'returns a return event for B#z as the fourth event' do
        a = A.new
        b = B.new(a)
        subject.trace do
          b.z
        end

        e = subject.events[3]
        expect(e).to be_return
        expect(e.invoker.object).to eq(subject)
        expect(e.invokee.object).to eq(b)
        expect(e.method_name).to eq(:z)
      end
    end
  end
end
