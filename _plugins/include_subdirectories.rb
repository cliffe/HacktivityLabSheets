# Plugin to include markdown files from subdirectories in the labs collection
Jekyll::Hooks.register :site, :after_init do |site|
  # Find all markdown files in _labs and subdirectories
  labs_dir = File.join(site.source, '_labs')
  if Dir.exist?(labs_dir)
    Dir.glob(File.join(labs_dir, '**', '*.md')).each do |file|
      relative_path = file.sub(site.source + '/', '')
      
      # Skip if already in collection
      next if site.collections['labs'].docs.any? { |doc| doc.path == file }
      
      # Create a new document for this file
      doc = Jekyll::Document.new(file, {
        site: site,
        collection: site.collections['labs']
      })
      
      # Add to collection
      site.collections['labs'].docs << doc
    end
  end
end
