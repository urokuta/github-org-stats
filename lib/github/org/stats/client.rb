require 'octokit'
module Github
  module Org
    module Stats
      class Client
        attr_accessor :client
        def initialize(access_token:, org_name:)
          @client = Octokit::Client.new(access_token: access_token)
          @org_name = org_name
        end

        def owner_team
          teams = @client.org_teams(@org_name)
          teams.find{|t| t[:slug] == "owners"}
        end

        def org_repos
          team_id = owner_team[:id]
          @client.team_repositories(team_id)
        end

        # if you'd like to get last week, specify 1 as week
          # in default, get this week num of commits
        def commit_stats_group_by_user(repo_id:, week: 0)
          today = Date.today
          week_start_day = today - today.wday - (week * 7)
          github_week_ts = (week_start_day.to_time + 9*60*60).to_i
          user_stats = @client.contributors_stats(repo_id)
          return [] if user_stats.nil? || user_stats.empty?
          stats = user_stats.map do |user_stat|
            commits = user_stat[:weeks].find{|us| us[:w] == github_week_ts}[:c]
            user_name = user_stat[:author][:login]
            {user: user_name, commits: commits}
          end
          stats.reduce({}){|h, v|h.merge({v[:user] => v[:commits]})}
        end

        def commit_stats_all_repo(week: 0)
          repos = org_repos
          result = org_repos.map do |org_repo|
            repo_id = org_repo[:id]
            stats = commit_stats_group_by_user(repo_id: repo_id, week: week)
          end
        end

        def summary_commits_all_repo(week: 0)
          commits = commit_stats_all_repo(week: week)
          commits.inject(Hash.new(0)){|h, user_hash| user_hash.inject(h){|h2, kv|  h2[kv[0]] += kv[1]; h2}; h}
        end
      end
    end
  end
end
