require 'rugged'
require 'linguist'
require 'faraday'
require 'json'
require 'octokit'

repo = Rugged::Repository.new('./code')
project = Linguist::Repository.new(repo, repo.head.target_id)

conn = Faraday.new(:url => ENV.fetch("APP_URL")) do |config|
  config.adapter Faraday.default_adapter
end

# discover languages available in this repo
path = "/repos/#{ENV.fetch("GITHUB_USER")}/#{ENV.fetch("GITHUB_REPO")}"
tags = project.languages.keys

puts "posting #{tags}: to #{path}"

res = conn.put do |req|
  req.url "/repos/#{ENV.fetch("GITHUB_USER")}/#{ENV.fetch("GITHUB_REPO")}"
  req.headers['Content-Type'] = 'application/json'
  req.headers['Authorization'] = "Basic #{ENV.fetch("ACCESS_TOKEN")}"
  req.body = {
    task_id: ENV.fetch("TASK_ID").to_i,
    tags: project.languages.keys
  }.to_json
end
puts res.inspect

# create message action if issues are turned off
client = Octokit::Client.new(:access_token => ENV.fetch("GITHUB_TOKEN"))
repo = client.repository(ENV.fetch("GITHUB_USER") + '/' + ENV.fetch("GITHUB_REPO"))

unless repo.has_issues
  res = conn.post do |req|
    req.url '/actions'
    req.headers['Content-Type'] = 'application/json'
    req.headers['Authorization'] = "Basic #{ENV.fetch("ACCESS_TOKEN")}"
    req.body = {
      kind: 'message',
      repo_id: repo.id,
      task_id: ENV.fetch("TASK_ID").to_i,
      body: "
        I noticed that issues aren't enabled on %{repo_full_name}. 
        I will sometimes create issues for urgent problems with your
        project such as security vulnerabilities, you should consider turning these on!
      "
    }.to_json
  end
  puts res.inspect
end

# create message action if continuous integration turned off
statuses = client.statuses(ENV.fetch("GITHUB_USER") + '/' + ENV.fetch("GITHUB_REPO"), "HEAD")

unless statuses.length > 0
  res = conn.post do |req|
    req.url '/actions'
    req.headers['Content-Type'] = 'application/json'
    req.headers['Authorization'] = "Basic #{ENV.fetch("ACCESS_TOKEN")}"
    req.body = {
      kind: 'message',
      repo_id: repo.id,
      task_id: ENV.fetch("TASK_ID"),
      body: "
        It looks like continuous integration isn't enabled on %{repo_full_name}. 
        I work best alongside a CI service so that you can have confidence
        in my changes!
      "
    }.to_json
  end
  puts res.inspect
end
