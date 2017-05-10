require 'spec_helper'
require 'sequence_diagram/method_invocation/filter'

describe SequenceDiagram::MethodInvocation::Filter do
  let(:discriminator) { double(:path_discriminator) }

  subject { described_class.new(discriminator) }

  before do
    allow(discriminator).to receive(:inside_application?) do |actor|
      actor.path =~ /^inside/
    end
  end

  describe '#filter' do
    # let(:events) { [event] }
    #
    # context 'when both paths are inside application' do
    #   let(:event) { double(:event, paths: ['inside-path-1', 'inside-path-2']) }
    #
    #   it 'includes event' do
    #     expect(subject.filter(events)).to include(event)
    #   end
    # end
    #
    # context 'when first path is outside application' do
    #   let(:event) { double(:event, paths: ['outside-path', 'inside-path']) }
    #
    #   it 'excludes event' do
    #     expect(subject.filter(events)).not_to include(event)
    #   end
    # end
    #
    # context 'when second path is outside application' do
    #   let(:event) { double(:event, paths: ['inside-path', 'outside-path']) }
    #
    #   it 'excludes event' do
    #     expect(subject.filter(events)).not_to include(event)
    #   end
    # end
    #
    # context 'when both paths are outside application' do
    #   let(:event) { double(:event, paths: ['outside-path-1', 'outside-path-2']) }
    #
    #   it 'excludes event' do
    #     expect(subject.filter(events)).not_to include(event)
    #   end
    # end
  end
end
