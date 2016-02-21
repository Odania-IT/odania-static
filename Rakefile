require 'redcarpet'
require 'rspec'
require 'ruby-lint'

BASE_DIR = File.dirname(__FILE__) unless defined? 'BASE_DIR'

# Import custom tasks to keep the main Rakefile small
Dir.glob('tasks/*.rake').each { |r| import r }

task :spec => ['spec:all']
task :default => ['spec:all', 'lint']
