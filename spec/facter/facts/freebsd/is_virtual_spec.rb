# frozen_string_literal: true

describe Facts::Freebsd::IsVirtual do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::IsVirtual.new }

    let(:virtual_detector_double) { instance_spy(Facter::Util::Facts::VirtualDetector) }

    before do
      allow(Facter::Util::Facts::VirtualDetector).to receive(:new).and_return(virtual_detector_double)
      allow(virtual_detector_double).to receive(:platform).and_return(virtual_value)
    end

    context 'when not in a virtual environment' do
      let(:virtual_value) { 'physical' }

      it 'return resolved fact with nil value' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'is_virtual', value: false)
      end
    end

    context 'when in a virtual environment' do
      let(:virtual_value) { 'aws' }

      it 'return resolved fact with nil value' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'is_virtual', value: true)
      end
    end
  end
end
