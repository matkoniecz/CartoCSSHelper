require 'RMagick'
load 'util.rb'

def visualise_changes(tags, type, on_water, zlevel_range, old_branch, new_branch)
	switch_to_branch(old_branch)
	old = collect_images(tags, type, on_water, zlevel_range)
	switch_to_branch(new_branch)
	new = collect_images(tags, type, on_water, zlevel_range)
  on_water_string = ''
  if on_water
    on_water_string = 'on water'
  end
  diff = ComparisonOfImages.new(old, new, "#{ dict_to_pretty_tag_list(tags) } #{ type } #{ on_water_string }")
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
  def merge_description_from_next_image(image)
    @description << ', ' << image.description
  end
end

class ComparisonOfImages
  def initialize(before, after, header)
    @header = header
    @compared = compress(before, after)

    @image_size = 200 #TODO - stop hardcoding
    @margin = 20
    @standard_pointsize = 10
    @header_space = @standard_pointsize*1.5
    @diff_note_space = @standard_pointsize

    render
  end

  def compress(before, after)
    returned = [ImagePair.new(before[0], after[0])]
    (1...before.length).each { |i|
      if before[i].identical(before[i-1]) && after[i].identical(after[i-1])
        returned[-1].merge_description_from_next_image(before[i])
      else
        returned.push(ImagePair.new(before[i], after[i]))
      end
    }
    return returned
  end

  def render
    create_canvas
    offset = 0
    render_header
    offset += @header_space + @margin*1.5
    render_diff_note offset
    offset += @diff_note_space + @margin*0.5
    render_images_with_labels offset
    offset += (@compared.length)*(@margin + @image_size)
    render_footer offset
  end

  def create_canvas
    y = get_needed_y
    x = @image_size*2+3*@margin

    @canvas = Magick::Image.new(x, y)
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
    header_drawer.pointsize(@header_space*3/5)
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
      render_row_of_labelled_images(@compared[i], y_offset + i * (@margin + @image_size))
    }
  end

  def render_row_of_labelled_images(processed, y_offset)
    left_image = Magick::Image.read(processed.left_file_location)[0]
    right_image = Magick::Image.read(processed.right_file_location)[0]
    render_label(y_offset, processed.description)
    render_row_of_images(y_offset, left_image, right_image)
  end

  def render_label(y_offset, label)
    label_drawer = Magick::Draw.new
    label_drawer.pointsize(@standard_pointsize)
    label_drawer.text(@margin, y_offset, label)
    label_drawer.draw(@canvas)
  end

  def render_row_of_images(y_offset, left_image, right_image)
    if left_image == right_image
      @canvas.composite!(left_image, @margin*1.5 + @image_size/2, y_offset, Magick::OverCompositeOp)
    else
      @canvas.composite!(left_image, @margin, y_offset, Magick::OverCompositeOp)
      @canvas.composite!(right_image, @margin*2+@image_size, y_offset, Magick::OverCompositeOp)
    end
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