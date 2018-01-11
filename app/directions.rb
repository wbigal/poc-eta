class Directions
  def self.all
    $all_directions ||= JSON.parse(File.read('./points.json'))['points']
  end
end
