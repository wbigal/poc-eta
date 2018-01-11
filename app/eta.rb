class Eta
  attr_reader :points, :current_point

  def initialize(lat_lngs, current_lat_lng)
    @points = lat_lngs.map do |lat_lng|
      Geokit::LatLng.new(lat_lng.first, lat_lng.last)
    end

    @current_point = Geokit::LatLng.new(current_lat_lng.first, current_lat_lng.last)
  end

  def kms
    i = 1
    total = 0

    point_a = points[0]

    while points.size > i do
      point_b = points[i]

      total += point_a.distance_to(point_b)
      point_a = point_b

      i += 1
    end

    total
  end
end
