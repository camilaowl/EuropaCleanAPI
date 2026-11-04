class CreateItemTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :item_types do |t|
      t.string :item_type_key, null: false
      t.string :default_display_name, null: false
      t.string :icon_asset_key

      t.timestamps
    end

    add_index :item_types, :item_type_key, unique: true
  end
end