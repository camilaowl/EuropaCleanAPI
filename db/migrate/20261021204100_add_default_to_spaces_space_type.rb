class AddDefaultToSpacesSpaceType < ActiveRecord::Migration[8.1]
  def change
    change_column_default :spaces, :space_type, from: nil, to: "home"
    change_column_null :spaces, :space_type, false, "home"
  end
end
