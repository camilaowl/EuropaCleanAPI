room_types = [
  { key: "bedroom", name: "Bedroom", icon: "bedroom" },
  { key: "kitchen", name: "Kitchen", icon: "kitchen" },
  { key: "bathroom", name: "Bathroom", icon: "bathroom" },
  { key: "living_room", name: "Living Room", icon: "living_room" },
  { key: "office", name: "Office", icon: "office" },
  { key: "dining_room", name: "Dining Room", icon: "dining_room" },
  { key: "garage", name: "Garage", icon: "garage" },
  { key: "basement", name: "Basement", icon: "basement" },
  { key: "laundry_room", name: "Laundry Room", icon: "laundry_room" },
  { key: "attic", name: "Attic", icon: "attic" },
  { key: "hallway", name: "Hallway", icon: "hallway" },
  { key: "other", name: "Other", icon: "other" }
]

room_types.each do |type|
  RoomType.find_or_create_by!(room_type_key: type[:key]) do |record|
    record.default_display_name = type[:name]
    record.icon_asset_key = type[:icon]
  end
end

item_types = [
  # Room surfaces and fixtures
  { key: "floor", name: "Floor", icon: "floor" },
  { key: "carpet", name: "Carpet", icon: "carpet" },
  { key: "area_rug", name: "Area Rug", icon: "area_rug" },
  { key: "wall", name: "Wall", icon: "wall" },
  { key: "ceiling", name: "Ceiling", icon: "ceiling" },
  { key: "baseboard", name: "Baseboard", icon: "baseboard" },
  { key: "door", name: "Door", icon: "door" },
  { key: "door_frame", name: "Door Frame", icon: "door_frame" },
  { key: "door_handle", name: "Door Handle", icon: "door_handle" },
  { key: "window", name: "Window", icon: "window" },
  { key: "window_sill", name: "Window Sill", icon: "window_sill" },
  { key: "blinds", name: "Blinds", icon: "blinds" },
  { key: "curtains", name: "Curtains", icon: "curtains" },
  { key: "mirror", name: "Mirror", icon: "mirror" },
  { key: "shelf", name: "Shelf", icon: "shelf" },
  { key: "storage_cabinet", name: "Storage Cabinet", icon: "storage_cabinet" },
  { key: "storage_drawer", name: "Storage Drawer", icon: "storage_drawer" },
  { key: "light_fixture", name: "Light Fixture", icon: "light_fixture" },
  { key: "lamp", name: "Lamp", icon: "lamp" },
  { key: "light_switch", name: "Light Switch", icon: "light_switch" },
  { key: "electrical_outlet", name: "Electrical Outlet", icon: "electrical_outlet" },
  { key: "ceiling_fan", name: "Ceiling Fan", icon: "ceiling_fan" },
  { key: "air_vent", name: "Air Vent", icon: "air_vent" },
  { key: "radiator", name: "Radiator", icon: "radiator" },
  { key: "air_conditioner", name: "Air Conditioner", icon: "air_conditioner" },
  { key: "trash_can", name: "Trash Can", icon: "trash_can" },

  # Bedroom and nursery
  { key: "bed", name: "Bed", icon: "bed" },
  { key: "bed_frame", name: "Bed Frame", icon: "bed_frame" },
  { key: "headboard", name: "Headboard", icon: "headboard" },
  { key: "mattress", name: "Mattress", icon: "mattress" },
  { key: "bedding", name: "Bedding", icon: "bedding" },
  { key: "pillow", name: "Pillow", icon: "pillow" },
  { key: "nightstand", name: "Nightstand", icon: "nightstand" },
  { key: "dresser", name: "Dresser", icon: "dresser" },
  { key: "wardrobe", name: "Wardrobe", icon: "wardrobe" },
  { key: "closet", name: "Closet", icon: "closet" },
  { key: "bedroom_bench", name: "Bedroom Bench", icon: "bedroom_bench" },
  { key: "crib", name: "Crib", icon: "crib" },
  { key: "changing_table", name: "Changing Table", icon: "changing_table" },
  { key: "toy_box", name: "Toy Box", icon: "toy_box" },

  # Living room
  { key: "sofa", name: "Sofa", icon: "sofa" },
  { key: "armchair", name: "Armchair", icon: "armchair" },
  { key: "recliner", name: "Recliner", icon: "recliner" },
  { key: "ottoman", name: "Ottoman", icon: "ottoman" },
  { key: "coffee_table", name: "Coffee Table", icon: "coffee_table" },
  { key: "side_table", name: "Side Table", icon: "side_table" },
  { key: "television", name: "Television", icon: "television" },
  { key: "tv_stand", name: "TV Stand", icon: "tv_stand" },
  { key: "bookshelf", name: "Bookshelf", icon: "bookshelf" },
  { key: "fireplace", name: "Fireplace", icon: "fireplace" },

  # Kitchen and dining room
  { key: "sink", name: "Sink", icon: "sink" },
  { key: "faucet", name: "Faucet", icon: "faucet" },
  { key: "countertop", name: "Countertop", icon: "countertop" },
  { key: "backsplash", name: "Backsplash", icon: "backsplash" },
  { key: "kitchen_cabinet", name: "Kitchen Cabinet", icon: "kitchen_cabinet" },
  { key: "kitchen_drawer", name: "Kitchen Drawer", icon: "kitchen_drawer" },
  { key: "pantry", name: "Pantry", icon: "pantry" },
  { key: "refrigerator", name: "Refrigerator", icon: "refrigerator" },
  { key: "freezer", name: "Freezer", icon: "freezer" },
  { key: "oven", name: "Oven", icon: "oven" },
  { key: "stovetop", name: "Stovetop", icon: "stovetop" },
  { key: "range_hood", name: "Range Hood", icon: "range_hood" },
  { key: "microwave", name: "Microwave", icon: "microwave" },
  { key: "dishwasher", name: "Dishwasher", icon: "dishwasher" },
  { key: "coffee_maker", name: "Coffee Maker", icon: "coffee_maker" },
  { key: "kettle", name: "Kettle", icon: "kettle" },
  { key: "toaster", name: "Toaster", icon: "toaster" },
  { key: "blender", name: "Blender", icon: "blender" },
  { key: "food_processor", name: "Food Processor", icon: "food_processor" },
  { key: "stand_mixer", name: "Stand Mixer", icon: "stand_mixer" },
  { key: "air_fryer", name: "Air Fryer", icon: "air_fryer" },
  { key: "dining_table", name: "Dining Table", icon: "dining_table" },
  { key: "dining_chair", name: "Dining Chair", icon: "dining_chair" },
  { key: "bar_stool", name: "Bar Stool", icon: "bar_stool" },

  # Bathroom
  { key: "toilet", name: "Toilet", icon: "toilet" },
  { key: "bathtub", name: "Bathtub", icon: "bathtub" },
  { key: "shower", name: "Shower", icon: "shower" },
  { key: "shower_door", name: "Shower Door", icon: "shower_door" },
  { key: "shower_curtain", name: "Shower Curtain", icon: "shower_curtain" },
  { key: "bathroom_vanity", name: "Bathroom Vanity", icon: "bathroom_vanity" },
  { key: "medicine_cabinet", name: "Medicine Cabinet", icon: "medicine_cabinet" },
  { key: "bidet", name: "Bidet", icon: "bidet" },
  { key: "towel_rack", name: "Towel Rack", icon: "towel_rack" },
  { key: "exhaust_fan", name: "Exhaust Fan", icon: "exhaust_fan" },
  { key: "bath_mat", name: "Bath Mat", icon: "bath_mat" },
  { key: "soap_dispenser", name: "Soap Dispenser", icon: "soap_dispenser" },

  # Laundry room
  { key: "washing_machine", name: "Washing Machine", icon: "washing_machine" },
  { key: "clothes_dryer", name: "Clothes Dryer", icon: "clothes_dryer" },
  { key: "laundry_sink", name: "Laundry Sink", icon: "laundry_sink" },
  { key: "laundry_basket", name: "Laundry Basket", icon: "laundry_basket" },
  { key: "drying_rack", name: "Drying Rack", icon: "drying_rack" },
  { key: "ironing_board", name: "Ironing Board", icon: "ironing_board" },

  # Office
  { key: "desk", name: "Desk", icon: "desk" },
  { key: "office_chair", name: "Office Chair", icon: "office_chair" },
  { key: "computer", name: "Computer", icon: "computer" },
  { key: "monitor", name: "Monitor", icon: "monitor" },
  { key: "keyboard", name: "Keyboard", icon: "keyboard" },
  { key: "mouse", name: "Mouse", icon: "mouse" },
  { key: "printer", name: "Printer", icon: "printer" },

  # Garage, basement, and utility areas
  { key: "garage_door", name: "Garage Door", icon: "garage_door" },
  { key: "workbench", name: "Workbench", icon: "workbench" },
  { key: "tool_cabinet", name: "Tool Cabinet", icon: "tool_cabinet" },
  { key: "storage_bin", name: "Storage Bin", icon: "storage_bin" },
  { key: "water_heater", name: "Water Heater", icon: "water_heater" },
  { key: "furnace", name: "Furnace", icon: "furnace" },
  { key: "boiler", name: "Boiler", icon: "boiler" },
  { key: "dehumidifier", name: "Dehumidifier", icon: "dehumidifier" },

  # Other common household items
  { key: "high_chair", name: "High Chair", icon: "high_chair" },
  { key: "exercise_machine", name: "Exercise Machine", icon: "exercise_machine" },
  { key: "yoga_mat", name: "Yoga Mat", icon: "yoga_mat" },
  { key: "pet_bed", name: "Pet Bed", icon: "pet_bed" },
  { key: "pet_bowl", name: "Pet Bowl", icon: "pet_bowl" },
  { key: "litter_box", name: "Litter Box", icon: "litter_box" },
  { key: "plant_pot", name: "Plant Pot", icon: "plant_pot" },
  { key: "vacuum_cleaner", name: "Vacuum Cleaner", icon: "vacuum_cleaner" },
  { key: "furniture", name: "Furniture", icon: "furniture" },
  { key: "other", name: "Other", icon: "other" }
]

item_types.each do |type|
  ItemType.find_or_create_by!(item_type_key: type[:key]) do |record|
    record.default_display_name = type[:name]
    record.icon_asset_key = type[:icon]
  end
end
