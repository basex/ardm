require 'spec_helper'

try_spec do

  require './spec/fixtures/network_node'

  describe Ardm::PropertyFixtures::NetworkNode do
    describe 'with UUID set as UUID object' do
      before :each do
        @uuid_string = 'b0fc632e-d744-4821-afe3-4ea0701859ee'
        @uuid        = UUIDTools::UUID.parse(@uuid_string)
        @resource    = Ardm::PropertyFixtures::NetworkNode.new(:uuid => @uuid)

        @resource.save.should be(true)
      end

      describe 'when reloaded' do
        before :each do
          @resource.reload
        end

        it 'has the same UUID string' do
          @resource.uuid.to_s.should == @uuid_string
        end

        it 'returns UUID as an object' do
          @resource.uuid.should be_an_instance_of(UUIDTools::UUID)
        end
      end
    end

    describe 'with UUID set as a valid UUID string' do
      before :each do
        @uuid  = 'b0fc632e-d744-4821-afe3-4ea0701859ee'
        @resource = Ardm::PropertyFixtures::NetworkNode.new(:uuid => @uuid)
        @resource.save.should be(true)
      end

      describe 'when reloaded' do
        before :each do
          @resource.reload
        end

        it 'has the same UUID string' do
          @resource.uuid.to_s.should == @uuid
        end

        it 'returns UUID as an object' do
          @resource.uuid.should be_an_instance_of(UUIDTools::UUID)
        end
      end
    end

    describe 'with UUID set as invalid UUID string' do
      before :each do
        @uuid  = 'meh'
        @operation = lambda do
          Ardm::PropertyFixtures::NetworkNode.new(:uuid => @uuid)
        end
      end

      describe 'when assigned UUID' do
        it 'raises ArgumentError' do
          @operation.should raise_error(ArgumentError, /Invalid UUID format/)
        end
      end
    end

    describe 'with UUID set as a blank string' do
      before :each do
        @uuid  = ''
        @operation = lambda do
          Ardm::PropertyFixtures::NetworkNode.new(:uuid => @uuid)
        end
      end

      describe 'when assigned UUID' do
        it 'raises ArgumentError' do
          @operation.should raise_error(ArgumentError, /Invalid UUID format/)
        end
      end
    end

    describe 'with missing UUID' do
      before :each do
        @uuid  = nil
        @resource = Ardm::PropertyFixtures::NetworkNode.new(:uuid => @uuid)
        @resource.save.should be(true)
      end

      describe 'when reloaded' do
        before :each do
          @resource.reload
        end

        it 'has no UUID' do
          @resource.uuid.should be_nil
        end
      end
    end
  end
end
