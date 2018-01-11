class Route
  attr_reader :points

  def initialize(lat_lngs)
    @points = lat_lngs.map do |lat_lng|
      Geokit::LatLng.new(lat_lng.first, lat_lng.last)
    end
  end

  def nearest_point(point)
    i = 0
    near_point = Hash[point: nil, distance: nil, index: nil]

    while points.size > i do
      current_point = points[i]
      distance = point.distance_to(current_point)

      if near_point[:distance] == nil || near_point[:distance] >= distance
        near_point[:point] = current_point
        near_point[:distance] = distance
        near_point[:index] = i
      end

      i += 1
    end

    near_point
  end
end
