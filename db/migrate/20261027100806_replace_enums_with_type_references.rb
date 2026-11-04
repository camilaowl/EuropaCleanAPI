class ReplaceEnumsWithTypeReferences < ActiveRecord::Migration[8.1]
  def up
    add_reference :rooms, :room_type, null: true, foreign_key: true
    add_reference :room_items, :item_type, null: true, foreign_key: true

    remove_column :rooms, :room_type
    remove_column :room_items, :item_type
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end