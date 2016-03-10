class HtmlProcessor
	def name
		'html'
	end

	def glob
		'*.html'
	end

	def target_name(name)
		name
	end

	def process_file(file)
		content = File.read file
		PreProcessor.process content
	end

	def can_handle?(file)
		return true if file.end_with? '.html'
		false
	end
end
