require 'rubygems'
gem 'rspec', '>=1.1.3'
require 'spec'
require 'pathname'

require Pathname(__FILE__).dirname.expand_path.parent + 'lib/data_mapper'
require DataMapper.root / 'spec' / 'lib' / 'mock_adapter'

# setup mock adapters
[ :default, :mock, :legacy, :west_coast, :east_coast ].each do |repository_name|
  DataMapper.setup(repository_name, "mock://localhost/#{repository_name}")
end

def load_driver(name, default_uri)
  lib = "do_#{name}"

  begin
    gem lib, '=0.9.0'
    require lib
    DataMapper.setup(name, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
    true
  rescue Exception => e
    warn "Could not load #{lib}: #{e}" if name == ADAPTER
    false
  end
end

ENV['ADAPTER'] ||= 'sqlite3'

ADAPTER = ENV['ADAPTER'].to_sym

HAS_SQLITE3  = load_driver(:sqlite3,  'sqlite3::memory:')
HAS_MYSQL    = load_driver(:mysql,    'mysql://localhost/dm_core_test')
HAS_POSTGRES = load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')

class Article
  include DataMapper::Resource

  property :id,         Integer, :serial => true
  property :blog_id,    Integer
  property :created_at, DateTime
  property :author,     String
  property :title,      String
end

class Comment
  include DataMapper::Resource
end

class NormalClass
  # should not include DataMapper::Resource
end

# ==========================
# Used for Association specs
class Vehicle
  include DataMapper::Resource

  property :id, Integer, :serial => true
  property :name, String
end

class Manufacturer
  include DataMapper::Resource

  property :id, Integer, :serial => true
  property :name, String
end

class Supplier
  include DataMapper::Resource

  property :id, Integer, :serial => true
  property :name, String
end

class Class
  def publicize_methods
    klass = class << self; self; end

    saved_private_class_methods      = klass.private_instance_methods
    saved_protected_class_methods    = klass.protected_instance_methods
    saved_private_instance_methods   = self.private_instance_methods
    saved_protected_instance_methods = self.protected_instance_methods

    self.class_eval do
      klass.send(:public, *saved_private_class_methods)
      klass.send(:public, *saved_protected_class_methods)
      public(*saved_private_instance_methods)
      public(*saved_protected_instance_methods)
    end

    begin
      yield
    ensure
      self.class_eval do
        klass.send(:private, *saved_private_class_methods)
        klass.send(:protected, *saved_protected_class_methods)
        private(*saved_private_instance_methods)
        protected(*saved_protected_instance_methods)
      end
    end
  end
end
