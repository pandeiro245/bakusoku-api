class Api::Timecrowd < Api
  def initialize
    @api_host   = 'timecrowd.net'
    @secret_url = 'https://timecrowd.net/oauth/applications'
    super
  end

  def me
    return @me if @me
    @me = get('/api/v1/user/info', {})
  end

  def time_entries(team_id)
    page = 1
    res = []
    tasks = team_tasks(team_id, page)['tasks']
    while tasks.present?
      tasks.each do |task|
        team_task_time_entries(team_id, task['id']).each do |te|
          res.push(te)
        end
      end
      page += 1
      tasks = team_tasks(team_id, page)['tasks']
    end
    res
  end

  def team_tasks(team_id, page=1)
    get("/api/v1/teams/#{team_id}/tasks", {page: page})
  end

  def team_task_time_entries(team_id, task_id)
    get("/api/v1/teams/#{team_id}/tasks/#{task_id}/time_entries")
  end
end

