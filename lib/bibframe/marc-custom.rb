# -*- encoding: utf-8 -*-

module MARC

  class Record
    def include_member?(ary)
      all_tags = self.tags
      if ary.is_a? Array
        ary.select{|t| all_tags.include?(t)}.size > 0
      else
        raise MARC::Exception.new(),
        "parameter is not Array instance #{ary}"
      end
    end
  end

  class DataField
    def values_of(code)
      if code.is_a? String
        subfields.select{|s| s.code == code}.map{|s| s.value}
      elsif code.is_a? Array
        subfields.select{|s| code.include?(s.code)}.map{|s| s.value}
      else
        raise MARC::Exception.new(),
        "parameter is not Array nor String but instance of #{code.class}"
      end
    end

    def has_subfields(code)
      all_subfields = self.codes
      if code.is_a? String
        all_subfields.include?(code)
      elsif code.is_a? Array
        code.uniq.any?{|c| all_subfields.include?(c)}
      else
       raise MARC::Exception.new(),
        "invalid code #{code}"
      end
    end
  end

end