class DomainConfigs
	def initialize(static_dir)
		@content_dir = File.join static_dir, 'contents'
	end

	def process
		puts "Searching for domain-config.json files in #{@content_dir}"
		Dir.glob("#{@content_dir}/**/domain-config.json").each do |file|
			parts = File.dirname(file.gsub(@content_dir, '')).split('/')
			subdomain = '_general'
			if parts.length.eql? 3
				subdomain = parts.pop
			end
			domain = parts.pop

			domain_config = JSON.parse File.read file
			unless domain_config['config'].nil?
				$domain_config[domain][subdomain][:config] = domain_config['config']
				$default_domains = "#{subdomain}.#{domain}" if domain_config['config']['is_default']
			end
			$domain_config[domain][subdomain][:redirects] = domain_config['redirects'] unless domain_config['redirects'].nil?
		end
	end
end
