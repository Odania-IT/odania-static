module PreProcessor
	class << self
		def process(content)
			# Detect metadata
			metadata = {}
			if content.start_with? '---'
				end_idx = content.index('---', 4)

				yaml_metadata = content[0, end_idx]
				begin
					metadata = YAML.load(yaml_metadata)
				rescue => e
					puts "Error parsing yaml metadata!! #{e.inspect}"
					e.backtrace.each do |line|
						puts e
					end
					puts yaml_metadata
				end
				content = content[end_idx+3..-1].strip
			end

			return content, metadata
		end
	end
end
