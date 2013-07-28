require 'spec_helper'


describe 'SlashdotApi' do

  describe 'initialization' do
    it 'should initialize without an argument' do
      expect(SlashdotApi.new).to be_an_instance_of(SlashdotApi)
    end

    it 'should NOT initialize with an argument' do
      expect{SlashdotApi.new('foo')}.to raise_error()
    end
  end

end