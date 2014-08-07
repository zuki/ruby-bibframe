# -*- encoding: utf-8 -*-

module Bibframe

  module Utils

    private

    # 指定した文字が末尾にある場合に削除
    # @param [String] value ID値が含まれる文字列
    # @param [String] punc 削除すべき文字
    # @return [String] 処理済みの文字列
    def chop_puctuation(value, punc)
      value[-1] == punc ? value.chop : value
    end

    # 文字列からID値として不要な文字を削除
    # @param [String] value ID値が含まれる文字列
    # @return [String] 処理済みの文字列
    def clean_id(value)
      value = value.sub(/\(OCoLC\)/, '').sub(/^(ocm|ocn)/, '').sub(/\(DLC\)/, '')
      clean_string(value)
    end

    # 文字列から名前として不要な文字を削除
    # @param [String] value ID値が含まれる文字列
    # @return [String] 処理済みの文字列
    def clean_name_string(value)
      value.sub(/\[from old catalog\]/i, '').sub(/,$/, '')
    end

    # 文字列から不要な文字を削除
    # @param [String] value ID値が含まれる文字列
    # @return [String] 処理済みの文字列
    def clean_string(value)
      value = value.gsub(/from old catalog/i, '').gsub(/[\[\];]+/, '').gsub(/ :/, '')
                   .sub(/,$/, '')
      value = value.sub(/\(/, '') if value.include?('(') && ! value.include?(')')
      value = value.sub(/\)/, '') if value.include?(')') && ! value.include?('(')
      normalize_space(value)
    end

    # 文字列からタイトルとして不要な文字を削除
    # @param [String] value ID値が含まれる文字列
    # @return [String] 処理済みの文字列
    def clean_title_string(title)
      clean_string(title).gsub(/\[sound recording\]/i, '')
                         .gsub(/\[microform\]/i, '').sub(/\/$/, '')
    end

    # リソース種別を判定する
    # @return [Array] 該当するリソース種別（String）の配列
    def get_types
      return @types if @types.size > 0

      leader6 = @record.leader[6]
      @types << RESOURCE_TYPES[:leader][leader6] if RESOURCE_TYPES[:leader].has_key?(leader6)
      if @record['007']
        cf007 = @record['007'].value
        @types << RESOURCE_TYPES[:cf007][cf007] if RESOURCE_TYPES[:cf007].has_key?(cf007)
      end

      %w(336 337).each do |tag|
        @record.fields(tag).each do |field|
          %w(a b).each do |code|
            field.values_of(code) do |value|
              key = ('sf' + tag + code).to_sym
              value = value.downcase
              @types << RESOURCE_TYPES[key][value] if RESOURCE_TYPES[key].has_key?(value)
            end
          end
        end
      end

      @types = @types.flatten.uniq
    end

    # 各種システム番号から BF.systemNumber トリプルを作成する
    # @param [String] sysnum システム番号
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def handle_system_number(sysnum, subject)
      sysnum = normalize_space(sysnum)
      if sysnum.start_with?('(DE-588)')
        id = normalize_space(sysnum.sub(/\(DE-588\)/, ''))
        @graph << [subject, BF.hasAuthority, RDF::URI.new('http://d-nb.info/gnd/'+id)]
      elsif sysnum.include?('(OCoLC)')
        id = clean_string(sysnum.sub(/\(OCoLC\)/, '')).gsub(/^(ocm|ocn)/, '')
        @graph << [subject, BF.systemNumber, RDF::URI.new('http://www.worldcat.org/oclc/'+id)]
      else
        bn_identifier = RDF::Node.uuid
        @graph << [subject, BF.systemNumber, bn_identifier]
        @graph << [bn_identifier, RDF.type, BF.Identifier]
        @graph << [bn_identifier, BF.identifierValue, sysnum]
      end
    end

    # 文字列中の空白の正規化
    # @param [String] value 正規化する文字列
    # @return [String] 正規化された文字列
    def normalize_space(value)
      value.gsub(/\s+/, ' ').strip
    end

    # 典拠IDの取得
    # @param [String] lname データ種別
    # @param [String] label 典拠値
    # @return [String|nil] 典拠ID。該当する典拠データがない場合はnil
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

    # 典拠ID取得のためのHTTP処理
    # @param [String] 典拠ID取得URL文字列
    # @return [Net::HTTPResponse] HTTPレスポンス
    def getResponse(url_str)
      url = URI.parse(url_str)
      req = Net::HTTP::Get.new(url.path)
      Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end
    end

  end # Utils

end # Bibframe