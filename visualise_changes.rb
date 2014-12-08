require 'RMagick'

def visualise_changes(tags, type, on_water, zlevel_range, old_branch, new_branch)
	switch_to_branch(old_branch)
	old = collect_images(tags, type, on_water, zlevel_range)
	switch_to_branch(new_branch)
	new = collect_images(tags, type, on_water, zlevel_range)
  diff = ComparisonOfImages.new(old, new, "#{ tags.to_s } #{ type } #{ on_water }")
  diff.save
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
    @compared = compress(before, after)

    @image_size = 200 #TODO - stop hardcoding
    @margin = 20
    @standard_pointsize = 10
    @header_space = @standard_pointsize*2.5
    @diff_note_space = @standard_pointsize*2

    render
  end

  def compress(before, after)
    returned = [ImagePair.new(before[0], after[0])]
    (1...before.length).each { |i|
      if before[i].identical(before[i-1]) && after[i].identical(after[i-1])
        returned[-1].description << ', ' << before[i].description
      else
        returned.push(ImagePair.new(before[i], after[i]))
      end
    }
    return returned
  end
  def render
    y = get_needed_y
    x = @image_size*2+3*@margin

    @canvas = Magick::Image.new(x, y)

    offset = 0
    render_header
    offset += @header_space + @margin*1.5
    render_diff_note offset
    offset += @diff_note_space + @margin*0.5
    render_images_with_labels offset
    offset += (@compared.length)*(@margin + @image_size)
    render_footer offset
  end

  def get_needed_y
    y = 0
    y += @header_space
    y += @margin*1.5
    y += @diff_note_space
    y += @margin*0.5
    y += (@compared.length) * (@image_size + @margin)
    y += @diff_note_space
    return y
  end

  def render_header
    header_drawer = Magick::Draw.new
    header_drawer.pointsize(@header_space*2/2.5)
    header_drawer.text(@margin, @header_space, @header)
    header_drawer.draw(@canvas)
  end

  def render_diff_note(y_offset)
    drawer = Magick::Draw.new
    drawer.pointsize(@diff_note_space)
    drawer.text(@margin, y_offset, 'before')
    drawer.draw(@canvas)
    drawer.text(@margin*2 + @image_size, y_offset, 'after')
    drawer.draw(@canvas)
  end

  def render_images_with_labels(y_offset)
    (0...@compared.length).each { |i|
      processed = @compared[i]
      left_image = Magick::Image.read(processed.left_file_location)[0]
      right_image = Magick::Image.read(processed.right_file_location)[0]
      y = y_offset + i * (@margin + @image_size) - @margin + @standard_pointsize*2
      render_label(y, processed.description)
      y = y_offset + i * (@margin + @image_size)
      render_row_of_images(y, left_image, right_image)
    }
  end

  def render_label(y_offset, label)
    label_drawer = Magick::Draw.new
    label_drawer.pointsize(@standard_pointsize)
    label_drawer.text(@margin, y_offset, label)
    label_drawer.draw(@canvas)
  end

  def render_row_of_images(y_offset, left_image, right_image)
    @canvas.composite!(left_image, @margin, y_offset, Magick::OverCompositeOp)
    @canvas.composite!(right_image, @margin*2+@image_size, y_offset, Magick::OverCompositeOp)
  end

  def render_footer(y_offset)
    label_drawer = Magick::Draw.new
    label_drawer.pointsize(@standard_pointsize)
    label_drawer.text(@margin, y_offset, 'generated using https://github.com/mkoniecz/CartoCSSHelper')
    label_drawer.draw(@canvas)
  end

  def popup
    @canvas.display
  end

  def save
    @canvas.write("tmp/#{@header}.png")
  end
end