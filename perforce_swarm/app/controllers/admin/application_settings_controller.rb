require Rails.root.join('app', 'controllers', 'admin', 'application_settings_controller')

module PerforceSwarm
  module AdminApplicationSettingsControllerExtension
    def application_setting_params
      super.merge(params.require(:application_setting).permit(:last_version_ignored))
    end

    def update
      # adds responses for json requests
      if @application_setting.update_attributes(application_setting_params)
        message = 'Application settings saved successfully'
        respond_to do |format|
          format.js { render json: { message: message }, content_type: 'text/json' }
          format.html { redirect_to admin_application_settings_path, notice: message }
        end
      else
        respond_to do |format|
          format.js { render json: { errors: @application_setting.errors }, status: 422, content_type: 'text/json' }
          format.html { render :show }
        end
      end
    end
  end
end

class Admin::ApplicationSettingsController < Admin::ApplicationController
  prepend PerforceSwarm::AdminApplicationSettingsControllerExtension
end
