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
		'*.md'
	end

	def target_name(name)
		name.gsub('.md', '.html')
	end

	def process_file(file)
		content = self.markdown.render File.read(file, encoding: 'utf-8')
		PreProcessor.process content
	end

	def can_handle?(file)
		return true if file.end_with? '.md'
		false
	end
end
