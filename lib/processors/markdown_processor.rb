require 'redcarpet'

class MarkdownProcessor
	attr_accessor :markdown

	def initialize
		self.markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
	end

	def name
		'markdown'
	end

	def glob
		'*.{md,md.erb}'
	end

	def target_name(name)
		name.gsub('.md', '.html')
	end

	def process_file(file)
		content, metadata = PreProcessor.process File.read(file, encoding: 'utf-8')
		content = self.markdown.render content
		return content, metadata
	end

	def can_handle?(file)
		return true if file.end_with? '.md'
		false
	end
end
