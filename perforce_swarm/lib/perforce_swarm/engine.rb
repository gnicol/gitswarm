module PerforceSwarm
  class Engine < ::Rails::Engine
    # Require our api changes before GitLab's in order to influence the api before it is mounted
    config.before_initialize do
      Dir["#{Rails.root}/perforce_swarm/lib/api/*.rb"].each { |file| require file }
    end

    # Gitlab requires all their libs in an initializer, (config/initializers/2_app.rb)
    # So we will go ahead and do the same for ourselves
    initializer 'swarm_load_libs' do
      Dir["#{Rails.root}/perforce_swarm/lib/**/*.rb"].each { |file| require file }

      # Autoload classes from shell when needed
      shell_path  = File.expand_path(Gitlab.config.gitlab_shell.path)

      # we can't autoload the shell version of PerforceSwarm::GitFusion since
      # the same namespace is defined in Gitlab, so we explicitly require it.
      fusion_path = File.join(shell_path, 'perforce_swarm', 'git_fusion.rb')
      require fusion_path if File.exist?(fusion_path)

      PerforceSwarm.autoload :Mirror,                 File.join(shell_path, 'perforce_swarm', 'mirror')
      PerforceSwarm.autoload :Repo,                   File.join(shell_path, 'perforce_swarm', 'repo')
      PerforceSwarm.autoload :GitFusionRepo,          File.join(shell_path, 'perforce_swarm', 'git_fusion_repo')
      PerforceSwarm.autoload :GitlabConfig,           File.join(shell_path, 'perforce_swarm', 'config')
      PerforceSwarm.autoload :MirrorLockSocketServer, File.join(shell_path, 'perforce_swarm', 'mirror_lock_socket')
      PerforceSwarm::GitFusion.autoload :Config,      File.join(shell_path, 'perforce_swarm', 'config')
      PerforceSwarm::P4.autoload :Connection,         File.join(shell_path, 'perforce_swarm', 'p4', 'connection')
      PerforceSwarm::P4.autoload :Spec,               File.join(shell_path, 'perforce_swarm', 'p4', 'spec', 'depot')
    end

    # We want our engine's migrations to be run when the main app runs db:migrate
    # It seems as though stand-alone initializers run too late so the logic is here
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end

      # from Ian Young September 11, 2015 at 5:06 pm
      # https://blog.pivotal.io/labs/labs/leave-your-migrations-in-your-rails-engines
      # these extra paths are required to ensure our migrations get marked as applied
      ActiveRecord::Tasks::DatabaseTasks.migrations_paths |= app.config.paths['db/migrate'].to_a
      ActiveRecord::Migrator.migrations_paths             |= app.config.paths['db/migrate'].to_a

      # Include our engine's fixtures in seed-fu
      SeedFu.fixture_paths << Rails.root.join('perforce_swarm/db/fixtures').to_s
      SeedFu.fixture_paths << Rails.root.join('perforce_swarm/db/fixtures/' + Rails.env).to_s
    end

    initializer :engine_middleware do |app|
      # Engine's public folder is searched first for assets
      if app.config.serve_static_files
        app.middleware.insert_before(Gitlab::Middleware::Static, ::ActionDispatch::Static, "#{root}/public")
      end

      # Override error pages (500) with our own versions
      app.middleware.insert_after(
        ::ActionDispatch::ShowExceptions,
        ::ActionDispatch::ShowExceptions,
        ::ActionDispatch::PublicExceptions.new("#{root}/public")
      )
    end

    initializer :assets_precompile do |app|
      app.config.assets.precompile += %w(favicon.ico application_overrides.js application_overrides.css)
    end
  end

  def self.edition
    unless defined? GITSWARM_EDITION
      const_set(:GITSWARM_EDITION, File.exist?(Rails.root.join('CHANGELOG-EE')) ? 'ee' : 'ce')
    end
    GITSWARM_EDITION
  end

  def self.ee?
    edition == 'ee'
  end

  def self.ce?
    edition == 'ce'
  end

  def self.short_name
    ce? ? 'GitSwarm' : 'GitSwarm EE'
  end

  def self.long_name
    ce? ? 'GitSwarm' : 'GitSwarm Enterprise Edition'
  end

  def self.package_name
    ce? ? 'gitswarm' : 'gitswarm-ee'
  end

  def self.gitlab_name
    ce? ? 'GitLab CE' : 'GitLab EE'
  end

  module ConfigurationExtension
    def initialize(*)
      super

      # Change the railties order so our engine comes first
      # This allows our routes and asset_paths to take precedence
      @railties_order = [PerforceSwarm::Engine, :main_app, :all]

      # Add our own directories as an rails autoload path. Gitlab adds theirs,
      # so doing ours first here allows our files to take precedence.
      # The GitLab paths that we are matching here can be found in their config/application.rb
      paths.add 'perforce_swarm/lib', autoload: true
      paths.add 'perforce_swarm/app/models/hooks', autoload: true
      paths.add 'perforce_swarm/app/models/concerns', autoload: true
      paths.add 'perforce_swarm/app/models/project_services', autoload: true
      paths.add 'perforce_swarm/app/models/members', autoload: true
    end
  end
end

# Inject our custom config into the main rails application
class Rails::Application::Configuration
  prepend PerforceSwarm::ConfigurationExtension
end
