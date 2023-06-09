class CreateTranslationRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :translation_requests do |t|
      t.string :distant_key
      t.date :completed

      t.timestamps
    end
  end
end
