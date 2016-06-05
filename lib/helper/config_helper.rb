class ConfigHelper
	def self.check_domain_key(domain_config, domain)
		domain_config[domain] = {config: {}, subdomains: {}, redirects: {}, valid_domains: {}, default_domains: {} } if domain_config[domain].nil?
		domain_config
	end
end
