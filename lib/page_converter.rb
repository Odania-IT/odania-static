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

			@page_processor.process_pages(directory, domain, subdomain, :partials)
		end
	end
end
