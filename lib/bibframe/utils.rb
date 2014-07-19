# -*- encoding: utf-8 -*-

module Bibframe

  module Utils

    private

    def chop_puctuation(value, punc)
      value[-1] == punc ? value.chop : value
    end

    def clean_id(value)
      value = value.sub(/\(OCoLC\)/, '').sub(/^(ocm|ocn)/, '').sub(/\(DLC\)/, '')
      clean_string(value)
    end

    def clean_name_string(value)
      value.sub(/\[from old catalog\]/i, '').sub(/,$/, '')
    end

    def clean_string(value)
      value = value.gsub(/from old catalog/i, '').gsub(/[\[\];]+/, '').gsub(/ :/, '')
                   .sub(/,$/, '')
      value = value.sub(/\(/, '') if value.include?('(') && ! value.include?(')')
      value = value.sub(/\)/, '') if value.include?(')') && ! value.include?('(')
      normalize_space(value)
    end

    def clean_title_string(title)
      clean_string(title).gsub(/\[sound recording\]/i, '')
                         .gsub(/\[microform\]/i, '').sub(/\/$/, '')
    end

    def get_types
      return @types if @types.size > 0

      leader6 = @record.leader[6]
      @types << RESOURCE_TYPES[:leader][leader6] if RESOURCE_TYPES[:leader].has_key?(leader6)
      if @record['007']
        code = @record['007'].value
        @types << RESOURCE_TYPES[:cf007][code] if RESOURCE_TYPES[:cf007].has_key?(code)
      end

      if @record['336']
        @record.fields['336'].each do |field|
          field.each do |sbfield|
            code = sbfield.code
            value = sbfield.value.downcase
            types << RESOURCE_TYPES[:sf336a][value] if code == 'a' && RESOURCE_TYPES[:sf336a].has_key?(value)
            types << RESOURCE_TYPES[:sf336b][value] if code == 'b' && RESOURCE_TYPES[:sf336b].has_key?(value)
          end
        end
      end
      if @record['337']
        @record.fields['337'].each do |field|
          field.each do |sbfield|
            code = sbfield.code
            value = sbfield.value.downcase
            @types << RESOURCE_TYPES[:sf337a][value] if code == 'a' && RESOURCE_TYPES[:sf337a].has_key?(value)
            @types << RESOURCE_TYPES[:sf337b][value] if code == 'b' && RESOURCE_TYPES[:sf337b].has_key?(value)
          end
        end
      end
      @types = @types.flatten.uniq
    end

    def get_uri(type)
      @num += 1
      RDF::URI.new(@baseuri + '-' + type + @num.to_s)
    end

    def handle_cancels(field, sbfield, scheme, subject)
      if (%w(010 015 016 017 020 022 024 027 030 088).include?(field.tag) && sbfield.code == 'z') || (field.tag == '022' && %w(m y).include?(sbfield.code))
        @graph << [subject, RDF.type, BF.Identifier]
        @graph << [subject, BF.identifierScheme, scheme]
        @graph << [subject, BF.identifierValue, normalize_space(sbfield.value)]
        if field.tag == '022' && sbfield.code == 'y'
          @graph << [subject, BF.identifierStatus, 'incorrect']
        else
          @graph << [subject, BF.identifierStatus, 'canceled/invalid']
        end
      end
    end

    def handle_system_number(sysnum, resource)
      sysnum = normalize_space(sysnum)
      if sysnum.start_with?('(DE-588)')
        id = normalize_space(sysnum.sub(/\(DE-588\)/, ''))
        @graph << [resource, BF.hasAuthority, RDF::URI.new('http://d-nb.info/gnd/'+id)]
      elsif sysnum.include?('(OCoLC)')
        id = clean_string(sysnum.sub(/\(OCoLC\)/, '')).gsub(/^(ocm|ocn)/, '')
        @graph << [resource, BF.systemNumber, RDF::URI.new('http://www.worldcat.org/oclc/'+id)]
      else
        bn_identifier = RDF::Node.uuid
        @graph << [resource, BF.systemNumber, bn_identifier]
        @graph << [bn_identifier, RDF.type, BF.Identifier]
        @graph << [bn_identifier, BF.identifierValue, sysnum]
      end
    end

    def normalize_space(value)
      value.gsub(/\s+/, ' ').strip
    end

    def getAuthorityID(lname, label)
      return unless %w(Person Organization Place Meeting Family Topic TemporalConcept).include? lname

      scheme = %w(Topic TemporalConcept).include?(lname) ? 'subjects' : 'names'
      # URI.escape(str)はobsoluteだが、URI.encode_www_form_component(str)は、空白を'+', カンマを'%2C'に変換する。
      # これがid.loc.govの検索仕様（空白は'%20', カンマは','）にあわないため、あえてURI.escape(str)を使用
      label = URI.escape(label.gsub(/¥s+/, ' ').strip)
      response = getResponse("http://id.loc.gov/authorities/#{scheme}/label/#{label}")
      if response.is_a? Net::HTTPRedirection
        response['x-uri']
      elsif label[-1] == '.'
        response = getResponse("http://id.loc.gov/authorities/#{scheme}/label/#{label.chop}")
        if response.is_a? Net::HTTPRedirection
          response['x-uri']
        end
      end
    end

    def getResponse(url_str)
      url = URI.parse(url_str)
      req = Net::HTTP::Get.new(url.path)
      Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end
    end

  end # Utils

end # Bibframe