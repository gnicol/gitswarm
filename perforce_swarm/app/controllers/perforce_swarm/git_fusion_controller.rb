class PerforceSwarm::GitFusionController < ApplicationController
  def existing_project
    init_auto_create

    begin
      # get the desired project and throw if it is already mirrored
      @project = Project.find(params['project_id'])
      raise 'This project is already mirrored in Helix.' if @project.git_fusion_mirrored?
      raise 'This project is already associated to a Helix Git Fusion repository.' if @project.git_fusion_repo.present?

      # first verify we can talk to git-fusion successfully, add error out with details if we cannot
      begin
        PerforceSwarm::GitFusion.run(@fusion_server, 'info')
      rescue => error
        raise 'There was an error communicating with Helix Git Fusion: ' + error.message
      end

      # pre-flight checks against Git Fusion and Perforce
      creator = PerforceSwarm::GitFusion::AutoCreateRepoCreator.new(@fusion_server)
      creator.namespace(@project.namespace.name).project_path(@project.path)
      p4 = PerforceSwarm::P4::Connection.new(creator.config)
      p4.login
      creator.save_preflight(p4)

      @path_template = creator.depot_path + '/...'
    rescue => error
      @errors << error.message
    ensure
      p4.disconnect if p4
    end

    respond_to do |format|
      format.html { render partial: 'existing_project', layout: false }
      format.json { render json: { html: view_to_html_string('perforce_swarm/git_fusion/_existing_project') } }
    end
  end

  def new_project
    init_auto_create

    begin
      @repos = PerforceSwarm::GitFusionRepo.list(@fusion_server, current_user.username)
    rescue => e
      @errors << e.message
    end

    begin
      # attempt to connect to Perforce and ensure the desired project depot exists
      # we do this in its own rescue block so we only grab errors relevant to auto_create
      creator        = PerforceSwarm::GitFusion::AutoCreateRepoCreator.new(@fusion_server)
      p4             = PerforceSwarm::P4::Connection.new(creator.config)
      p4.login
      @project_depot = creator.project_depot
      @depot_exists  = PerforceSwarm::P4::Spec::Depot.exists?(p4, creator.project_depot)
      @path_template = creator.path_template.chomp('/') + '/...'
    rescue => auto_create_error
      @auto_create_errors << auto_create_error.message
    ensure
      p4.disconnect if p4
    end

    respond_to do |format|
      format.html { render partial: 'new_project', layout: false }
      format.json { render json: { html: view_to_html_string('perforce_swarm/git_fusion/_new_project') } }
    end
  end

  def reenable_helix_mirroring_redirect
    init_reenable
    flash[:notice] = 'Helix mirroring successfully re-enabled.' if @project.git_fusion_mirrored?
    redirect_to project_path(@project)
  end

  # gives us the status of the re-enable process for a specific project
  def reenable_helix_mirroring_status
    begin
      init_reenable
      @status = @project.git_fusion_reenable_status
      @error  = @project.git_fusion_enable_error
    rescue => e
      @status = Project::GIT_FUSION_REENABLE_ERROR
      @error  = e.message
    end

    render json: { status: @status, error: @error }
  end

  # re-enables helix mirroring on the specified project
  def reenable_helix_mirroring
    init_reenable

    # ensure the repo still exists, and the user re-enabling can see it
    error = nil
    begin
      server  = @project.git_fusion_server_id
      repo    = @project.git_fusion_repo_name
      repos   = PerforceSwarm::GitFusionRepo.list(server, current_user.username)
      message = "Either the repo '#{repo}' does not exist, or you do not have permission to access it."
      error   = message unless repos[repo]
    rescue => e
      error = e.message
    end

    if error
      render status: :bad_request, json: { status: 'error', error: error }
      return
    end

    # kick off and background the re-enable process
    job = fork do
      gitlab_shell  = File.expand_path(Gitlab.config.gitlab_shell.path)
      mirror_script = File.join(gitlab_shell, 'perforce_swarm', 'bin', 'gitswarm-mirror')
      args          = [mirror_script, 'reenable_mirroring',
                       @project.git_fusion_repo, @project.path_with_namespace]
      exec Shellwords.shelljoin(args)
    end
    Process.detach(job)
    logger.info("Helix Mirroring re-enable started on project '#{@project.name_with_namespace}' " \
                "by user '#{current_user.username}'")

    # we want to return once the above process has started, so we don't return until
    # either the child process is done, the re-enabling process has started, or
    # we hit a timeout
    begin
      Timeout.timeout(20) do
        sleep(0.1) until reenable_started?(job)
      end
    rescue Timeout::Error
      logger.error('reenable_helix_mirroring failed to start a re-enable shell task.')
    end

    render nothing: true
  end

  protected

  # boolean as to whether we've started the re-enable process - either the project
  # reports re-enabling as being in-progress, or the shell task has quit
  def reenable_started?(shell_pid)
    return true if @project.git_fusion_reenable_status == Project::GIT_FUSION_REENABLE_IN_PROGRESS
    # getpgid returns false if the argument PID doesn't exist (shell task completed or an error)
    return true unless Process.getpgid(shell_pid)
    false
  end

  def init_reenable
    @project = Project.find(params['project_id'])

    # ensure that we have a logged-in user, and that they have permission to re-enable the project
    if !current_user || !current_user.can?(:admin_project, @project)
      raise 'You do not have permissions to re-enable Helix mirroring on this project.'
    end

    # ensure that there is a git fusion repo that we want to re-enable
    raise 'Project is not associated with a Helix Git Fusion repository.' unless @project.git_fusion_repo.present?
  end

  def init_auto_create
    @fusion_server      = params['fusion_server']
    @errors             = []
    @repos              = []
    @project_depot      = ''
    @depot_exists       = false
    @auto_create_errors = []
    @path_template      = ''
  end
end
