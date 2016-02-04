class Hoe
  module Markdown
    def initialize_markdown
      self.readme_file = readme_file.sub(/\.txt$/, ".md")
      self.history_file = history_file.sub(/\.txt$/, ".md")
    end

    def define_markdown_tasks
      # do nothing
    end
  end
end
