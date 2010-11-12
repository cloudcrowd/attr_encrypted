require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the attr_encrypted gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'lib/attr_encrypted'
  # CloudCrowd keeps volatile components in the source tree, not installed
  t.libs.concat [ 
    'dm-core.git', 
    'addressable.git', 
    'extlib.git', 
    'eigenclass.git', 
    'encryptor.git' ,
    'dm-mysql-adapter-1.0.0',
    'do_mysql-0.10.2',
    'data_objects-0.10.2',
    'dm-do-adapter.git',
    'dm-migrations.git'
    ].map{|x| "../#{x}/lib"}

  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the attr_encrypted gem.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'attr_encrypted'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
