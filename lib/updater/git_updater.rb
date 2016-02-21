require 'git'

class GitUpdater
	attr_accessor :repo_url, :git

	def initialize(config)
		self.repo_url = config['git_updater']['repo_url']
=begin
		Git.configure do |config|
			# If you want to use a custom git binary
			config.binary_path = '/git/bin/path'

			# If you need to use a custom SSH script
			config.git_ssh = '/path/to/ssh/script'
		end
=end
		self.git = Git.open(self.repo_url, :log => Logger.new(STDOUT))
	end

	def watch(web_dir)
		puts "Start watching git repository: #{self.repo_url}"

		self.notifier.watch(web_dir, :modify, :create, :delete, :moved_from, :moved_to, :recursive) do |event|
			puts "Event: #{event}"
			unless self.timer.nil?
				puts "Cancel: #{self.timer.inspect}"
				#EventMachine.send :cancel_timer, self.timer
			end
			#EventMachine::Timer.cancel self.timer unless self.timer.nil?
			self.timer = EM.add_timer(2) do
				puts "Executing timer event: #{Time.now}"
				run_update
			end
			puts self.timer.inspect
		end

		EM.watch self.notifier.to_io do
			self.notifier.process
		end
	end
end
