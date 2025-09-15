# Jekyll plugin to support ==highlight== syntax
module Jekyll
  module HighlightFilter
    def highlight_text(input)
      return input if input.nil?
      # Convert ==text== to <mark>text</mark>
      input.gsub(/==([^=]+)==/, '<mark>\1</mark>')
    end
  end
end

Liquid::Template.register_filter(Jekyll::HighlightFilter)
