class GeneratePluginConfig
	def create(static_dir)
		config_data = JSON.parse File.read "#{static_dir}/config.json"

		ips = Odania.ips
		plugin_config = config_data.clone
		plugin_config['plugin-config']['ips'] = ips
		plugin_config['plugin-config']['ip'] = Odania.primary_ip(ips)
		plugin_config['plugin-config']['port'] = 80
		plugin_config['plugin-config']['tags'] = ['content']
		puts JSON.pretty_generate plugin_config

		plugin_config
	end
end
