class AssetConverter
	def initialize(static_dir, target_web_dir)
		@static_dir = static_dir
		@target_web_dir = target_web_dir
	end

	def convert
		FileUtils.mkdir_p "#{@target_web_dir}/contents" unless Dir.exists? "#{@target_web_dir}/contents"

		Dir.glob("#{@static_dir}/contents/**/assets").each do |directory|
			parts = directory.split('/')
			parts.pop
			subdomain = parts.pop
			domain = parts.pop

			next if 'layouts'.eql? domain
			puts
			puts
			puts "Got domain: #{domain} sub_domain: #{subdomain} ======================================================================================"
			$domain_config[domain][subdomain][:assets] = process_assets(directory)
		end

		$domain_config
	end

	protected

	# Process assets
	# TODO minify, processing
	def process_assets(directory, config=nil, prefix='')
		return {} unless File.directory? directory
		config = {} if config.nil?

		Dir.glob("#{directory}/**/*").each do |file|
			name = file.gsub("#{directory}/", '')

			if File.directory? file
				process_assets file, config, "#{name}/"
			else
				target_name = file.gsub(@static_dir, '')
				target_file = "#{@target_web_dir}#{target_name}"

				target_dir = File.dirname target_file
				FileUtils.mkdir_p target_dir unless Dir.exists? target_dir
				FileUtils.cp file, target_file

				config["#{prefix}#{name}"] = {
					plugin_url: target_name,
					cacheable: true
				}
			end
		end

		config
	end
end
