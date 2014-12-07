require 'RMagick'

def visualise_changes(tags, type, on_water, zlevel_range, old_branch, new_branch)
	switch_to_branch(old_branch)
	old = collect_images(tags, type, on_water, zlevel_range)
	switch_to_branch(new_branch)
	new = collect_images(tags, type, on_water, zlevel_range)
  diff = ComparisonOfImages.new(old, new, "#{ tags.to_s } #{ type } #{ on_water }")
  diff.render
end

class Image
  attr_reader :file_location, :description
  def initialize(file_location, description)
    @file_location = file_location
    @description = description
  end
  def identical(another_image)
    #Returns true if the contents of a file A and a file B are identical.
    return FileUtils.compare_file(self.file_location, another_image.file_location)
  end
end

def collect_images(tags, type, on_water, zlevel_range)
  collection = []
	zlevel_range.each { |zlevel|
		scene = Scene.new(tags, zlevel, on_water, type)
    collection.push(Image.new(scene.get_image, "z#{zlevel}"))
	}
  return collection
end

class ImagePair
  attr_reader :left_file_location, :right_file_location
  attr_accessor :description
  def initialize(left_image, right_image)
    raise 'description mismatch' unless left_image.description == right_image.description
    @left_file_location = left_image.file_location
    @right_file_location = right_image.file_location
    @description = left_image.description
  end
end

class ComparisonOfImages
  def initialize(before, after, header)
    @header = header
    @compared = [ImagePair.new(before[0], after[0])]
    (1...before.length).each { |i|
      if before[i].identical(before[i-1]) && after[i].identical(after[i-1])
        append = ', ' + before[i].description
        @compared[-1].description << append
      else
        @compared.push(ImagePair.new(before[i], after[i]))
      end
    }
  end
  def render
    size = 200
    margin = 20
    standard_pointsize = 10
    header_margin = standard_pointsize*3
    count = @compared.length

    y = size*count+margin*(count+2)
    y += header_margin
    x = size*2+3*margin

    canvas = Magick::Image.new(x, y)

    header_drawer = Magick::Draw.new
    header_drawer.pointsize(standard_pointsize*3)
    header_drawer.text(margin, header_margin, @header)
    header_drawer.draw(canvas)

    label_drawer = Magick::Draw.new
    label_drawer.pointsize(standard_pointsize)
    (0...count).each { |i|
      processed = @compared[i]
      filename_a = processed.left_file_location
      filename_b = processed.right_file_location
      a = Magick::Image.read(filename_a)[0]
      b = Magick::Image.read(filename_b)[0]
      y = (i+1)*margin+(i)*size+header_margin
      label_drawer.text(margin, y-standard_pointsize*2/3, processed.description)
      canvas.composite!(a, margin, y, Magick::OverCompositeOp)
      canvas.composite!(b, margin*2+size, y, Magick::OverCompositeOp)
    }
    label_drawer.draw(canvas)

    canvas.display
    canvas.write("tmp/#{@header}.png")
  end
end