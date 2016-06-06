require 'rubygems'
require 'yaml'
require 'json'
require 'socket'
require 'odania'

require_relative '../lib/generate_plugin_config'
require_relative '../lib/asset_converter'
require_relative '../lib/domain_configs'
require_relative '../lib/layout_converter'
require_relative '../lib/page_converter'
require_relative '../lib/helper/config_helper'
require_relative '../lib/helper/page_processor'

namespace :web do
	desc 'Build the web files'
	task :generate do
		config = YAML.load_file './config/application.yml'
		application_config = config['application']
		static_dir = application_config['static_dir']
		release_dir = application_config['release_dir'] + '/' + Time.now.strftime('%Y%m%d_%H%M%S')

		puts 'Retrieving core information'
		core_service = Odania.consul.service.get_core_service
		$core_uri = core_service.ServiceAddress
		$core_port = core_service.ServicePort
		puts "Core found at #{$core_uri}:#{$core_port}"

		puts 'Loading configuration'
		plugin_config = GeneratePluginConfig.new.create static_dir

		puts 'Generating web files'
		$valid_domains = Hash.new { |hash, key| hash[key] = [] }
		$domain_config = Hash.new { |hash, key| hash[key] = Hash.new { |h, k| h[k] = {assets: {}, layouts: {}, pages: {}, config: {}} } }
		$default_domains = Hash.new { |hash, key| hash[key] = [] }
		$partials = Hash.new { |hash, key| hash[key] = Hash.new { |h, k| h[k] = {default: {}, layouts: Hash.new { |a, b| a[b] = {} } } } }
		DomainConfigs.new(static_dir).process
		AssetConverter.new(static_dir, release_dir).convert
		LayoutConverter.new(static_dir, release_dir).convert
		PageConverter.new(static_dir).convert
		plugin_config[:domains] = $domain_config
		plugin_config[:valid_domains] = $valid_domains
		plugin_config[:default_domains] = $default_domains
		plugin_config[:partials] = $partials

		puts 'Writing plugin config'
		File.write "#{release_dir}/config.json", JSON.pretty_generate(plugin_config)

		# Writing health check
		File.write "#{release_dir}/health", 'OK'

		# Symlink new release dir to web
		web_dir = application_config['web_dir']
		puts "Symlinking release dir #{release_dir} => #{web_dir}"
		FileUtils.ln_sf release_dir, web_dir
		`ln -sfn #{release_dir} #{web_dir}`

		# Cleaning old releases
		sorted_entries = Dir.glob(File.join(application_config['release_dir'], '*')).sort
		if sorted_entries.length > 3
			last_entries = []
			last_entries << sorted_entries.pop
			last_entries << sorted_entries.pop
			last_entries << sorted_entries.pop

			puts "Keeping releases: #{last_entries.join(', ')}"

			sorted_entries.each do |entry|
				puts "Cleaning release: #{entry}"
				FileUtils.remove_dir entry
			end
		end

		puts '======================== PLUGIN CONFIG ============================================='
		puts JSON.pretty_generate plugin_config
		puts '======================== FIN PLUGIN CONFIG ============================================='

		plugin_instance_name = Odania.plugin.get_plugin_instance_name plugin_config['plugin-config']['name']
		Odania.plugin.register plugin_instance_name, plugin_config

		puts 'Done'
	end
end
