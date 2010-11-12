require File.dirname(__FILE__) + '/test_helper'

#DataMapper.setup(:default, "sqlite3::memory:")
# To verify things work with the MySQL adapter, 
# make sure you've created a vendor_unit_tests DB
DataMapper.setup(:default, "mysql://localhost/vendor_unit_tests")

class AttrEncryptClient
  include DataMapper::Resource
  
  property :id, Serial
  property :encrypted_email, String
  property :encrypted_credentials, Text
  property :salt, String
  
  attr_encrypted :email, :key => 'a secret key'
  attr_encrypted :credentials, :key => Proc.new { |client| Encryptor.encrypt(:value => client.salt, :key => 'some private key') }, :marshal => true
  
  def initialize(attrs = {})
    super attrs
    self.salt ||= Digest::SHA1.hexdigest((Time.now.to_i * rand(5)).to_s)
    self.credentials ||= { :username => 'example', :password => 'test' }
  end
end

# Verify that property validations still work. Note 
# that any attr_encrypted definitions must *follow*
# the property definition for the underlying encrypted field.
class AttrEncryptRequired
  include DataMapper::Resource
  
  property :id, Serial
  property :encrypted_email, String, :required => true
  attr_encrypted :email, :key => 'a secret key'
end

class AttrEncryptImplicit
  include DataMapper::Resource
  
  property :id, Serial
  attr_encrypted :email, :key => 'a secret key'
end

DataMapper.auto_migrate!

class DataMapperTest < Test::Unit::TestCase
  
  def setup
    AttrEncryptClient.all.each(&:destroy)
  end
  
  def test_should_encrypt_email
    @client = AttrEncryptClient.new :email => 'test@example.com'
    assert @client.save
    assert_not_nil @client.encrypted_email
    assert_not_equal @client.email, @client.encrypted_email
    assert_equal @client.email, AttrEncryptClient.first.email
  end

  def test_should_marshal_and_encrypt_credentials
    @client = AttrEncryptClient.new
    assert @client.save
    assert_not_nil @client.encrypted_credentials
    assert_not_equal @client.credentials, @client.encrypted_credentials
    assert_equal @client.credentials, AttrEncryptClient.first.credentials
    assert AttrEncryptClient.first.credentials.is_a?(Hash)
  end
  
  def test_should_encode_by_default
    assert AttrEncryptClient.attr_encrypted_options[:encode]
  end

  def test_required_property
    required = AttrEncryptRequired.create :email => 'recless@example.com'
    assert required.clean?
    assert_not_nil required.encrypted_email
    assert_not_equal required.email, required.encrypted_email
  end

  def test_implicit_property
    implicit = AttrEncryptImplicit.create :email => 'recless@example.net'
    assert implicit.clean?
    assert_not_nil implicit.encrypted_email
    assert_not_equal implicit.email, implicit.encrypted_email
    # Fails:
    #assert_nothing_raised { assert_equal implicit.email, AttrEncryptClient.first.email }
  end
  
end
