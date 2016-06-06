class LayoutConverter < AssetConverter
	def initialize(static_dir, target_web_dir)
		super(static_dir, target_web_dir)
		@page_processor = PageProcessor.new
	end

	def convert
		FileUtils.mkdir_p "#{@target_web_dir}/contents" unless Dir.exists? "#{@target_web_dir}/contents"

		Dir.glob("#{@static_dir}/contents/**/layout.json").each do |layout_json|
			directory = File.dirname(layout_json)
			parts = directory.split('/')
			layout_name = parts.pop
			parts.pop
			subdomain = parts.pop
			domain = parts.pop

			puts
			puts
			puts "Got Layout #{layout_name} for Domain: #{domain} Subdomain: #{subdomain} =============================================================================="
			layout_config = JSON.parse File.read layout_json

			$domain_config[domain][subdomain][:layouts][layout_name] = {
				assets: process_assets(File.join(directory, 'assets')),
				config: layout_config
			}

			# Load partials.json
			prefix = "layouts/#{layout_name}"
			partial_file = File.join directory, 'partials.json'
			if File.exists? partial_file
				partial_config = JSON.parse File.read(partial_file)

				partial_config.each_pair do |key, value|
					partial_config[key] = "#{prefix}/#{value}"
				end

				$partials[domain][subdomain][:layouts][layout_name].merge!(partial_config)
			end

			@page_processor.process_pages(File.join(directory, 'files'), domain, subdomain, :partials, prefix)
		end
	end
end
