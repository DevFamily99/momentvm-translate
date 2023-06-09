class AddTeamIdToTranslations < ActiveRecord::Migration[5.2]
  def change
    add_reference :translations, :team, foreign_key: true
  end
end
