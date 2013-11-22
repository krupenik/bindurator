require 'unbind/core_ext/hash/keys'
require 'unbind/core_ext/string/inflections'

describe Hash do
  describe '#symbolize_keys' do
    it 'converts string keys to symbols' do
      expect({'symbol' => ''}.symbolize_keys).to eq({symbol: ''})
    end
  end
end

describe String do
  describe '#camelize' do
    it 'converts underscored_string to CamelCase' do
      expect('camel_case_test'.camelize).to eq('CamelCaseTest')
    end
  end
end
