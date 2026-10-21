class CreateRoomItems < ActiveRecord::Migration[8.1]
  def change
    create_table :room_items do |t|
      t.string :name
      t.string :item_type
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
