class CreateRoomTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :room_types do |t|
      t.string :room_type_key, null: false
      t.string :default_display_name, null: false
      t.string :icon_asset_key

      t.timestamps
    end

    add_index :room_types, :room_type_key, unique: true
  end
end