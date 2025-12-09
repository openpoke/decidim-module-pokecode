# frozen_string_literal: true

namespace :decidim do
  # override of the original upgrade task to include pokecode tasks
  desc "Performs upgrade tasks (migrations, node, docs )."
  task upgrade: [
    :choose_target_plugins,
    :"decidim:upgrade_app",
    :"railties:install:migrations",
    :"decidim:upgrade:migrations",
    :"decidim:upgrade:webpacker",
    # it would be nice to remove this task in the future
    # but for now we keep it to as it requires access to a database
    :"decidim_api:generate_docs",
    :"pokecode:copy_config_files"
  ]
end
