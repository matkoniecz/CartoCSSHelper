module CartoCSSHelper
  class StyleSpecificData
    attr_reader :min_z, :max_z, :list_of_documented_tags, :list_of_documented_compositions, :name_label_is_not_required
    def initialize(min_z, max_z, list_of_documented_tags, list_of_documented_compositions, name_label_is_not_required)
      @min_z = min_z
      @max_z = max_z
      @list_of_documented_tags = list_of_documented_tags
      @list_of_documented_compositions = list_of_documented_compositions
      @name_label_is_not_required = name_label_is_not_required
    end
  end
end
