module CartoCSSHelper
  class StyleSpecificData
    attr_reader :min_z, :max_z, :list_of_expected_tags, :list_of_expected_compositions
    def initialize(min_z, max_z, list_of_expected_tags, list_of_expected_compositions)
      @min_z = min_z
      @max_z = max_z
      @list_of_expected_tags = list_of_expected_tags
      @list_of_expected_compositions = list_of_expected_compositions
    end
  end
end