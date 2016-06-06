class PageConverter
	def initialize(static_dir)
		@page_processor = PageProcessor.new
		@static_dir = static_dir
	end

	def convert
		Dir.glob("#{@static_dir}/contents/**/web").each do |directory|
			parts = directory.split('/')
			parts.pop
			subdomain = parts.pop
			domain = parts.pop

			puts
			puts
			puts "web domain: #{domain} sub_domain: #{subdomain} ======================================================================================"

			@page_processor.process_pages(directory, domain, subdomain, :web)
		end

		Dir.glob("#{@static_dir}/contents/**/partials").each do |directory|
			parts = directory.split('/')
			parts.pop
			subdomain = parts.pop
			domain = parts.pop

			puts
			puts
			puts "partials domain: #{domain} sub_domain: #{subdomain} ======================================================================================"

			# Load partials.json
			partial_file = File.join directory, 'partials.json'
			if File.exists? partial_file
				partial_config = JSON.parse File.read(partial_file)
				$partials[domain][subdomain][:default].merge!(partial_config)
			end

			@page_processor.process_pages(directory, domain, subdomain, :partials)
		end
	end
end
