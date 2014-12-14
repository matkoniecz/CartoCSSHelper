def get_composite_sets
  return [
      {'name' => 'a'}, #place=city...
      {'highway' => 'service'}, #access, ref, bridge, tunnel, service=parking_aisle...
      {'railway' => 'rail'}, #service=siding
      {'boundary' => 'administrative'}, #admin_level
      {'admin_level' => '2'}, #boundary=administrative
      {'natural' => 'peak'}, #ele=*
      {'ref' => '3'}, #aeroway=gate
      {'amenity' => 'place_of_worship'}, #religion
      {'amenity' => 'place_of_worship', 'religion' => 'christian'}, #denomination=jehovahs_witness
      {'waterway' => 'river'}, #bridge=aqueduct, tunnel=culvert
  #{'barrier' => 'hedge'}, #area=yes
  ]
end

