source 'https://rubygems.org'

# GitHub Pages compatible gems - pin to version compatible with Ruby 3.1.7
gem 'github-pages', '~> 232', group: :jekyll_plugins
gem 'jekyll-feed', '~> 0.12'
gem 'jekyll-sitemap'

# Pin activesupport to be compatible with Ruby 3.1.7 (GitHub Pages)
gem 'activesupport', '< 8.0'

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem 'tzinfo', '>= 1', '< 3'
  gem 'tzinfo-data'
end

# Performance-booster for watching directories on Windows
gem 'wdm', '~> 0.1.1', :platforms => [:mingw, :x64_mingw, :mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem 'http_parser.rb', '~> 0.6.0', :platforms => [:jruby]

# Note: webrick is needed for local development with Ruby 3.2+
# but GitHub Pages (Ruby 3.1.7) doesn't need it
# This is handled in the start-server-github-pages.sh script
