# frozen_string_literal: true

describe Facts::Linux::Disks do
  subject(:fact) { Facts::Linux::Disks.new }

  let(:disk) do
    {
      'sda' => {
        model: 'Virtual disk',
        size: '20.00 GiB',
        size_bytes: 21_474_836_480,
        vendor: 'VMware'
      }
    }
  end

  let(:expecte_response) do
    {
      'sda' => {
        'model' => 'Virtual disk',
        'size' => '20.00 GiB',
        'size_bytes' => 21_474_836_480,
        'vendor' => 'VMware'
      }
    }
  end

  describe '#call_the_resolver' do
    before do
      allow(Facter::Resolvers::Linux::Disk).to receive(:resolve).with(:disks).and_return(disk)
    end

    it 'calls Facter::Resolvers::Linux::Disk' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Disk).to have_received(:resolve).with(:disks)
    end

    it 'returns resolved fact with name disk and value' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Array)
        .and contain_exactly(
          an_object_having_attributes(name: 'disks', value: expecte_response),
          an_object_having_attributes(name: 'blockdevices', value: 'sda'),
          an_object_having_attributes(name: 'blockdevice_sda_model', value: 'Virtual disk', type: :legacy),
          an_object_having_attributes(name: 'blockdevice_sda_size', value: 21_474_836_480, type: :legacy),
          an_object_having_attributes(name: 'blockdevice_sda_vendor', value: 'VMware', type: :legacy)
        )
    end

    context 'when resolver returns empty hash' do
      let(:disk) { {} }

      it 'returns nil fact' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'disks', value: nil)
      end
    end

    context 'when resolver returns nil' do
      let(:disk) { nil }

      it 'returns nil fact' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'disks', value: nil)
      end
    end
  end
end
