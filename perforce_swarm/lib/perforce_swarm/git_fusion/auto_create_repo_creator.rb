module PerforceSwarm
  module GitFusion
    class AutoCreateRepoCreator < RepoCreator
      def self.validate_config(config)
        super(config)

        unless config.auto_create_configured?
          raise ConfigValidationError, 'Auto create is not configured properly.'
        end
      end

      def initialize(config_entry_id, namespace = nil, project_path = nil)
        super(config_entry_id)
        @namespace    = namespace
        @project_path = project_path
      end

      # returns the depot portion of the generated depot_path
      def project_depot
        PerforceSwarm::P4::Spec::Depot.id_from_path(path_template)
      end

      # generates the p4gf_config file that should be checked into Perforce under
      # //.git-fusion/repos/repo_name/p4gf_config
      def p4gf_config(stream = false)
        depot_branch_creation("#{depot_path}/{git_branch_name}")
        branch_mappings('master' => "#{depot_path}/master")
        super
      end

      def validate_depots(connection)
        depot_branch_creation("#{depot_path}/{git_branch_name}")
        super(connection)
      end

      # run pre-flight checks for:
      #  * project_depot pattern is valid
      #  * both //.git-fusion and the project depots exist
      #  * Git Fusion repo ID is not already in use (no p4gf_config for the specified repo ID)
      #  * Perforce has no content under the target project location
      # if any of the above conditions are not met, an exception is thrown
      def save_preflight(connection)
        if project_depot.include?('{namespace}') || project_depot.include?('{project-path}')
          raise 'Depot names cannot contain substitution variables ({namespace} or {project-path}).'
        end

        # ensure that the depots exist and there is not an existing p4gf_config file
        super(connection)

        if perforce_path_exists?(depot_path, connection)
          raise "It appears that there is already content in Helix at #{depot_path}."
        end
      end
    end
  end
end
