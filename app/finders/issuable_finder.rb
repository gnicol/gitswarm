# IssuableFinder
#
# Used to filter Issues and MergeRequests collections by set of params
#
# Arguments:
#   klass - actual class like Issue or MergeRequest
#   current_user - which user use
#   params:
#     scope: 'created-by-me' or 'assigned-to-me' or 'all'
#     state: 'open' or 'closed' or 'all'
#     group_id: integer
#     project_id: integer
#     milestone_id: integer
#     assignee_id: integer
#     search: string
#     label_name: string
#     sort: string
#
require_relative 'projects_finder'

class IssuableFinder
  NONE = '0'

  attr_accessor :current_user, :params

  def execute(current_user, params)
    @current_user = current_user
    @params = params

    items = init_collection
    items = by_scope(items)
    items = by_state(items)
    items = by_group(items)
    items = by_project(items)
    items = by_search(items)
    items = by_milestone(items)
    items = by_assignee(items)
    items = by_author(items)
    items = by_label(items)
    items = sort(items)
  end

  private

  def init_collection
    table_name = klass.table_name

    if project
      if Ability.abilities.allowed?(current_user, :read_project, project)
        project.send(table_name)
      else
        []
      end
    elsif current_user && params[:authorized_only].presence && !current_user_related?
      klass.of_projects(current_user.authorized_projects).references(:project)
    else
      klass.of_projects(ProjectsFinder.new.execute(current_user)).references(:project)
    end
  end

  def by_scope(items)
    case params[:scope]
    when 'created-by-me', 'authored' then
      items.where(author_id: current_user.id)
    when 'all' then
      items
    when 'assigned-to-me' then
      items.where(assignee_id: current_user.id)
    else
      raise 'You must specify default scope'
    end
  end

  def by_state(items)
    case params[:state]
    when 'closed'
      items.closed
    when 'all'
      items
    when 'opened'
      items.opened
    else
      raise 'You must specify default state'
    end
  end

  def by_group(items)
    if params[:group_id].present?
      items = items.of_group(Group.find(params[:group_id]))
    end

    items
  end

  def by_project(items)
    if params[:project_id].present?
      items = items.of_projects(params[:project_id])
    end

    items
  end

  def by_search(items)
    if params[:search].present?
      items = items.search(params[:search])
    end

    items
  end

  def sort(items)
    items.sort(params[:sort])
  end

  def by_milestone(items)
    if params[:milestone_title].present?
      milestone_ids = (params[:milestone_title] == NONE ? nil : Milestone.where(title: params[:milestone_title]).pluck(:id))
      items = items.where(milestone_id: milestone_ids)
    end

    items
  end

  def by_assignee(items)
    if params[:assignee_id].present?
      items = items.where(assignee_id: (params[:assignee_id] == NONE ? nil : params[:assignee_id]))
    end

    items
  end

  def by_author(items)
    if params[:author_id].present?
      items = items.where(author_id: (params[:author_id] == NONE ? nil : params[:author_id]))
    end

    items
  end

  def by_label(items)
    if params[:label_name].present?
      label_names = params[:label_name].split(",")

      item_ids = LabelLink.joins(:label).
        where('labels.title in (?)', label_names).
        where(target_type: klass.name).pluck(:target_id)

      items = items.where(id: item_ids)
    end

    items
  end

  def project
    Project.where(id: params[:project_id]).first if params[:project_id].present?
  end

  def current_user_related?
    params[:scope] == 'created-by-me' || params[:scope] == 'authored' || params[:scope] == 'assigned-to-me'
  end
end
