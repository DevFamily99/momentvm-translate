namespace :clean do

  namespace :translations do
  
    desc "removed HashWithIndifferentAccess"
    task withindifferentaccess: :environment do
      replaced = []
      errors = []
      Translation.all.each do |translation|
      # [Translation.find(75)].each do |translation|
        next if translation.raw_body.nil?
        next if translation.raw_body.empty?
        if translation.raw_body.match "!ruby/"
          body_json = YAML.unsafe_load(translation.raw_body).to_json
          body_yaml = JSON.parse(body_json)
          # puts body_yaml
          translation.update_column :body, body_yaml
          replaced << translation.id
          # if translation.save
          #   replaced << translation.id
          # else
          #   errors << translation.id
          # end
        end
      end
      puts "Done cleaning."
      puts "Replaced #{replaced.count}"
      puts "Errors in: #{errors}"
    end

    desc "cleans translations that have values where its just a link id in a p tag"
    task p: :environment do
      issues = []
      translations_with_issues = []
      translations = [3439,3440,1554,4096,2750,4097,1911,1910,924,1192,499,728,500,2394,729,501,730,522,731,3523,2536,2630,732,523,734,502,733,521,2544,735,3631,4039,4036,4037,4038,3123,3124,3125,3126,737,548,551,736,2539,541,3803,3804,3805,3806,4134,4138,4135,4136,4137,4094,4095,3522,3630,3799,3800,3801,3802,3423,3424,3425,3426,4052,4053,4054,4055,4124,4128,4125,4126,4127,3431,3433,3432,3434,3795,3796,3797,3798,4098,4099,3520,3627,3427,3428,3429,3430,4031,4028,4029,4030,3698,3699,3700,3701,4132,4133,4129,4130,4131]
      translations = Translation.where(id: translations)
      translations.each do |tr|
        body = tr.body
        body.each do |key, value|
          if (/<p>[0-9]+<\/p>/).match(value)
            issues << value
            body[key] = value[/<p>([0-9]+)<\/p>/, 1]
            translations_with_issues << tr.id
          end
        end
        tr.save
      end
      puts translations_with_issues.uniq
    end


    task fake_text: :environment do
      faulty_translations = []
      Translation.all.each do |t|
        t.body.each do |key, value|
          if (/Hallo ich/).match(value)
            faulty_translations << t
          end
        end
      end
      puts faulty_translations.uniq.map {|t| t.id }.join(", ")
    end



  end

end
