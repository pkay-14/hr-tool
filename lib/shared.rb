module Shared

  def group_data(data, grouping_fields, summing_fields)
    grouped_data = data.group_by {|hash| hash.values_at(*grouping_fields).join ":"}.values.map do |grouped|
      grouped.inject do |merged, n|
        merged.merge(n) do |key, v1, v2|
          if grouping_fields.include?(key)
            v1
          elsif summing_fields.include?(key)
            if v1.respond_to?(:to_i) && v2.respond_to?(:to_i)
              if (v1.to_i == v1.to_f) && (v2.to_i == v2.to_f)
                v1.to_i + v2.to_i
              else
                v1.to_f + v2.to_f
              end
            else
              v1 + v2
            end
          end
        end
      end
    end

    grouped_data.sort_by {|hash| hash.values_at(*grouping_fields).join ":"}
  end


end
