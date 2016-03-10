class GeneratePluginConfig
	def create(static_dir)
		config_data = JSON.parse File.read "#{static_dir}/config.json"

		ips = Odania.ips
		plugin_config = config_data.clone
		plugin_config[:domains] = Hash.new
		plugin_config['plugin-config']['ips'] = ips
		plugin_config['plugin-config']['ip'] = Odania.primary_ip(ips)
		plugin_config['plugin-config']['port'] = 80
		plugin_config['plugin-config']['tags'] = ['content']
		puts JSON.pretty_generate plugin_config

		configs_dir = "#{static_dir}/contents/"
		puts "Searching for domain config files in #{configs_dir}"
		Dir.glob("#{configs_dir}/**/config.json").each do |file|
			domain = file.gsub("#{configs_dir}/", '').gsub('/config.json', '')

			plugin_config[:domains] = ConfigHelper.check_domain_key(plugin_config[:domains], domain)
			plugin_config[:domains][domain][:config] = JSON.parse File.read file
		end

		plugin_config
	end
end
