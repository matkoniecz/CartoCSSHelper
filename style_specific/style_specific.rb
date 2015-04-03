module CartoCSSHelper
  class StyleSpecificData
    attr_reader :min_z, :max_z, :list_of_documented_tags, :list_of_documented_compositions
    def initialize(min_z, max_z, list_of_documented_tags, list_of_documented_compositions)
      @min_z = min_z
      @max_z = max_z
      @list_of_documented_tags = list_of_documented_tags
      @list_of_documented_compositions = list_of_documented_compositions
    end
  end
end