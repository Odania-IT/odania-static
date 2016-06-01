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

		@data_to_idx = Hash.new { |hash, key| hash[key] = {} }
	end

	def convert
		FileUtils.mkdir_p "#{@target_web_dir}/contents" unless Dir.exists? "#{@target_web_dir}/contents"

		config = Hash.new { |hash, key| hash[key] = {} }
		Dir.glob("#{@static_dir}/contents/**/web").each do |directory|
			parts = directory.split('/')
			parts.pop
			subdomain = parts.pop
			domain = parts.pop

			puts
			puts
			puts "web domain: #{domain} sub_domain: #{subdomain} ======================================================================================"

			config[domain][subdomain] = process_pages(directory, domain, subdomain, :web)
		end

		Dir.glob("#{@static_dir}/contents/**/partials").each do |directory|
			parts = directory.split('/')
			parts.pop
			subdomain = parts.pop
			domain = parts.pop

			puts
			puts
			puts "partials domain: #{domain} sub_domain: #{subdomain} ======================================================================================"

			config[domain][subdomain] = process_pages(directory, domain, subdomain, :partials)
		end

		config
	end

	private

	def process_pages(directory, domain, subdomain, type)
		config = Hash.new { |hash, key| hash[key] = {} }

		@processors.each do |processor|
			puts ' '*12 + " searching for: #{processor.name} in: #{directory}"
			Dir.glob("#{directory}/**/#{processor.glob}").each do |file|
				name = file.gsub("#{directory}/", '')

				web_name = '/' + processor.target_name(name).gsub(' ', '-').downcase

				full_domain = "#{subdomain}.#{domain}"
				if '_general'.eql? domain
					full_domain = ''
				elsif '_general'.eql? subdomain
					full_domain = domain
				end
				full_web_name = "#{full_domain}#{web_name}"

				puts "name: #{name} web_name: #{web_name} full_web_name: #{full_web_name}"
				html_data, metadata = processor.process_file file
				config[type][web_name] = metadata.merge({path: web_name, domain: domain, subdomain: subdomain, full_domain: full_domain, full_path: full_web_name})
				idx_data = config[type][web_name].merge(content: html_data)

				path = "/api/#{type}?id=#{full_web_name}"
				req = Net::HTTP::Post.new(path, initheader = { 'Content-Type' => 'application/json'})
				req.body = {data: idx_data}.to_json

				response = Net::HTTP.new($core_uri, $core_port).start {|http| http.request(req) }
				unless 200.eql? response.code.to_i
					puts "ERROR: Could not index #{full_web_name}!"
					puts response.inspect
				end
			end
		end

		config
	end
end
