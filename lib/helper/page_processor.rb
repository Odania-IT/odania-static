require_relative '../processors/html_processor'
require_relative '../processors/markdown_processor'
require_relative '../processors/pre_processor'

class PageProcessor
	def initialize
		@processors = [
			MarkdownProcessor.new,
			HtmlProcessor.new
		]
	end

	def process_pages(directory, domain, subdomain, type, prefix='')
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
				full_web_name = "#{prefix}#{full_domain.empty? ? '' : '/' + full_domain}#{web_name}"

				puts "name: #{name} web_name: #{web_name} full_web_name: #{full_web_name}"
				html_data, metadata = processor.process_file file
				config[type][web_name] = metadata.merge({
																		 path: web_name,
																		 domain: domain,
																		 subdomain: subdomain,
																		 full_domain: full_domain,
																		 full_path: full_web_name,
																		 cacheable: true
																	 })
				idx_data = config[type][web_name].merge(content: html_data)

				path = "/api/#{type}?id=#{full_web_name}"
				req = Net::HTTP::Post.new(path, initheader = {'Content-Type' => 'application/json'})
				req.body = {data: idx_data}.to_json

				response = Net::HTTP.new($core_uri, $core_port).start { |http| http.request(req) }
				unless 200.eql? response.code.to_i
					puts "ERROR: Could not index #{full_web_name}!"
					puts response.inspect
				end
			end
		end

		config
	end
end
