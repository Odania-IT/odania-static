require_relative 'processors/html_processor'
require_relative 'processors/markdown_processor'
require_relative 'processors/pre_processor'

class PageConverter
	def initialize(static_dir, target_web_dir)
		@processors = [
			MarkdownProcessor.new,
			HtmlProcessor.new
		]
		@static_dir = static_dir
		@target_web_dir = target_web_dir
	end

	def convert
		FileUtils.mkdir_p "#{@target_web_dir}/contents" unless Dir.exists? "#{@target_web_dir}/contents"

		config = {}
		Dir.glob("#{@static_dir}/contents/**").each do |directory|
			domain = directory.gsub("#{@static_dir}/contents/", '')
			puts
			puts
			puts "Got domain: #{domain} ======================================================================================"

			config[domain] = process_domain(directory, domain)
		end

		config
	end

	private

	def process_domain(directory, domain)
		domain_config = {}

		Dir.glob("#{directory}/**").each do |subdomain_directory|
			subdomain = subdomain_directory.gsub("#{directory}/", '')
			if 'domain-config.json'.eql? subdomain
				domain_config['_general'] = {} if domain_config['_general'].nil?
				process_domain_config subdomain_directory, domain_config['_general']
				next
			end

			puts ' '*6 + " subdomain: #{subdomain}"

			domain_config[subdomain] = process_subdomain(subdomain_directory, domain)
		end

		domain_config
	end

	def process_subdomain(directory, domain)
		static_files = process_assets("#{directory}/assets")
		static_web_files = process_web_folder("#{directory}/web", domain)
		internal_files = process_internal("#{directory}/internal", domain)

		result = {}
		process_domain_config("#{directory}/domain-config.json", result) if File.exists? "#{directory}/domain-config.json"
		result[:direct] = static_files unless static_files.empty?
		result[:dynamic] = static_web_files unless static_web_files.empty?
		result[:internal] = internal_files unless internal_files.empty?
		result
	end

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

	def process_internal(directory, domain)
		return {} unless File.directory? directory

		layout_files = process_layouts("#{directory}/layouts", domain)
		partial_files = process_partials("#{directory}/partials", domain)

		result = {}
		result[:layouts] = layout_files unless layout_files.empty?
		result[:partials] = partial_files unless layout_files.empty?
		result
	end

	def process_web_folder(directory, domain)
		return {} unless File.directory? directory
		config = {}

		@processors.each do |processor|
			puts ' '*12 + " searching for: #{processor.name} in: #{directory}"
			Dir.glob("#{directory}/**/#{processor.glob}").each do |file|
				name = file.gsub("#{directory}/", '')
				language, path = retrieve_info name
				web_name = '/' + processor.target_name(name).gsub(' ', '-').downcase

				puts "name: #{name} language: #{language} web_name: #{web_name}"

				target_name = "/contents/#{domain}/web#{web_name}"
				target_file = "#{@target_web_dir}#{target_name}"
				puts "name: #{name} language: #{language} web_name: #{web_name}"

				html_data, metadata = processor.process_file file

				puts ' '*18 + "generating file: #{target_file} Length: #{html_data.length}"
				target_dir = File.dirname target_file
				FileUtils.mkdir_p target_dir unless Dir.exists? target_dir

				File.write target_file, html_data

				config[web_name] = {
					plugin_url: target_name,
					cacheable: true,
					metadata: metadata
				}
			end
		end

		config
	end

	def process_folder(directory, domain, replace_dir=nil)
		return {} unless File.directory? directory
		config = {}

		if replace_dir.nil?
			puts "BEFORE REPLACE DIR #{directory}"
			replace_dir = directory.split('/')
			replace_dir.pop
			replace_dir = replace_dir.join('/')
		end

		puts "REPLACE DIR #{replace_dir}"

		@processors.each do |processor|
			puts ' '*12 + " searching for: #{processor.name} in: #{directory}"
			Dir.glob("#{directory}/**/#{processor.glob}").each do |file|
				internal_name = file.gsub("#{replace_dir}/", '')

				puts "name: #{internal_name} internal_name: #{internal_name}"

				target_name = "/contents/#{domain}/internal/#{internal_name}"
				target_file = "#{@target_web_dir}#{target_name}"
				html_data, metadata = processor.process_file file

				puts ' '*18 + "generating file: #{target_file} Length: #{html_data.length}"
				target_dir = File.dirname target_file
				FileUtils.mkdir_p target_dir unless Dir.exists? target_dir

				File.write target_file, html_data

				config[internal_name] = {
					plugin_url: target_name,
					cacheable: true,
					metadata: metadata
				}
			end
		end

		config
	end

	def process_layouts(directory, domain)
		puts "Processing layouts under: #{directory} Domain: #{domain}"

		result = {}
		Dir.glob("#{directory}/**/layout.json").each do |file|
			puts "Processing #{file}"

			begin
				layout_config = JSON.parse File.read file
				replace_dir = File.dirname(file).split('/')
				replace_dir.pop
				replace_dir.pop
				replace_dir = replace_dir.join('/')
				config = {
					'styles' => {
						'_general' => {
							'direct' => process_folder(File.join(File.dirname(file), 'direct'), domain, replace_dir),
							'dynamic' => process_folder(File.join(File.dirname(file), 'dynamic'), domain, replace_dir),
							'assets' => process_assets(File.join(File.dirname(file), 'assets'))
						}
					}
				}

				puts JSON.pretty_generate config

				layout_config['styles'].each_pair do |name, cfg|
					config['styles'][name] = {} if config['styles'][name].nil?
					config['styles'][name]['entry_point'] = cfg['entry_point']
				end

				result[layout_config['name']] = config
			rescue => e
				puts "Error processing template #{file}"
				puts e.inspect
				puts 'Backtrace '+'-'*200
				e.backtrace.each do |line|
					puts line
				end
			end
		end
		result
	end

	def process_partials(directory, domain)
		result = {}

		Dir.glob("#{directory}/**/partials.json").each do |file|
			begin
				partial_config = JSON.parse File.read file
				partial_folder = File.dirname(file)

				partial_config.each_pair do |name, file|
					@processors.each do |processor|
						if processor.can_handle? file
							internal_name = file.gsub("#{partial_folder}/", '')

							web_name = processor.target_name(internal_name).gsub(' ', '-').downcase
							target_name = "/contents/#{domain}/partials/#{web_name}"
							target_file = "#{@target_web_dir}#{target_name}"

							html_data, metadata = processor.process_file File.join partial_folder, file

							puts ' '*18 + "generating partial file: #{target_file} Length: #{html_data.length}"
							target_dir = File.dirname target_file
							FileUtils.mkdir_p target_dir unless Dir.exists? target_dir

							File.write target_file, html_data

							result[name] = {
								plugin_url: target_name,
								cacheable: true,
								metadata: metadata
							}
						end
					end
				end
			rescue => e
				puts "Error processing partial #{file}"
				puts e.inspect
				puts e.backtrace.inspect
			end
		end
		result
	end

	def retrieve_info(path)
		data = path.split('/')
		language = data.shift
		return language, data.join('/')
	end

	def process_domain_config(file, subdomain_config)
		domain_config = JSON.parse File.read file
		subdomain_config[:config] = domain_config['config'] unless domain_config['config'].nil?
		subdomain_config[:redirects] = domain_config['redirects'] unless domain_config['redirects'].nil?
	end
end
