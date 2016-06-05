class HtmlProcessor
	def name
		'html'
	end

	def glob
		'*.{html,html.erb}'
	end

	def target_name(name)
		name
	end

	def process_file(file)
		content = File.read file, encoding: 'utf-8'
		PreProcessor.process content
	end

	def can_handle?(file)
		return true if file.end_with? '.html'
		false
	end
end
