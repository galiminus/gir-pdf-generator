require "prawn"
require 'open-uri'
require 'prawn/measurement_extensions'
require 'byebug'
require 'fastimage'

info_height = 60
info_padding = 20
font_size = 30

["A3"].each do |size|
  Prawn::Document.generate("gir-#{size}.pdf") do
  # byebug
    Dir["input/**/*"].each do |path|
      next unless [".png", ".jpg", ".jpeg"].include?(File.extname(path).downcase)

      character_configuration, artist_configuration = path.split(File::SEPARATOR)[-3..-2]

      _, character_name, character_species =
        character_configuration.match(/([^(]+) *\(?([^\)]+)?\)?/).to_a

      _, artist_name, artist_network =
        artist_configuration.match(/([^()]+) *\(?([^\)]+)?\)?/).to_a

      # Convert to a better format
      system("convert", path, "/tmp/gir-input.jpg")

      image_size = FastImage.size("/tmp/gir-input.jpg")

      is_portrait = image_size[1] > image_size[0]
      start_new_page(size: size, layout: is_portrait ? :portrait : :landscape, margin: [0, 0, 0, 0])

      image_record = image "/tmp/gir-input.jpg", at: [page.trim_box[0], page.trim_box[3]], fit: [page.trim_box[2], page.trim_box[3]]

      fill_color '000000'

      transparent(0.8) do
        fill { rectangle [ page.trim_box[0], page.trim_box[3] - image_record.scaled_height + info_height], image_record.scaled_width, info_height }
      end

      fill_color 'FFFFFF'

      draw_text character_name, :at => [ page.trim_box[0] + info_padding, page.trim_box[3] - image_record.scaled_height + info_height - font_size ]
    end
  end
end