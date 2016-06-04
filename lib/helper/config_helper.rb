class ConfigHelper
	def self.check_domain_key(domain_config, domain)
		domain_config[domain] = {:config => {}, :subdomains => {}, :redirects => {}, :default_subdomains => {}} if domain_config[domain].nil?
		domain_config
	end
end
