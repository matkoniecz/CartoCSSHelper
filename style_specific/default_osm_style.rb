
def get_expected_tag_status
    return [
        Status.new('access', '*', :ignored),
        Status.new('access', 'destination', :composite, {'highway'=>'service'}),
        Status.new('access', 'no', :composite, {'highway'=>'service'}),
        Status.new('access', 'private', :composite, {'highway'=>'service'}),
        Status.new('addr:housename', '*', :primary),
        Status.new('addr:housenumber', '*', :primary),
        Status.new('addr:interpolation', '*', :primary),
        Status.new('admin_level', '*', :ignored),
        Status.new('admin_level', '0', :ignored),
        Status.new('admin_level', '1', :ignored),
        Status.new('admin_level', '10', :composite, {'boundary'=>'administrative'}),
        Status.new('admin_level', '2', :composite, {'boundary'=>'administrative'}),
        Status.new('admin_level', '3', :composite, {'boundary'=>'administrative'}),
        Status.new('admin_level', '4', :composite, {'boundary'=>'administrative'}),
        Status.new('admin_level', '5', :composite, {'boundary'=>'administrative'}),
        Status.new('admin_level', '6', :composite, {'boundary'=>'administrative'}),
        Status.new('admin_level', '7', :composite, {'boundary'=>'administrative'}),
        Status.new('admin_level', '8', :composite, {'boundary'=>'administrative'}),
        Status.new('admin_level', '9', :composite, {'boundary'=>'administrative'}),
        Status.new('aerialway', '*', :ignored),
        Status.new('aerialway', 'cable_car', :primary),
        Status.new('aerialway', 'chair_lift', :primary),
        Status.new('aerialway', 'drag_lift', :primary),
        Status.new('aerialway', 'gondola', :primary),
        Status.new('aerialway', 'goods', :primary),
        Status.new('aerialway', 'platter', :primary),
        Status.new('aerialway', 'rope_tow', :primary),
        Status.new('aerialway', 'station', :primary),
        Status.new('aeroway', 'aerodrome', :primary),
        Status.new('aeroway', 'apron', :primary),
        Status.new('aeroway', 'gate', :composite, {'ref'=>'3'}),
        Status.new('aeroway', 'helipad', :primary),
        Status.new('aeroway', 'runway', :primary),
        Status.new('aeroway', 'taxiway', :primary),
        Status.new('aeroway', 'terminal', :primary),
        Status.new('amenity', '*', :ignored),
        Status.new('amenity', 'atm', :primary),
        Status.new('amenity', 'bank', :primary),
        Status.new('amenity', 'bar', :primary),
        Status.new('amenity', 'bicycle_rental', :primary),
        Status.new('amenity', 'biergarten', :primary),
        Status.new('amenity', 'bus_station', :primary),
        Status.new('amenity', 'cafe', :primary),
        Status.new('amenity', 'car_sharing', :primary),
        Status.new('amenity', 'cinema', :primary),
        Status.new('amenity', 'college', :primary),
        Status.new('amenity', 'courthouse', :primary),
        Status.new('amenity', 'drinking_water', :primary),
        Status.new('amenity', 'embassy', :primary),
        Status.new('amenity', 'emergency_phone', :primary),
        Status.new('amenity', 'fast_food', :primary),
        Status.new('amenity', 'fire_station', :primary),
        Status.new('amenity', 'fuel', :primary),
        Status.new('amenity', 'grave_yard', :primary),
        Status.new('amenity', 'hospital', :primary),
        Status.new('amenity', 'kindergarten', :primary),
        Status.new('amenity', 'library', :primary),
        Status.new('amenity', 'parking', :primary),
        Status.new('amenity', 'pharmacy', :primary),
        Status.new('amenity', 'place_of_worship', :primary),
        Status.new('amenity', 'police', :primary),
        Status.new('amenity', 'post_box', :primary),
        Status.new('amenity', 'post_office', :primary),
        Status.new('amenity', 'prison', :primary),
        Status.new('amenity', 'pub', :primary),
        Status.new('amenity', 'recycling', :primary),
        Status.new('amenity', 'restaurant', :primary),
        Status.new('amenity', 'school', :primary),
        Status.new('amenity', 'shelter', :primary),
        Status.new('amenity', 'telephone', :primary),
        Status.new('amenity', 'theatre', :primary),
        Status.new('amenity', 'toilets', :primary),
        Status.new('amenity', 'university', :primary),
        Status.new('area', '*', :ignored),
        Status.new('area', 'no', :primary, {'barrier' => 'hedge'}),
        Status.new('area', 'yes', :primary, {'barrier' => 'hedge'}),
        Status.new('barrier', '*', :primary),
        Status.new('barrier', 'block', :primary),
        Status.new('barrier', 'bollard', :primary),
        Status.new('barrier', 'embankment', :primary),
        Status.new('barrier', 'gate', :primary),
        Status.new('barrier', 'hedge', :primary),
        Status.new('barrier', 'lift_gate', :primary),
        Status.new('bicycle', '*', :ignored),
        Status.new('bicycle', 'designated', :composite, {'highway'=>'path'}),
        Status.new('boundary', '*', :ignored),
        Status.new('boundary', 'administrative', :composite, {'admin_level'=>'2'}),
        Status.new('boundary', 'national_park', :primary),
        Status.new('brand', '*', :ignored),
        Status.new('bridge', '*', :ignored),
        Status.new('bridge', 'aqueduct', :composite, {'waterway'=>'river'}),
        Status.new('bridge', 'boardwalk', :composite, {'highway'=>'service'}),
        Status.new('bridge', 'cantilever', :composite, {'highway'=>'service'}),
        Status.new('bridge', 'covered', :composite, {'highway'=>'service'}),
        Status.new('bridge', 'low_water_crossing', :composite, {'highway'=>'service'}),
        Status.new('bridge', 'movable', :composite, {'highway'=>'service'}),
        Status.new('bridge', 'trestle', :composite, {'highway'=>'service'}),
        Status.new('bridge', 'viaduct', :composite, {'highway'=>'service'}),
        Status.new('bridge', 'yes', :composite, {'highway'=>'service'}),
        Status.new('building', '*', :primary),
        Status.new('building', 'cabin', :primary),
        Status.new('building', 'canopy', :primary),
        Status.new('building', 'garage', :primary),
        Status.new('building', 'garages', :primary),
        Status.new('building', 'glasshouse', :primary),
        Status.new('building', 'greenhouse', :primary),
        Status.new('building', 'kiosk', :primary),
        Status.new('building', 'mobile_home', :primary),
        Status.new('building', 'roof', :primary),
        Status.new('building', 'service', :primary),
        Status.new('building', 'shed', :primary),
        Status.new('building', 'shelter', :primary),
        Status.new('building', 'silo', :primary),
        Status.new('building', 'station', :primary),
        Status.new('building', 'storage_tank', :primary),
        Status.new('building', 'supermarket', :primary),
        Status.new('building', 'support', :primary),
        Status.new('building', 'tank', :primary),
        Status.new('building', 'tent', :primary),
        Status.new('capital', '*', :ignored),
        Status.new('capital', 'yes', :composite, {'place'=>'city'}),
        Status.new('construction', '*', :ignored),
        Status.new('construction', 'cycleway', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'living_street', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'motorway', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'motorway_link', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'primary', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'primary_link', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'residential', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'secondary', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'secondary_link', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'service', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'tertiary', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'tertiary_link', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'trunk', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'trunk_link', :composite, {'highway'=>'construction'}),
        Status.new('construction', 'unclassified', :composite, {'highway'=>'construction'}),
        Status.new('covered', '*', :ignored),
        Status.new('covered', 'yes', :composite, {'highway'=>'service'}),
        Status.new('culvert', '*', :ignored),
        Status.new('cutting', '*', :ignored),
        Status.new('denomination', '*', :ignored),
        Status.new('denomination', 'jehovahs_witness', :composite, {'amenity'=>'place_of_worship', 'religion'=>'christian'}),
        Status.new('disused', '*', :ignored),
        Status.new('ele', '*', :composite, {'natural'=>'peak'}),
        Status.new('embankment', '*', :ignored),
        Status.new('foot', '*', :ignored),
        Status.new('foot', 'designated', :composite, {'highway'=>'path'}),
        Status.new('generator:source', '*', :ignored),
        Status.new('generator:source', 'wind', :composite, {'power'=>'generator'}),
        Status.new('harbour', '*', :ignored),
        Status.new('highway', '*', :ignored),
        Status.new('highway', 'bridleway', :primary),
        Status.new('highway', 'bus_guideway', :primary),
        Status.new('highway', 'bus_stop', :primary),
        Status.new('highway', 'construction', :primary),
        Status.new('highway', 'cycleway', :primary),
        Status.new('highway', 'footway', :primary),
        Status.new('highway', 'ford', :primary),
        Status.new('highway', 'living_street', :primary),
        Status.new('highway', 'mini_roundabout', :primary),
        Status.new('highway', 'motorway', :primary),
        Status.new('highway', 'motorway_junction', :composite, {'name'=>'a'}),
        Status.new('highway', 'motorway_link', :primary),
        Status.new('highway', 'path', :primary),
        Status.new('highway', 'pedestrian', :primary),
        Status.new('highway', 'platform', :primary),
        Status.new('highway', 'primary', :primary),
        Status.new('highway', 'primary_link', :primary),
        Status.new('highway', 'proposed', :primary),
        Status.new('highway', 'raceway', :primary),
        Status.new('highway', 'residential', :primary),
        Status.new('highway', 'rest_area', :primary),
        Status.new('highway', 'road', :primary),
        Status.new('highway', 'runway', :ignored),
        Status.new('highway', 'secondary', :primary),
        Status.new('highway', 'secondary_link', :primary),
        Status.new('highway', 'service', :primary),
        Status.new('highway', 'services', :primary),
        Status.new('highway', 'steps', :primary),
        Status.new('highway', 'taxiway', :ignored),
        Status.new('highway', 'tertiary', :primary),
        Status.new('highway', 'tertiary_link', :primary),
        Status.new('highway', 'track', :primary),
        Status.new('highway', 'traffic_signals', :primary),
        Status.new('highway', 'trunk', :primary),
        Status.new('highway', 'trunk_link', :primary),
        Status.new('highway', 'turning_circle', :primary), #note: special topology is required
        Status.new('highway', 'turning_loop', :primary), #note: special topology is required
        Status.new('highway', 'unclassified', :primary),
        Status.new('historic', '*', :ignored),
        Status.new('historic', 'archaeological_site', :primary),
        Status.new('historic', 'castle_walls', :primary),
        Status.new('historic', 'citywalls', :primary),
        Status.new('historic', 'memorial', :primary),
        Status.new('horse', '*', :ignored),
        Status.new('horse', 'designated', :composite, {'highway'=>'path'}),
        Status.new('intermittent', '*', :ignored),
        Status.new('junction', '*', :ignored),
        Status.new('junction', 'yes', :composite, {'name'=>'a'}),
        Status.new('landuse', '*', :ignored),
        Status.new('landuse', 'allotments', :primary),
        Status.new('landuse', 'basin', :primary),
        Status.new('landuse', 'brownfield', :primary),
        Status.new('landuse', 'cemetery', :primary),
        Status.new('landuse', 'commercial', :primary),
        Status.new('landuse', 'conservation', :primary),
        Status.new('landuse', 'construction', :primary),
        Status.new('landuse', 'farm', :primary),
        Status.new('landuse', 'farmland', :primary),
        Status.new('landuse', 'farmyard', :primary),
        Status.new('landuse', 'field', :primary),
        Status.new('landuse', 'forest', :primary),
        Status.new('landuse', 'garages', :primary),
        Status.new('landuse', 'grass', :primary),
        Status.new('landuse', 'industrial', :primary),
        Status.new('landuse', 'landfill', :primary),
        Status.new('landuse', 'meadow', :primary),
        Status.new('landuse', 'military', :primary),
        Status.new('landuse', 'orchard', :primary),
        Status.new('landuse', 'quarry', :primary),
        Status.new('landuse', 'railway', :primary),
        Status.new('landuse', 'recreation_ground', :primary),
        Status.new('landuse', 'reservoir', :primary),
        Status.new('landuse', 'residential', :primary),
        Status.new('landuse', 'retail', :primary),
        Status.new('landuse', 'village_green', :primary),
        Status.new('landuse', 'vineyard', :primary),
        Status.new('layer', '*', :ignored),
        Status.new('layer', '1', :composite, {'highway' => 'service'}), #modifies ordering
        Status.new('layer', '2', :composite, {'highway' => 'service'}), #modifies ordering
        Status.new('layer', '3', :composite, {'highway' => 'service'}), #modifies ordering
        Status.new('layer', '4', :composite, {'highway' => 'service'}), #modifies ordering
        Status.new('layer', '5', :composite, {'highway' => 'service'}), #modifies ordering
        Status.new('layer', '-1', :composite, {'highway' => 'service'}), #modifies ordering
        Status.new('layer', '-2', :composite, {'highway' => 'service'}), #modifies ordering
        Status.new('layer', '-3', :composite, {'highway' => 'service'}), #modifies ordering
        Status.new('layer', '-4', :composite, {'highway' => 'service'}), #modifies ordering
        Status.new('layer', '-5', :composite, {'highway' => 'service'}), #modifies ordering
        Status.new('leisure', '*', :ignored),
        Status.new('leisure', 'common', :primary),
        Status.new('leisure', 'garden', :primary),
        Status.new('leisure', 'golf_course', :primary),
        Status.new('leisure', 'marina', :primary),
        Status.new('leisure', 'nature_reserve', :primary),
        Status.new('leisure', 'park', :primary),
        Status.new('leisure', 'picnic_table', :primary),
        Status.new('leisure', 'pitch', :primary),
        Status.new('leisure', 'playground', :primary),
        Status.new('leisure', 'recreation_ground', :primary),
        Status.new('leisure', 'slipway', :primary),
        Status.new('leisure', 'sports_centre', :primary),
        Status.new('leisure', 'stadium', :primary),
        Status.new('leisure', 'swimming_pool', :primary),
        Status.new('leisure', 'track', :primary),
        Status.new('lock', '*', :ignored),
        Status.new('lock', 'yes', :primary),
        Status.new('man_made', '*', :ignored),
        Status.new('man_made', 'breakwater', :primary),
        Status.new('man_made', 'cutline', :primary),
        Status.new('man_made', 'embankment', :primary),
        Status.new('man_made', 'groyne', :primary),
        Status.new('man_made', 'lighthouse', :primary),
        Status.new('man_made', 'mast', :primary),
        Status.new('man_made', 'pier', :primary),
        Status.new('man_made', 'power_wind', :ignored),
        Status.new('man_made', 'water_tower', :primary),
        Status.new('man_made', 'windmill', :primary),
        Status.new('military', '*', :ignored),
        Status.new('military', 'barracks', :primary),
        Status.new('military', 'danger_area', :primary),
        Status.new('motorcar', '*', :ignored),
        Status.new('name', '*', :composite, {'highway'=>'service'}),
        Status.new('natural', '*', :ignored),
        Status.new('natural', 'bay', :composite, {'name'=>'a'}),
        Status.new('natural', 'beach', :primary),
        Status.new('natural', 'cave_entrance', :primary),
        Status.new('natural', 'cliff', :primary),
        Status.new('natural', 'desert', :primary),
        Status.new('natural', 'glacier', :primary),
        Status.new('natural', 'grassland', :primary),
        Status.new('natural', 'heath', :primary),
        Status.new('natural', 'lake', :primary),
        Status.new('natural', 'marsh', :primary),
        Status.new('natural', 'mud', :primary),
        Status.new('natural', 'peak', :primary),
        Status.new('natural', 'sand', :primary),
        Status.new('natural', 'scrub', :primary),
        Status.new('natural', 'spring', :primary),
        Status.new('natural', 'tree', :primary),
        Status.new('natural', 'tree_row', :primary),
        Status.new('natural', 'volcano', :primary),
        Status.new('natural', 'water', :primary),
        Status.new('natural', 'wetland', :primary),
        Status.new('natural', 'wood', :primary),
        Status.new('office', '*', :ignored),
        Status.new('oneway', '*', :ignored),
        Status.new('oneway', '-1', :composite, {'highway'=>'service'}),
        Status.new('oneway', 'yes', :composite, {'highway'=>'service'}),
        Status.new('operator', '*', :ignored),
        Status.new('place', '*', :ignored),
        Status.new('place', 'city', :composite, {'name'=>'a'}),
        Status.new('place', 'farm', :composite, {'name'=>'a'}),
        Status.new('place', 'hamlet', :composite, {'name'=>'a'}),
        Status.new('place', 'island', :composite, {'name'=>'a'}),
        Status.new('place', 'islet', :composite, {'name'=>'a'}),
        Status.new('place', 'isolated_dwelling', :composite, {'name'=>'a'}),
        Status.new('place', 'locality', :composite, {'name'=>'a'}),
        Status.new('place', 'neighbourhood', :composite, {'name'=>'a'}),
        Status.new('place', 'suburb', :composite, {'name'=>'a'}),
        Status.new('place', 'town', :composite, {'name'=>'a'}),
        Status.new('place', 'village', :composite, {'name'=>'a'}),
        Status.new('population', '*', :ignored),
        Status.new('power', '*', :ignored),
        Status.new('power', 'generator', :primary),
        Status.new('power', 'line', :primary),
        Status.new('power', 'minor_line', :primary),
        Status.new('power', 'pole', :primary),
        Status.new('power', 'station', :primary),
        Status.new('power', 'sub_station', :primary),
        Status.new('power', 'substation', :primary),
        Status.new('power', 'tower', :primary),
        Status.new('power_source', '*', :ignored),
        Status.new('power_source', 'wind', :composite, {'power'=>'generator'}),
        Status.new('public_transport', '*', :ignored),
        Status.new('railway', '*', :ignored),
        Status.new('railway', 'INT-preserved-ssy', :ignored),
        Status.new('railway', 'INT-spur-siding-yard', :ignored),
        Status.new('railway', 'construction', :primary),
        Status.new('railway', 'disused', :primary),
        Status.new('railway', 'funicular', :primary),
        Status.new('railway', 'halt', :primary),
        Status.new('railway', 'level_crossing', :primary),
        Status.new('railway', 'light_rail', :primary),
        Status.new('railway', 'miniature', :primary),
        Status.new('railway', 'monorail', :primary),
        Status.new('railway', 'narrow_gauge', :primary),
        Status.new('railway', 'platform', :primary),
        Status.new('railway', 'preserved', :primary),
        Status.new('railway', 'rail', :primary),
        Status.new('railway', 'station', :primary),
        Status.new('railway', 'subway', :primary),
        Status.new('railway', 'subway_entrance', :primary),
        Status.new('railway', 'tram', :primary),
        Status.new('railway', 'tram_stop', :primary),
        Status.new('railway', 'turntable', :primary),
        Status.new('ref', '*', :composite, {'aeroway'=>'gate'}),
        Status.new('religion', '*', :ignored),
        Status.new('religion', 'buddhist', :composite, {'amenity'=>'place_of_worship'}),
        Status.new('religion', 'christian', :composite, {'amenity'=>'place_of_worship'}),
        Status.new('religion', 'hindu', :composite, {'amenity'=>'place_of_worship'}),
        Status.new('religion', 'jewish', :composite, {'amenity'=>'place_of_worship'}),
        Status.new('religion', 'muslim', :composite, {'amenity'=>'place_of_worship'}),
        Status.new('religion', 'shinto', :composite, {'amenity'=>'place_of_worship'}),
        Status.new('religion', 'sikh', :composite, {'amenity'=>'place_of_worship'}),
        Status.new('religion', 'taoist', :composite, {'amenity'=>'place_of_worship'}),
        Status.new('route', '*', :ignored),
        Status.new('route', 'ferry', :primary),
        Status.new('service', '*', :ignored),
        Status.new('service', 'drive-through', :composite, {'highway'=>'service'}),
        Status.new('service', 'driveway', :composite, {'highway'=>'service'}),
        Status.new('service', 'parking_aisle', :composite, {'highway'=>'service'}),
        Status.new('service', 'siding', :composite, {'railway'=>'rail'}),
        Status.new('service', 'spur', :composite, {'railway'=>'rail'}),
        Status.new('service', 'yard', :composite, {'railway'=>'rail'}),
        Status.new('shop', '*', :ignored),
        Status.new('shop', 'accessories', :primary),
        Status.new('shop', 'alcohol', :primary),
        Status.new('shop', 'antique', :primary),
        Status.new('shop', 'antiques', :primary),
        Status.new('shop', 'appliance', :primary),
        Status.new('shop', 'art', :primary),
        Status.new('shop', 'baby_goods', :primary),
        Status.new('shop', 'bag', :primary),
        Status.new('shop', 'bags', :primary),
        Status.new('shop', 'bakery', :primary),
        Status.new('shop', 'bathroom_furnishing', :primary),
        Status.new('shop', 'beauty', :primary),
        Status.new('shop', 'bed', :primary),
        Status.new('shop', 'betting', :primary),
        Status.new('shop', 'beverages', :primary),
        Status.new('shop', 'bicycle', :primary),
        Status.new('shop', 'boat', :primary),
        Status.new('shop', 'bookmaker', :primary),
        Status.new('shop', 'books', :primary),
        Status.new('shop', 'boutique', :primary),
        Status.new('shop', 'builder', :primary),
        Status.new('shop', 'building_materials', :primary),
        Status.new('shop', 'butcher', :primary),
        Status.new('shop', 'camera', :primary),
        Status.new('shop', 'car', :primary),
        Status.new('shop', 'car_parts', :primary),
        Status.new('shop', 'car_repair', :primary),
        Status.new('shop', 'car_service', :primary),
        Status.new('shop', 'carpet', :primary),
        Status.new('shop', 'charity', :primary),
        Status.new('shop', 'cheese', :primary),
        Status.new('shop', 'chemist', :primary),
        Status.new('shop', 'chocolate', :primary),
        Status.new('shop', 'clothes', :primary),
        Status.new('shop', 'coffee', :primary),
        Status.new('shop', 'communication', :primary),
        Status.new('shop', 'computer', :primary),
        Status.new('shop', 'confectionery', :primary),
        Status.new('shop', 'convenience', :primary),
        Status.new('shop', 'copyshop', :primary),
        Status.new('shop', 'cosmetics', :primary),
        Status.new('shop', 'craft', :primary),
        Status.new('shop', 'curtain', :primary),
        Status.new('shop', 'dairy', :primary),
        Status.new('shop', 'deli', :primary),
        Status.new('shop', 'delicatessen', :primary),
        Status.new('shop', 'department_store', :primary),
        Status.new('shop', 'discount', :primary),
        Status.new('shop', 'dive', :primary),
        Status.new('shop', 'doityourself', :primary),
        Status.new('shop', 'dry_cleaning', :primary),
        Status.new('shop', 'e-cigarette', :primary),
        Status.new('shop', 'electrical', :primary),
        Status.new('shop', 'electronics', :primary),
        Status.new('shop', 'energy', :primary),
        Status.new('shop', 'erotic', :primary),
        Status.new('shop', 'estate_agent', :primary),
        Status.new('shop', 'fabric', :primary),
        Status.new('shop', 'farm', :primary),
        Status.new('shop', 'fashion', :primary),
        Status.new('shop', 'fish', :primary),
        Status.new('shop', 'fishing', :primary),
        Status.new('shop', 'fishmonger', :primary),
        Status.new('shop', 'flooring', :primary),
        Status.new('shop', 'florist', :primary),
        Status.new('shop', 'food', :primary),
        Status.new('shop', 'frame', :primary),
        Status.new('shop', 'frozen_food', :primary),
        Status.new('shop', 'funeral_directors', :primary),
        Status.new('shop', 'furnace', :primary),
        Status.new('shop', 'furniture', :primary),
        Status.new('shop', 'gallery', :primary),
        Status.new('shop', 'gambling', :primary),
        Status.new('shop', 'games', :primary),
        Status.new('shop', 'garden_centre', :primary),
        Status.new('shop', 'gas', :primary),
        Status.new('shop', 'general', :primary),
        Status.new('shop', 'gift', :primary),
        Status.new('shop', 'glaziery', :primary),
        Status.new('shop', 'greengrocer', :primary),
        Status.new('shop', 'grocery', :primary),
        Status.new('shop', 'hairdresser', :primary),
        Status.new('shop', 'hardware', :primary),
        Status.new('shop', 'health', :primary),
        Status.new('shop', 'health_food', :primary),
        Status.new('shop', 'hearing_aids', :primary),
        Status.new('shop', 'herbalist', :primary),
        Status.new('shop', 'hifi', :primary),
        Status.new('shop', 'hobby', :primary),
        Status.new('shop', 'household', :primary),
        Status.new('shop', 'houseware', :primary),
        Status.new('shop', 'hunting', :primary),
        Status.new('shop', 'ice_cream', :primary),
        Status.new('shop', 'insurance', :primary),
        Status.new('shop', 'interior_decoration', :primary),
        Status.new('shop', 'jewellery', :primary),
        Status.new('shop', 'jewelry', :primary),
        Status.new('shop', 'kiosk', :primary),
        Status.new('shop', 'kitchen', :primary),
        Status.new('shop', 'laundry', :primary),
        Status.new('shop', 'leather', :primary),
        Status.new('shop', 'lighting', :primary),
        Status.new('shop', 'locksmith', :primary),
        Status.new('shop', 'lottery', :primary),
        Status.new('shop', 'mall', :composite, {'name'=>'a'}),
        Status.new('shop', 'market', :primary),
        Status.new('shop', 'massage', :primary),
        Status.new('shop', 'medical', :primary),
        Status.new('shop', 'medical_supply', :primary),
        Status.new('shop', 'mobile_phone', :primary),
        Status.new('shop', 'money_lender', :primary),
        Status.new('shop', 'motorcycle', :primary),
        Status.new('shop', 'motorcycle_repair', :primary),
        Status.new('shop', 'music', :primary),
        Status.new('shop', 'musical_instrument', :primary),
        Status.new('shop', 'newsagent', :primary),
        Status.new('shop', 'office_supplies', :primary),
        Status.new('shop', 'optician', :primary),
        Status.new('shop', 'organic', :primary),
        Status.new('shop', 'outdoor', :primary),
        Status.new('shop', 'paint', :primary),
        Status.new('shop', 'pastry', :primary),
        Status.new('shop', 'pawnbroker', :primary),
        Status.new('shop', 'perfumery', :primary),
        Status.new('shop', 'pet', :primary),
        Status.new('shop', 'pets', :primary),
        Status.new('shop', 'pharmacy', :primary),
        Status.new('shop', 'phone', :primary),
        Status.new('shop', 'photo', :primary),
        Status.new('shop', 'photo_studio', :primary),
        Status.new('shop', 'photography', :primary),
        Status.new('shop', 'pottery', :primary),
        Status.new('shop', 'printing', :primary),
        Status.new('shop', 'radiotechnics', :primary),
        Status.new('shop', 'real_estate', :primary),
        Status.new('shop', 'religion', :primary),
        Status.new('shop', 'rental', :primary),
        Status.new('shop', 'salon', :primary),
        Status.new('shop', 'scuba_diving', :primary),
        Status.new('shop', 'seafood', :primary),
        Status.new('shop', 'second_hand', :primary),
        Status.new('shop', 'sewing', :primary),
        Status.new('shop', 'shoe_repair', :primary),
        Status.new('shop', 'shoes', :primary),
        Status.new('shop', 'shopping_centre', :primary),
        Status.new('shop', 'solarium', :primary),
        Status.new('shop', 'souvenir', :primary),
        Status.new('shop', 'sports', :primary),
        Status.new('shop', 'stationery', :primary),
        Status.new('shop', 'supermarket', :primary),
        Status.new('shop', 'tailor', :primary),
        Status.new('shop', 'tanning', :primary),
        Status.new('shop', 'tattoo', :primary),
        Status.new('shop', 'tea', :primary),
        Status.new('shop', 'ticket', :primary),
        Status.new('shop', 'tiles', :primary),
        Status.new('shop', 'tobacco', :primary),
        Status.new('shop', 'toys', :primary),
        Status.new('shop', 'trade', :primary),
        Status.new('shop', 'travel_agency', :primary),
        Status.new('shop', 'tyres', :primary),
        Status.new('shop', 'vacuum_cleaner', :primary),
        Status.new('shop', 'variety_store', :primary),
        Status.new('shop', 'video', :primary),
        Status.new('shop', 'video_games', :primary),
        Status.new('shop', 'watches', :primary),
        Status.new('shop', 'wholesale', :primary),
        Status.new('shop', 'wine', :primary),
        Status.new('shop', 'winery', :primary),
        Status.new('shop', 'yes', :primary),
        Status.new('sport', '*', :ignored),
        Status.new('surface', '*', :ignored),
        Status.new('toll', '*', :ignored),
        Status.new('tourism', '*', :ignored),
        Status.new('tourism', 'alpine_hut', :primary),
        Status.new('tourism', 'attraction', :primary),
        Status.new('tourism', 'camp_site', :primary),
        Status.new('tourism', 'caravan_site', :primary),
        Status.new('tourism', 'chalet', :primary),
        Status.new('tourism', 'guest_house', :primary),
        Status.new('tourism', 'hostel', :primary),
        Status.new('tourism', 'hotel', :primary),
        Status.new('tourism', 'information', :primary),
        Status.new('tourism', 'motel', :primary),
        Status.new('tourism', 'museum', :primary),
        Status.new('tourism', 'picnic_site', :primary),
        Status.new('tourism', 'theme_park', :primary),
        Status.new('tourism', 'viewpoint', :primary),
        Status.new('tourism', 'zoo', :primary),
        Status.new('tower:type', '*', :ignored),
        Status.new('tracktype', '*', :ignored),
        Status.new('tracktype', 'grade1', :composite, {'highway' => 'track'}),
        Status.new('tracktype', 'grade2', :composite, {'highway' => 'track'}),
        Status.new('tracktype', 'grade3', :composite, {'highway' => 'track'}),
        Status.new('tracktype', 'grade4', :composite, {'highway' => 'track'}),
        Status.new('tracktype', 'grade5', :composite, {'highway' => 'track'}),
        Status.new('tunnel', '*', :ignored),
        Status.new('tunnel', 'building_passage', :composite, {'highway' => 'service'}),
        Status.new('tunnel', 'culvert', :composite, {'waterway'=>'river'}),
        Status.new('tunnel', 'no', :ignored),
        Status.new('tunnel', 'yes', :composite, {'highway'=>'service'}),
        Status.new('water', '*', :ignored),
        Status.new('waterway', '*', :ignored),
        Status.new('waterway', 'canal', :primary),
        Status.new('waterway', 'dam', :primary),
        Status.new('waterway', 'derelict_canal', :primary),
        Status.new('waterway', 'ditch', :primary),
        Status.new('waterway', 'dock', :primary),
        Status.new('waterway', 'drain', :primary),
        Status.new('waterway', 'lock', :primary),
        Status.new('waterway', 'lock_gate', :primary),
        Status.new('waterway', 'river', :primary),
        Status.new('waterway', 'riverbank', :primary),
        Status.new('waterway', 'stream', :primary),
        Status.new('waterway', 'wadi', :primary),
        Status.new('waterway', 'weir', :primary),
        Status.new('wetland', '*', :ignored),
        Status.new('width', '*', :ignored),
        Status.new('wood', '*', :ignored),
    ]
end

def get_composite_sets
  return [
      {'name' => 'a'}, #place=city...
      {'highway' => 'service'}, #access, ref, bridge, tunnel, service=parking_aisle...
      {'railway' => 'rail'}, #service=siding
      {'boundary' => 'administrative'}, #admin_level
      {'admin_level' => '2'}, #boundary=administrative
      {'natural' => 'peak'}, #ele=*
      {'ref' => '3'}, #aeroway=gate
      {'aeroway' => 'gate'}, #ref=*
      {'amenity' => 'place_of_worship'}, #religion=christian
      {'amenity' => 'place_of_worship', 'religion' => 'christian'}, #denomination=jehovahs_witness
      {'waterway' => 'river'}, #bridge=aqueduct, tunnel=culvert
      {'power' => 'generator'}, #power_source=wind
      {'highway' => 'path'}, #bicycle=designated
      {'highway' => 'construction'}, #construction=motorway...
      {'highway' => 'track'}, #tracktype=grade1...
  #{'barrier' => 'hedge'}, #area=yes
  ]
end