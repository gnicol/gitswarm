# file only present in EE
require Rails.root.join('features', 'steps', 'project', 'pages') if PerforceSwarm.ee?

class Spinach::Features::ProjectPages < Spinach::FeatureSteps
  # EE-only step
  step 'I should see that GitLab Pages are disabled' do
    expect(page).to have_content('GitSwarm Pages are disabled')
  end
end
