require 'pr_geohash'
require 'geokit'

GEOHASH_PRECISION = 7
AVERAGE_SPEED = 50

Geokit::default_units = :kms

Dir['./app/**/*.rb'].each { |f| require f }

lat_lngs = Directions.all

origin = lat_lngs.first
destination = lat_lngs.last

geohashes = {}
origin_geohash7 = GeoHash.encode(origin.first, origin.last, GEOHASH_PRECISION)
destination_geohash7 = GeoHash.encode(destination.first, destination.last, GEOHASH_PRECISION)
destination_geohash12 = GeoHash.encode(destination.first, destination.last, 12)

destination_point = Geokit::LatLng.new(destination.first, destination.last)

lat_lngs.each do |lat_lng|
  latitude = lat_lng.first
  longitude = lat_lng.last
  current_geohash = GeoHash.encode(latitude, longitude, GEOHASH_PRECISION)
  current_geohash12 = GeoHash.encode(latitude, longitude, 12)

  current_geohash7_key = "#{current_geohash}-#{destination_geohash7}"

  current_point = Geokit::LatLng.new(latitude, longitude)
  distance_km = current_point.distance_to(destination_point)
  duration_min = distance_km / AVERAGE_SPEED * 60

  unless geohashes.key?(current_geohash7_key)
    geohashes[current_geohash7_key] = Hash[
      geohash7: current_geohash,
      distance_km: distance_km,
      duration_min: duration_min,
      geohashes: {}
    ]
  end

  unless geohashes[current_geohash7_key][:geohashes].key?(current_geohash12)
    geohashes[current_geohash7_key][:geohashes][current_geohash12] = Hash[
      distance_km: distance_km,
      duration_min: duration_min
    ]
  end
end

# current_location = [-3.73101999, -38.53862001]
current_location = [-3.73329163, -38.53797913]

current_location_geohash12 = GeoHash.encode(
  current_location.first,
  current_location.last,
  12
)

current_location_geohash6 = current_location_geohash12[0..6]

current_geohash = geohashes["#{current_location_geohash6}-#{destination_geohash7}"]

if current_geohash.nil?
  neighbors = GeoHash.neighbors(current_location_geohash6)

  while current_geohash.nil? && neighbors.size > 0
    current_geohash = geohashes["#{neighbors.pop}-#{destination_geohash7}"]
  end
end

puts "Geohash: #{current_geohash}"

if current_geohash.nil?
  puts "Out of route"
elsif current_geohash[:geohashes].key?(current_location_geohash12)
  distance = current_geohash[:geohashes][current_location_geohash12][:distance_km]
  duration = current_geohash[:geohashes][current_location_geohash12][:duration_min]
else
  distance = current_geohash[:distance_km]
  duration = current_geohash[:duration_min]
end

puts "Total kms: #{sprintf('%0.03f', distance)}" unless distance.nil?
puts "Total minutes: #{sprintf('%0.03f', duration)}" unless duration.nil?
