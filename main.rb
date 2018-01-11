require 'geokit'

Geokit::default_units = :kms

Dir['./app/**/*.rb'].each { |f| require f }

lat_lngs = Directions.all
my_lat_lon = [-3.73409, -38.52937]
my_point = Geokit::LatLng.new(my_lat_lon.first, my_lat_lon.last)
route = Route.new(lat_lngs)
nearest_point = route.nearest_point(my_point)

eta = Eta.new(lat_lngs[(nearest_point[:index])..-1], my_lat_lon)
puts eta.kms
