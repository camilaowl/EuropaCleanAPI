class CreateSpaces < ActiveRecord::Migration[8.1]
  def change
    create_table :spaces do |t|
      t.string :name
      t.string :space_type
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
