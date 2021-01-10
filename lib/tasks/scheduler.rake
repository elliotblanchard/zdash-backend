desc "This task is called by the Heroku scheduler add-on"
task :get_latest_transactions => :environment do
  puts "Updating feed..."
  puts "done."
end