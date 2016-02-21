class ConfigHelper
	def self.check_domain_key(domain_config, domain)
		domain_config[domain] = {:config => {}, :subdomains => {}, :redirects => {}, :default_subdomains => {}} if domain_config[domain].nil?
		domain_config
	end

	def self.check_sub_domain_key(subdomain_config, subdomain)
		subdomain_config[subdomain] = {:direct => {}, :internal => {}, :dynamic => {}} if subdomain_config[subdomain].nil?
		subdomain_config
	end
end
