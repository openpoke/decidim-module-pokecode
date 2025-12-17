# frozen_string_literal: true

namespace :decidim do
  # override of the original upgrade task to include pokecode tasks
  desc "Performs upgrade tasks (migrations, node, docs )."
  task upgrade: [
    :choose_target_plugins,
    :"decidim:upgrade_app",
    :"decidim:upgrade:shakapacker_npm",
    :"railties:install:migrations",
    :"decidim:upgrade:migrations",
    :"decidim:upgrade:shakapacker",
    # We will generate the api docs in the Dockerfile build step
    # :"decidim_api:generate_docs",
    :"pokecode:copy_config_files"
  ]
end
