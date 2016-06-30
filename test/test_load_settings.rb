gem 'minitest'
require 'minitest/autorun'
require 'choices'
require 'pathname'
require 'choices/rails'

describe Choices do

  before do
    path = Pathname.new(__FILE__)
    @without_local = path + '../settings/without_local.yml'
    @with_local = path + '../settings/with_local.yml'
  end

  describe 'when loading from Hash' do
    it 'should accept a Hash' do
      helper = Hashie::Mash.new
      helper.extend(Choices::Rails)
      helper.instance_variable_set(:@choices, Hashie::Mash.new)
      helper.from_hash({a: 100})
      helper.a.must_equal 100
    end

    it 'should accept a File' do
      helper = Hashie::Mash.new
      helper.extend(Choices::Rails)
      helper.instance_variable_set(:@choices, Hashie::Mash.new)
      helper.from_file(@without_local, "production")
      helper.name.must_equal "Production"
    end
  end

  describe 'when loading a settings file' do
    it 'should return a mash for the specified environment' do
      Choices.load_settings(@without_local, 'defaults').name.must_equal 'Defaults'
      Choices.load_settings(@without_local, 'production').name.must_equal 'Production'
    end

    it 'should load the local settings' do
      Choices.load_settings(@with_local, 'defaults').name.must_equal 'Defaults'
      Choices.load_settings(@with_local, 'development').name.must_equal 'Development'
      Choices.load_settings(@with_local, 'production').name.must_equal 'Production local'
    end

    it 'should raise an exception if the environment does not exist' do
      error = lambda {
        Choices.load_settings(@with_local, 'nonexistent')
      }.must_raise(IndexError)
      error.message.must_equal %{Missing key for "nonexistent" in `#{@with_local}'}
    end
  end
end
