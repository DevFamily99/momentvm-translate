namespace :migrate do
  desc "Migrate translations to teams"
  task teams: :environment do
    team = nil
    if Team.all.count == 0
      team = Team.new
      team.name = "STOKKE"
      team.save
      puts "Created team"
    else
      puts "Team already exists"
      team = Team.first
    end

    Translation.all.each do |t|
      if t.team == team
        next
      end
      t.team = team
      t.save
    end
  end

end
