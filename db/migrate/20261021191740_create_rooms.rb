class CreateRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :rooms do |t|
      t.string :name
      t.string :room_type
      t.references :space, null: false, foreign_key: true

      t.timestamps
    end
  end
end
