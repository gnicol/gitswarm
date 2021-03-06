require Rails.root.join('app', 'controllers', 'sessions_controller')

module PerforceSwarm
  module SessionsControllerExtension
    def create
      super
      GitFusion::RepoAccess.clear_cache(username: current_user.username) if current_user
    end

    # handle an "initial setup" state, where we have:
    # 1) one or two users
    # 2) one admin user that requires a password change
    # 3) if a non-admin user is given, it has the username 'gitswarm'
    def check_initial_setup
      return unless User.count <= 2

      # look for a regular user called 'gitswarm' if we have 2 users
      if User.count == 2
        user = (User.all - User.admins).last
        return unless user && user.username == 'gitswarm'
      end

      # look for an admin user that requires a password
      admin = User.admins.last
      return unless admin && admin.require_password?

      token = admin.generate_reset_token
      admin.save

      redirect_to edit_user_password_path(reset_password_token: token),
                  notice: 'Please create a password for your new account.'
    end
  end
end

class SessionsController < Devise::SessionsController
  respond_to :json
  protect_from_forgery except: [:create]
  prepend PerforceSwarm::SessionsControllerExtension
end
