require 'spec_helper'
describe 'pail' do

  context 'with defaults for all parameters' do
    it { should contain_class('pail') }
  end
end
