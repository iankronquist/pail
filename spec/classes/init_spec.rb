require 'spec_helper'
describe 'puppetpail' do

  context 'with defaults for all parameters' do
    it { should contain_class('puppetpail') }
  end
end
