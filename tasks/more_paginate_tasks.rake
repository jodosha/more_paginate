namespace :more_paginate do
  desc "Install more_paginate"
  task :install => :environment do
    require "fileutils"
    FileUtils.cp File.expand_path(File.dirname(__FILE__) + "/../assets/more_paginate.js"), File.join(Rails.public_path, "javascripts")
  end

  desc "Uninstall more_paginate"
  task :uninstall => :environment do
    require "fileutils"
    FileUtils.rm File.join(Rails.public_path, "javascripts", "more_paginate.js")
  end
end
