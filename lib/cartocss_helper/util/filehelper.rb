# frozen_string_literal: true

module FileHelper
  def self.make_string_usable_as_filename(string)
    return string.gsub(/[\x00\/\\:\*\?\"<>\|]/, '_')
  end
end
