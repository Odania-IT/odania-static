require 'rb-inotify'

class InotifyUpdater
	attr_accessor :notifier, :timer

	def initialize
		self.notifier = INotify::Notifier.new
	end

	def watch(web_dir)
		puts "Start watching directory: #{web_dir}"

		self.notifier.watch(web_dir, :modify, :create, :delete, :moved_from, :moved_to, :recursive) do |event|
			puts "Event: #{event}"
			run_update
		end

		EM.watch self.notifier.to_io do
			self.notifier.process
		end
	end
end
