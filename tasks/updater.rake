require 'yaml'
require 'eventmachine'

require_relative '../lib/updater/git_updater'
require_relative '../lib/updater/inotify_updater'
require_relative '../lib/updater/null_updater'

namespace :web do
	desc 'Updater to automatically update the pages'
	task :updater do
		def run_update
			puts "UPDATE"
			`cd #{BASE_DIR} && rake web:generate`
		end

		updater_clazz = {
			'git' => GitUpdater.new,
			'inotify' => InotifyUpdater.new,
			'none' => NullUpdater.new
		}

		config = YAML.load_file './config/application.yml'
		application_config = config['application']
		updater = updater_clazz[application_config['updater']]

		puts config['application']['updater'].inspect
		puts updater.inspect

		EM.run do
			updater.watch application_config['static_dir']
		end

	end
end
