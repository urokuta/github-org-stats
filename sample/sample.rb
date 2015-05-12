require './github_org_stats'
gos = Github::Org::Stats::Client.new(access_token: "your token", org_name: "your org")
puts "fetching last week your org commits..."
last_week = gos.summary_commits_all_repo(week: 1)
puts last_week.inspect
puts "fetching this week your org commits..."
this_week = gos.summary_commits_all_repo
puts this_week.inspect
