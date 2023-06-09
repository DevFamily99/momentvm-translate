namespace :test_scripts do

  namespace :run do
  
    desc "HashWithIndifferentAccess"
    task translation: :environment do
      translation = Translation.find 75
      puts translation.raw_body
      body_json = YAML.unsafe_load(translation.raw_body).to_json
      body_yaml = JSON.parse(body_json).to_yaml
      puts body_yaml
    end
  end
end
