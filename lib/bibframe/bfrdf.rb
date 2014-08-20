# -*- encoding: utf-8 -*-

module Bibframe

  class BFRDF

    include Bibframe::Utils

    attr_reader :graph, :source, :resolve, :baseuri

    # このクラスの初期化メソッド
    # @param [MARC::Record] record 変換するMARCレコード
    # @param [boolean] resolve 著者、件名、地名等の典拠IDを付与するか否か。デフォルトはしない（false）
    # @param [String] source MARCレコードの作成機関（現在認識するのは ('lc'|'ndl'|'bl')。デフォルトは 'lc'
    # @param [String] baseuri レコードIDURIのベースとなるURL文字列。指定がない場合は、sourceから自動設定。
    # @param [RDF::Repository] repository このクラスで作成するグラフを名前付きにする場合に指定する。デフォルトはnil
    # @return [Bibframe::BFRDF] このクラスのオブジェクト
    def initialize(record, resolve: false, source: 'lc', baseuri: nil, repository: nil, **other)
      @record = record
      @baseuri = get_baseuri(baseuri, source)
      if repository  # named graph
        @graph = RDF::Graph.new(RDF::URI.new(@baseuri), {data: repository})
      else
        @graph = RDF::Graph.new()
      end
      @resolve = resolve
      @source = source
      @types = []
      #parse
    end

    # MARCレコードをパースしてRDFグラフを作成する
    def parse
      work = RDF::URI.new(@baseuri)

      begin
        # フィールドごとに処理できない（その1）
        @graph << [work, RDF.type, BF.Work]
        generate_types(work)
        generate_accesspoints(work)        # 130  240 (245) 100 110 111
        generate_uniform_title(work)
        # generate_accesspoints_work880(subject) 翻訳形のauthor+title 今のロジックでは難しい
        generate_langs(work)
        generate_identifiers('work', work)

        # フィールド毎に処理可能
        @record.each do |field|
          case field.tag
          when '502'
            generate_dissertations(field, work)
          when /(100|110|111|700|710|711|720)/
            generate_names(field, work)
          when /(243|245|247)/
            generate_title(field, 'work', work)
          when '033'
            generate_events(field, work)
          when '521'
            generate_audience_521(field, work)
          when '555'
            generate_findaids(field, work)
          when '520'
            generate_abstract(field, work)
          when '008'
            generate_audience(field, work)
            generate_genre(field, 'Work', work)
          when '255'
            generate_cartography(field, work)
          when /(600|610|611|648|650|651|654|655|656|657|658|662|653|751|752)/
            generate_subjects(field, work)
          when '043'
            generate_gacs(field, work)
          when /(050|055|060|061|070|080|082|083|084|086)/
            generate_classes(field, 'work', work)
          when '505'
            generate_complex_notes(field, work)
          when /(400|410|411|430|440|490|533|534|630|700|710|711|720|730|740|760|762|765|767|770|772|773|774|775|776|777|780|785|786|787|800|810|811|830)/
            generate_related_works(field, 'work', work)
          when /(856|859)/
            generate_from_856(field, work)
          end
          # フィールドが設定ファイルで指定されており、独立に処理可能
          generate_simple_property(field, "work", work)
        end

        # フィールドごとに処理できない（その2）
        @graph << [work, BF.derivedFrom, RDF::URI.new(@baseuri)]
        generate_hashable(work)
        generate_admin(work)
        generate_instances(work)
      rescue => e
        puts "record: #{baseuri}, #{@record}"
        p e.message
        puts e.backtrace.join("\n")
      end
    end

    # レコード種別に関するトリプルを作成
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_types(subject)
      get_types.each do |type|
        @graph << [subject, RDF.type, BF[type]]
      end
    end

    # 標目に関するトリプルを作成
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_accesspoints(subject)
      title = nil
      @record.fields(%w(130 240)).each do |field|
        title = field.subfields.reject{|s| %w(0 6 8).include?(s.code)}.map{|s| s.value}.join(' ')
        break if title != ''
      end
      unless title
        title = @record['245'].subfields.select{|s| %w(a b h k n p s).include?(s.code)}.map{|s| s.value}.join(' ').sub(/\/$/, '').sub(/\.$/, '')
      end
      name = nil
      @record.fields(%w(100 110 111)).each do |field|
        name = field.subfields.select{|s| %w(a b c d q n).include?(s.code)}.map{|s| s.value}.join(' ')
        name = clean_name_string(name)
        break if name != ''
      end
      alabel = normalize_space(((name && name != '') ? (name + ' ') : '') + title)
      @graph << [subject, BF.authorizedAccessPoint, alabel]
    end

    # 統一書名に関するトリプルを作成
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_uniform_title(subject)
      require 'iso-639'

      field = @record['130'] ? @record['130'] : @record['240'] ? @record['240'] : nil
      return unless field

      label = field.subfields.reject{|s| %w(0 6 8).include?(s.code)}.map{|s| s.value}.join(' ')
      @graph << [subject, BF.label, label]
      # TODO: MADSは必要か?
      @graph << [subject, RDF::MADS.authoritativeLabel, label]
      generate_title_non_sort(field, label, BF.title, subject)

      bn_title = RDF::Node.uuid
      @graph << [subject, BF.workTitle, bn_title]
      generate_simple_property(field, 'title', bn_title)

      if field['0']
        field.values_of('0').each do |value|
          bn_id = RDF::Node.uuid
          @graph << [subject, BF.identifier, bn_id]
          @graph << [bn_id, RDF.type, BF.Identifier]
          @graph << [bn_id, BF.identifierValue, value]
          @graph << [bn_id, BF.identifierScheme, 'local']
        end
      end

      if lang = field['l']
        lang.chop! if lang[-1] == '.'
        entry = ISO_639.find_by_english_name(lang)
        if (entry)
          @graph << [subject, BF.language, RDF::URI.new("http://id.loc.gov/vocabulary/languages/"+entry.alpha3)]
        else
          @graph << [subject, BF.languageNote, lang]
        end

        tlabel = field.subfields.reject{|s| %w(l 0 6 8).include?(s.code)}.map{|s| s.value}.join(' ')
        bn_trans = RDF::Node.uuid
        @graph << [subject, BF.translationOf, bn_trans]
        @graph << [bn_trans, RDF.type, BF.Work]
        @graph << [bn_trans, BF.title, tlabel]
        generate_title_non_sort(field, tlabel, BF.title, bn_trans)
        @graph << [bn_trans, MADS.authoritativeLabel, tlabel]
        @graph << [bn_trans, BF.authorizedAccessPoint, tlabel]
        if @record['100']
          bn_agent = RDF::Node.uuid
          @graph << [bn_trans, BF.creator, bn_agent]
          @graph << [bn_agent, RDF.type, BF.Agent]
          @graph << [bn_agent, BF.label, @record['100']['a']]
        end
      end
    end

    # 言語に関するトリプルを作成
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_langs(subject)
      lang_008 = normalize_space(@record['008'].value[35, 3])
      lang_008 = nil if (lang_008 == '   ' || lang_008 == '|||')
      lang_041 = []
      bn_lang = nil
      @record.fields('041').each do |field|
        field.subfields.each do |sf|
          code, value = sf.code, sf.value
          case code
          when 'a'
            lang_041 << value
            bn_lang = RDF::URI.new("http://id.loc.gov/vocabulary/languages/#{value}")
            @graph << [subject, BF.language, bn_lang]
          when /(b|d|e|f|g|h|j|k|m|n)/
            bn_lang = RDF::Node.uuid
            @graph << [subject, BF.language, bn_lang]
            @graph << [bn_lang, RDF.type, BF.Language]
            @graph << [bn_lang, BF.resourcePart, LANG_PART[code]] if LANG_PART[code]
            value.strip.scan(/.{3}/).each do |lang|
              @graph << [bn_lang, BF.languageOfPartUri, RDF::URI.new("http://id.loc.gov/vocabulary/languages/#{lang}")]
            end
          when '2'
            @graph << [bn_lang, BF.languageSource, value]
          end
        end
      end

      if lang_008 && (lang_041.length == 0 || lang_008 != lang_041[0])
        @graph << [subject, BF.language, RDF::URI.new("http://id.loc.gov/vocabulary/languages/#{lang_008}")]
      end
    end

    # 識別子に関するトリプルを作成
    # @param [String] domain 処理対象の実体
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_identifiers(domain, subject)
      properties = []
      SIMPLE_PROPERTIES[domain].each_key do |tag|
        nodes = SIMPLE_PROPERTIES[domain][tag].is_a?(Hash) ? [SIMPLE_PROPERTIES[domain][tag]] :
                                                              SIMPLE_PROPERTIES[domain][tag]
        nodes.each do |node|
          next unless node[:group] == 'identifiers'
          node[:tag] = tag
          properties << node
        end
      end
      return if properties.size == 0

      properties.each do |h|
        next unless h[:ind1] == nil
        @record.fields(h[:tag]).each do |field|
          tag = field.tag
          if h[:uri] == nil || field.has_subfields(%w(b q 2)) ||
            (tag == '037' && field['c']) ||
            (tag == '040' && field['a'] && normalize_space(field['a']).start_with?('Ca'))
            bn_identifier = RDF::Node.uuid
            @graph << [subject, BF[h[:property]], bn_identifier]
            @graph << [bn_identifier, RDF.type, BF.Identifier]
            @graph << [bn_identifier, BF.identifierScheme, h[:property]]
            @graph << [bn_identifier, BF.identifierValue, field['a'].strip]
            field.values_of(%w(b 2)).each do |value|
              @graph << [bn_identifier, BF.identifierAssigner, value]
            end
            unless tag == '856'
              field.values_of('q').each do |value|
                @graph << [bn_identifier, BF.identifierQualifier, value]
              end
            end
            if tag == '037'
              field.subfiels.values_of('c').each do |value|
                @graph << [bn_identifier, BF.identifierQualifier, value]
              end
            end
          else
            generate_simple_property(field, domain, subject)
          end
          field.each do |sbfield|
            if (%w(010 015 016 017 020 022 024 027 030 088).include?(field.tag) && sbfield.code == 'z') ||
               (field.tag == '022' && %w(m y).include?(sbfield.code))
              bn_identifier = RDF::Node.uuid
              @graph << [subject, BF[h[:property]], bn_identifier]
              @graph << [bn_identifier, RDF.type, BF.Identifier]
              @graph << [bn_identifier, BF.identifierScheme, h[:property]]
              @graph << [bn_identifier, BF.identifierValue, normalize_space(sbfield.value)]
              if field.tag == '022' && sbfield.code == 'y'
                @graph << [bn_identifier, BF.identifierStatus, 'incorrect']
              else
                @graph << [bn_identifier, BF.identifierStatus, 'canceled/invalid']
              end
            end
          end
        end
      end
    end

    # 学位論文に関するトリプルを作成（ただし$abdはgenerate_simple_propertyで処理）
    # @param [MARC::Datafield] field 処理対象フィールド（502固定)
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_dissertations(field, subject)
      if field['c']
        bn_organ = RDF::Node.uuid
        @graph << [subject, BF.dissertationInstitution, bn_organ]
        @graph << [bn_organ, RDF.type, BF.Organization]
        @graph << [bn_organ, BF.label, field['c']]
      end
      if field['o']
        bn_id = RDF::Node.uuid
        @graph << [subject, BF.dissertationIdentifier, bn_id]
        @graph << [bn_id, RDF.type, BF.Identifier]
        @graph << [bn_id, BF.identifierValue, field['o']]
      end
    end

    # 著者に関するトリプルを作成
    # @param [MARC::Datafield] field 処理対象フィールド (100|110|111|700|710|711|720)
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_names(field, subject)
      resource_role = get_resource_role(field)
      bf_class = get_bf_class(field)
      label = get_label(field)

      bn_name = RDF::Node.uuid
      @graph << [subject, resource_role, bn_name]
      @graph << [bn_name, RDF.type, bf_class]
      @graph << [bn_name, BF.label, label]
      unless field.tag == '534'
        @graph << [bn_name, BF.authorizedAccessPoint, label]
        auth_uri = if resolve
          if @source == 'ndl'
            field['0'] ? RDF::URI.new("http://id.ndl.go.jp/auth/ndlna/#{field['0']}") : nil
          else
            auth_id = getAuthorityID(bf_class.label, label)
            auth_id ? RDF::URI.new(auth_id) : nil
          end
        end
        if auth_uri
         @graph << [bn_name, BF.hasAuthority, auth_uri]
        else
          ## TODO これは必要か（mads vocabularyを使用）
          generate_element_list(label, bn_name)
        end
      end

      generate_880_label(field, "name", bn_name) if field['6']
      generate_from_856(field, bn_name)
    end

    # タイトルに関連するトリプルを作成
    # @param [MARC::Datafield] field 処理対象フィールド (243|245|247)
    # @param [String] domain 処理対象のリソース種別
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_title(field, domain, subject)
      title = get_title(field)
      element_name = get_element_name(field, domain)
      xml_lang = (field.tag == '242' && field['y']) ? field['f'] : nil
      title_literal = xml_lang ? RDF::Literal.new(title, :language => xml_lang.to_sym) : title
      title_type = get_title_type(field)

      bn_title = RDF::Node.uuid
      @graph << [subject, BF.title, title_literal]
      @graph << [subject, element_name, bn_title]
      @graph << [bn_title, RDF.type, BF.Title]
      if title_type
        @graph << [bn_title, BF.titleType, title_type]
      else
        generate_simple_property(field, 'title', bn_title)
        generate_880_label(field, 'title', bn_title)
      end
      generate_title_non_sort(field, title, element_name, bn_title)
      unless @source == 'ndl'
        field.values_of('0').each do |value|
          handle_system_number(value, bn_title)
        end
      end
    end

    # イベントに関連するトリプルを作成
    #   TODO: 該当するデータが見つからず未チェック
    # @param [MARC::Datafield] field 処理対象フィールド (033)
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_events(field, subject)
      bn_event = RDF::Node.uuid
      @graph << [subject, BF.event, bn_event]
      @graph << [bn_event, RDF.type, BF.Event]
      subfields = field.subfields
      subfields.each_index do |i|
        case subfields[i].code
        when 'a'
          @graph << [bn_event, BF.eventDate, get_event_date(field)]
        when 'b'
          @graph << [bn_event, BF.eventPlace, get_event_place(field, i)]
        when 'p'
          bn_place = RDF::Node.uuid
          @graph << [bn_event, BF.eventPlace, bn_place]
          @graph << [bn_place, RDF.type, BF.Place]
          @graph << [bn_place, BF.label, subfields[i].value]
          if subfields[i+1] && subfields[i+1].code == '0'
            @graph << [bn_place, BF.systemNumber, subfields[i+1].value]
          end
        end
      end
    end

    # 対象読者注記に関連するトリプルを作成
    #   TODO: 該当するデータが見つからず未チェック
    # @param [MARC::Datafield] field 処理対象フィールド (521)
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_audience_521(field, subject)
      if field['a']
        bn_audience = RDF::Node.uuid
        @graph << [subject, BF.intendedAudience, bn_audience]
        @graph << [bn_audience, RDF.type, BF.IntendedAudience]
        field.values_of('a').each do |value|
         @graph << [bn_audience, BF.audience, value]
        end
        @graph << [bn_audience, BF.audienceAssigner, field['b']] if field['b']
      end
    end

    # 調査補助注記に関連するトリプルを作成
    #   TODO: 該当するデータが見つからず未チェック
    # @param [MARC::Datafield] field 処理対象フィールド (555)
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_findaids(field, subject)
      if field['u']
        generate_find_aid_work(field, subject)
      else
        generate_simple_property(field, 'findingaid', subject)
      end
    end

    # TAG(856|859)からInstance, Annotationを作成
    # @param [MARC::Datafield] field 処理対象フィールド (856|859)
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_from_856(field, subject)
      if %w(856 859).include?(field.tag)
        field.each do |sbfield|
          if sbfield.code == '3' && sbfield.value =~ /contributor/i
            generate_instance_from856(field, "person", subject)
          elsif sbfield.code == '3'
            generate_instance_from856(field, "work", subject)
          end
        end
      end
    end

    # TAG520からAnnotationを作成
    # @param [MARC::Datafield] field 処理対象フィールド (520)
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_abstract(field, subject)
      if field['c'] || field['u']
        generate_abstract_annotation_graph(field, subject)
      else
        generate_simple_property(field, 'work', subject)
      end
    end

    # 対象読者に関連するトリプルを作成
    # @param [MARC::Datafield] field 処理対象フィールド (008)
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_audience(field, subject)
      return unless MARC::ControlField.control_tag?(field.tag)

      audience = field.value[22]
      type008 = get_type_of_008
      if audience != ' ' && %w(BK CF MU VM).include?(type008) && TARGET_AUDIENCES[audience]
        @graph << [subject, BF.intendedAudience, RDF::URI.new("http://id.loc.gov/vocabulary/targetAudiences/#{TARGET_AUDIENCES[audience]}")]
      end
    end

    # 資料範疇に関連するトリプルを作成
    #   TODO: 現在のところ、rtype='Work'は対象外で意味のないメソッドとなっている。
    #         今後、BF.Categoryでトリプルを作成するようになるのではないか?
    # @param [MARC::Datafield] field 処理対象フィールド (008)
    # @param [String] rtype リソース種別
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_genre(field, rtype, subject)
      genre = field.value[23]
      if FORMS_OF_ITEMS[genre] && FORMS_OF_ITEMS[genre][:rtype].include?(rtype)
        @graph << [subject, BF.genre, FORMS_OF_ITEMS[genre][:form]]
      end
    end

    # 地図に関連するトリプルを作成
    # @param [MARC::Datafield] field 処理対象フィールド (255)
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_cartography(field, subject)
      generate_simple_property(field, 'cartography', subject)
    end

    # 件名に関連するトリプルを作成
    #   TODO: MADSボキャブラリを使った詳細情報は無視した
    # @param [MARC::Datafield] field 処理対象フィールド
    #                               (600|610|611|648|650|651|654|655|656|657|658|662|653|751|752)
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_subjects(field, subject)
      if type = SUBJECTS_TYPES[field.tag]
        type = 'Work' if field.tag == '600' && field['t']
        label = get_subject_label(field)
        bn_subject = RDF::Node.uuid
        @graph << [subject, BF.subject, bn_subject]
        @graph << [bn_subject, RDF.type, BF[type]]
        @graph << [bn_subject, BF.authorizedAccessPoint, label]
        auth_uri = if @resolve
          if @source == 'ndl'
            field['0'] ? RDF::URI.new("http://id.ndl.go.jp/auth/ndlsh/#{field['0']}") : nil
          else
            auth_id = getAuthorityID(BF[type].label, label)
            auth_id ? RDF::URI.new(auth_id) : nil
          end
        end
        @graph << [bn_subject, BF.hasAuthority, auth_uri] if auth_uri
        @graph << [bn_subject, BF.label, label]
        generate_880_label(field, 'subject', bn_subject)
        unless @source == 'ndl'
          field.values_of('0').each do |value|
            handle_system_number(value, bn_subject)
          end
        end
      end
    end

    # 地理コードに関連するトリプルを作成
    # @param [MARC::Datafield] field 処理対象フィールド (043)
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_gacs(field, subject)
      field.values_of('a').each do |value|
        gac = normalize_space(value).gsub(/[\-\+\$]/, '')
        @graph << [subject, BF.subject, RDF::URI.new("http://id.loc.gov/vocabulary/geographicAreas/#{gac}")]
      end
    end

    # 分類に関連するトリプルを作成
    # @param [MARC::Datafield] field 処理対象フィールド
    #                               (060|061|086|050|055|070|080|082|083|084|086)
    # @param [String] domain 処理対象のリソース種別
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_classes(field, domain, subject)
      case field.tag
      when /(060|061)/
        field.values_of('a').each do |value|
          classification = normalize_space(value.split(' ')[0])
          @graph << [subject, BF.classificationNlm, RDF::URI.new("http://nlm.example.org/classification/#{classification}")]
        end
      when '086'
        field.each do |sf|
          next unless sf.code == 'a' || sf.code == 'z'
          bn_class = RDF::Node.uuid
          @graph << [subject, BF.classification, bn_class]
          @graph << [bn_class, RDF.type, BF.Classification]
          if field.indicator1 == ' ' && field['2']
            @graph << [bn_class, BF.classificationScheme, field['2']]
          elsif field.indicator1 == '0'
            @graph << [bn_class, BF.classificationScheme, 'SUDOC']
          elsif field.indicator1 == '1'
            @graph << [bn_class, BF.classificationScheme, 'Government of Canada classification']
          end
          @graph << [bn_class, BF.classificationNumber, sf.value]
          @graph << [bn_class, BF.classificationStatus, 'canceled/invalid'] if sf.code == 'z'
        end
      when /(050|055|070|080|082|083|084)/
        field.each do |sf|
          next unless sf.code == 'a'
          tag, ind1, ind2 = field.tag, field.indicator1, field.indicator2
          classification = sf.value
          if %w(050 055).include?(tag)
            classification = classification.sub(/(\s+|\.).+$/, '')
            classification = nil unless VALID_LCC.include?(classification.sub(/\d+/, ''))
          end
          next unless classification
          if (field.codes.size == 1 && field['a']) ||
             (field.codes.size == 2 && field['b'])
            property = get_class_property(domain, tag)
            property = 'classification' unless property
            case property
            when 'classificationLcc'
              @graph << [subject, BF.classificationLcc, RDF::URI.new("http://id.loc.gov/authorities/classification/#{classification}")]
            when 'classificationDdc'
              @graph << [subject, BF.classificationDdc, RDF::URI.new("http://dewey.info/class/#{classification}/about")]
            else
              bn_class = RDF::Node.uuid
              @graph << [subject, BF[property], bn_class]
              @graph << [bn_class, RDF.type, BF.Classification]
              @graph << [bn_class, BF.classificationNumber, classification]
              @graph << [bn_class, BF.classificationScheme, property]
            end
          else
            assigner = if tag == '050' && ind2 == '0' then 'dlc'
              elsif %w(060 061).include?(tag) then 'dnlm'
              elsif %w(070 071).include?(tag) then 'dnal'
              elsif %w(082 083 084).include?(tag) && field['q'] then field['q']
              else nil
              end
            bn_class = RDF::Node.uuid
            @graph << [subject, BF.classification, bn_class]
            @graph << [bn_class, RDF.type, BF.Classification]
            scheme = case tag
             when '050' then 'lcc'
             when '060' then 'nlm'
             when '080' then 'udc'
             when '082', '083' then 'ddc'
             when '084'
              if field['2'] then field['2'] else nil end
             else nil
            end
            @graph << [bn_class, BF.classificationScheme, scheme] if scheme
            if %w(082 083).include?(tag) && field['m']
              if field['m'] == 'a'
                @graph << [bn_class, BF.classificationDesignation, 'standard']
              elsif field['m'] == 'b'
                @graph << [bn_class, BF.classificationDesignation, 'optional']
              end
            end
            @graph << [bn_class, BF.classificationNumber, classification]
            @graph << [bn_class, BF.label, classification]
            @graph << [bn_class, BF.classificationAssigner, RDF::URI.new("http://id.loc.gov/vocabulary/organizations/#{assigner}")] if assigner
            if (%w(080 082 083).include?(tag) && %w(0 1).include?(ind1)) ||
               (%w(082 083).include?(tag) && field['2'])
              edition = if %w(080 082 083).include?(tag) && ind1 == '1' then 'abridged'
                elsif %w(080 082 083).include?(tag) && ind1 == '0' then 'full'
                elsif %w(082 083).include?(tag) && field['2'] then field['2']
                else nil
                end
              @graph << [bn_class, BF.classificationEdition, edition] if edition
            end
            generate_simple_property(field, 'classification', bn_class) if tag == '083'
          end
        end
      end
    end

    # Tag505 (Formatted Contents Note) からトリプルを作成
    # @param [MARC::Datafield] field 処理対象フィールド (505)
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_complex_notes(field, subject)
      return unless field.indicator2 == '0'
      codes = field.codes(false)
      codes.delete('t')
      notes =[]
      note = {}
      field.subfields.each do |sb|
        if  sb.code == 't'
          if note.has_key?(:title)
            notes << note
            note = {}
          end
          note[:title] = sb.value.gsub(/ \//, '')
        else
          value = sb.value.gsub(/ --/, '')
          case sb.code
          when 'r'
            note[:element] = 'creator'
            note[:value] = value.split(';')
          when 'u'
            note[:element] = 'resource'
            note[:uri] = RDF::URI.new(value)
          else
            note[:element] = 'note'
            note[:value] = value
          end
        end
      end
      notes << note if note.has_key?(:title)

      notes.each do |nt|
        uri_work = nt[:uri] ? nt[:uri] : RDF::Node.uuid
        @graph << [subject, BF.hasPart, uri_work]  # BF.contains is Deleted, duplicated hasPart.
        @graph << [uri_work, RDF.type, BF.Work]
        @graph << [uri_work, BF.title, nt[:title]]
        case nt[:element]
        when 'note'
          @graph << [uri_work, BF.note, nt[:value]]
        when 'creator'
          nt[:value].each do |value|
            bn_agent = RDF::Node.uuid
            @graph << [uri_work, BF.creator, bn_agent]
            @graph << [bn_agent, RDF.type, BF.Agent]
            @graph << [bn_agent, BF.label, value]
          end
        end
      end
    end

    # リソース間の関係に関連するトリプルを作成する
    # @param [MARC::Datafield] field 処理対象フィールド
    #   (400|410|411|430|440|490|533|534|630|700|710|711|720|730|740|760|762|765|767|770|772|773|774|775|776|777|780|785|786|787|800|810|811|830)
    # @param [String] domain 処理対象のリソース種別
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_related_works(field, domain, subject)
      tag, ind2 = field.tag, field.indicator2
      case tag
      when /(730|740|772|780|785)/
        property = getRelationship(domain, tag, ind2)
        generate_related_works_graph(field, property, subject)
      when '533'
        property = getRelationship(domain, tag, nil)
        generate_related_reporoduction(field, property, subject)
      when /(700|710|711|720)/
        return unless field['t'] && ind2 == '2'
        property = getRelationship(domain, tag, ind2)
        generate_related_works_graph(field, property, subject)
      when /(440|490|630|830)/
        return unless field['a']
        property = getRelationship(domain, tag, nil)
        generate_related_works_graph(field, property, subject)
      when '534'
        return unless field['f']
        property = getRelationship(domain, tag, nil)
        generate_related_works_graph(field, property, subject)
      else
        return unless field['t'] || field['s']
        property = getRelationship(domain, tag, nil)
        generate_related_works_graph(field, property, subject)
      end
    end

    # hash値による bf:authorizedAccessPoint トリプルを作成する
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_hashable(subject)
      ufield = @record['130'] ? @record['130'] : (@record['240'] ? @record['240'] : nil)
      pfield = @record['245']
      title = if ufield && (ufield.codes() - %w(g h k l m n o p r s 0 6 8) != [])
        ufield.subfields.reject{|s| %w(g h k l m n o p r s 0 6 8).include?(s.code)}.map{|s| s.value}.join(' ')
      else
        tstr = pfield.subfields.select{|s| %w(a b).include?(s.code)}.map{|s| s.value}.join(' ')
        pfield.indicator2.to_i > 0 ? tstr[pfield.indicator2.to_i..-1] : tstr
      end
      title = clean_title_string(title)

      name1, name2 = nil, nil
      @record.fields(%w(100 110 111)).each do |field|
        if (field.codes() - %w(e 0 4 6 8)) != []
          name1 = field.subfields.reject{|s| %w(e 0 4 6 8).include?(s.code)}.map{|s| s.value}.join(' ')
          break;
        end
      end
      @record.fields(%w(700 710 711)).each do |field|
        if (field.codes() - %w(e f g h i j k l m n o p q r s t u x 0 3 4 5 6 8)) != []
          name2 = field.subfields.reject{|s| %w(e f g h i j k l m n o p q r s t u x 0 3 4 5 6 8).include?(s.code)}.map{|s| s.value}.join(' ')
          break;
        end
      end
      names = []
      names << name1 if name1
      names << name2 if name2
      name = names.sort.join(' ')

      lang = normalize_space(@record['008'].value[35, 3])
      type = "Work" + get_types().join('')
      hstring = (name + ' / ' + title + ' / ' + lang + ' / ' + type).gsub(/[!\|@#$%^\*\(\)\{\}\[\]:;'"&<>,\.\?~`\+=_\-\/\\ ]/, '').downcase
      @graph << [subject, BF.authorizedAccessPoint, RDF::Literal.new(hstring, :language => 'x-bf-hashable')]
    end

    # 管理関連のトリプルを作成する
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_admin(subject)
      require 'date'
      require 'iso-639'

      lccn = get_lccn
      bn_anno = RDF::Node.uuid
      @graph << [subject, BF.hasAnnotation, bn_anno]
      @graph << [bn_anno, RDF.type, BF.Annotation]
      @graph << [bn_anno, BF.derivedFrom, RDF::URI.new("http://lccn.loc.gov/#{lccn}")] if lccn
      @graph << [bn_anno, BF.generationProcess, "Ruby-rdf: "+DateTime.now.iso8601]
      if @record['005']
        dt = clean_string(@record['005'].value)
        #edited = "%04d-%02d-%02dT%02d:%02d:%02d" % [dt[0,4], dt[4,2], dt[6,2], dt[8,2], dt[10,2], dt[12,2]]
        @graph << [bn_anno, BF.changeDate, DateTime.parse(dt).iso8601]
      end
      @record.fields('040').each do |field|
        generate_simple_property(field, 'annotation', bn_anno)
      end
      case @record.leader[18]
      when 'a'
        @graph << [bn_anno, BF.descriptionConventions, RDF::URI.new("http://id.loc.gov/vocabulary/descriptionConventions/aacr2")]
      when ' '
        @graph << [bn_anno, BF.descriptionConventions, RDF::URI.new("http://id.loc.gov/vocabulary/descriptionConventions/nonisbd")]
      when 'c', 'i'
        @graph << [bn_anno, BF.descriptionConventions, RDF::URI.new("http://id.loc.gov/vocabulary/descriptionConventions/isbd")]
      end
      @graph << [bn_anno, BF.annotates, subject]
    end

    # インスタンスに関連するトリプルを作成する
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_instances(subject)
      isbn_pairs = if @record['020'] && @record['020']['a']
        generate_isbns
      else
        []
      end

      fields = @record.fields(%w(260 261 262 264 300))
      if fields.size > 0
        generate_instance_from260(fields[0], subject, isbn_pairs)
      end
    end

    # タグとリソース種別からトリプルを作成する汎用のメソッド
    # @param [MARC::Datafield] field 処理対象フィールド
    # @param [String] domain 処理対象のリソース種別
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_simple_property(field, domain, subject)
      return if MARC::ControlField.control_tag?(field.tag)
      tag, ind1, ind2 = field.tag, field.indicator1, field.indicator2
      return unless SIMPLE_PROPERTIES[domain] && SIMPLE_PROPERTIES[domain][tag]
      hs = SIMPLE_PROPERTIES[domain][tag]
      nodes = if hs.is_a?(Array)
          hs.select{|n| (n[:ind1] == nil || n[:ind1] == ind1) && (n[:ind2] == nil || n[:ind2] == ind2)}
        elsif hs.is_a?(Hash)
          (hs[:ind1] == nil || hs[:ind1] == ind1) && (hs[:ind2] == nil || hs[:ind2] == ind2) ? [hs] : []
        else
          []
        end
      return if nodes.size == 0

      nodes.each do |node|
        # {domain: "instance", property: "$2", tag: "024", sfcodes: "a", ind1: "7", group: "identifiers"}
        if node[:property]=='$2' && field['2']
          node[:property] = field['2']
        end
        startwith = node[:startwith] ? node[:startwith] : ''
        stringjoin = node[:stringjoin] ? node[:stringjoin] : ' '
        codes = node[:sfcodes] ? node[:sfcodes] : 'a'
        values = []
        case codes.length
        when 0
          next
        when 1
          field.values_of(codes).each do |value|
            values << startwith + value
          end
        else
          value = field.subfields.select{|sf| codes.include?(sf.code) }.map{|sf| sf.value}.join(stringjoin)
          values << startwith + value if value != ''
        end
        values.each do |value|
          if node[:group] == 'identifiers'
            if value.start_with?('(OCoLC)')
              oclcid = value.sub(/\(OCoLC\)/, '').sub(/^(ocm|ocn)/, '')
              @graph << [subject, BF[node[:property]], RDF::URI.new(node[:uri]+oclcid)]
            else
              bn_identifier = RDF::Node.uuid
              @graph << [subject, BF[node[:property]], bn_identifier]
              @graph << [bn_identifier, RDF.type, BF.Identifier]
              @graph << [bn_identifier, BF.identifierValue, value.strip]
              @graph << [bn_identifier, BF.identifierScheme, node[:property]]
            end
          elsif node[:uri] == nil
            @graph << [subject, BF[node[:property]], value]
          elsif node[:uri].include?('loc.gov/vocabulary/organizations')
            if value.length < 10 && !value.include?(' ')
              @graph << [subject, BF[node[:property]], RDF::URI.new(node[:uri]+value.gsub(/-/, ''))]
            else
              @num += 1
              nd_organization = RDF::Node.uuid
              @graph << [subject, BF[node[:property]], nd_organization]
              @graph << [nd_organization, BF.label, value]
            end
          elsif node[:property] == 'lccn'
            @graph << [subject, BF[node[:property]], RDF::URI.new(node[:uri]+value.gsub(/ /, ''))]
          else
            @graph << [subject, BF[node[:property]], RDF::URI.new(node[:uri]+value)]
          end
        end
      end
    end

    private

    # Baseuriを作成する
    # @param [String] baseuri baseuri作成のベースとなるURI。指定がない場合は、sourceから設定する。
    # @param [String] source 変換元のMARC提供機関。現在、(lc|ndl|bl)を用意している。デフォルトは'lc'
    # @param [String] bfrdfレコードのbaseuriとして使用するuri文字列
    def get_baseuri(baseuri=nil, source='lc')
      record_id = @record['001'].value.strip
      base = if baseuri
        baseuri
      else
        case source
        when 'ndl' then 'http://id.ndl.go.jp/bib/'
        when 'bl'  then 'http://bnb.data.bl.uk/doc/resource/'
        else            'http://id.loc.gov/resources/bibs/'
        end
      end
      base + record_id
    end

    # TAG520[(c|u)]からAnnotationを作成
    # param [MARC::Datafield] field 処理対象フィールド (520)
    # param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_abstract_annotation_graph(field, subject)
      if field.indicator1 == '1'
        type_vocab = BF.Review
        invert_vocab = BF.reviewOf
        type_string = "Review"
        bn_anno = RDF::Node.uuid
      else
        type_vocab = BF.Summary
        invert_vocab = BF.summaryOf
        type_string = "Summary"
        bn_anno = RDF::Node.uuid
      end
      @graph << [subject, BF.hasAnnotation, bn_anno]
      @graph << [bn_anno, RDF.type, type_vocab]
      @graph << [bn_anno, BF.label, type_string]
      if field['c']
        field.values_of('c').each do |value|
          @graph << [bn_anno, BF.annotationAssertedBy, value]
        end
      else
        @graph << [bn_anno, BF.annotationAssertedBy, RDF::URI.new('http://id.loc.gov/vocabulary/organizations/dlc')]
      end
      field.values_of('u').each do |value|
        @graph << [bn_anno, BF.annotationBody, RDF::URI.new(value)]
      end
      @graph << [bn_anno, invert_vocab, subject]
    end

    # LC番号を取得
    # @return [String|nil] LC番号。ない場合はnil
    def get_lccn
      if @record['010'] && @record['010']['a']
        value = @record['010']['a'].gsub(/[^0-9]/, '')
        value == '' ? nil : value
      else
        nil
      end
    end

    # leaderとTag008からレコード種別を取得
    # @return [String] 種別コード (BK|SE|MM|CF|MP|VM|MU)
    # @return [nil] 種別不明
    def get_type_of_008
      leader6 = @record.leader[6]
      leader7 = @record.leader[7]
      case leader6
      when 'a'
        case leader7
        when /[acdm]/
          'BK'
        when /[bis]/
          'SE'
        else nil
        end
      when 't' then 'BK'
      when 'p' then 'MM'
      when 'm' then 'CF'
      when /[efs]/ then 'MP'
      when /[gkor]/ then 'VM'
      when /[cdij]/ then 'MU'
      else nil
      end
    end

    # 分類プロパティを返す
    # @param [String] domain 対象となるリソース種別
    # @param [String] tag 対象となるフィールドタグ
    # @return [String|nil] プロパティ名。該当するプロパティがない場合はnil
    def get_class_property(domain, tag)
      CLASSES[domain] ? CLASSES[domain][tag] : nil
    end

    # イベント日時を作成
    # @param [MARC::Datafiele] field 作成対象となるフィールド
    # @return [RDF::Literal] 日付。
    def get_event_date(field)
      case field.indicator1
      when '2'
        field.values_of('a').join('-')
      when '1'
        field.values_of('a').join(', ')
      else
        value = field['a']
        case value
        when /\A\d{4}-\d{2}-\d{2}H\d{2}:\d{2}:\d{2}/
          RDF::Literal.new(value, :datatype => RDF::XSD.dateTime)
        when /\A\d{4}-\d{2}-\d{2}\Z/
          RDF::Literal.new(value, :datatype => RDF::XSD.date)
        when /\A\d{4}-\d{2}\Z/
          RDF::Literal.new(value, :datatype => RDF::XSD.gYearMonth)
        when /\A\d{4}\Z/
          RDF::Literal.new(value, :datatype => RDF::XSD.gYear)
        else
          value
        end
      end
    end

    def get_event_place(field, pos)
      subcode = if field.subfields[pos+1] && field.subfields[pos+1].code == 'c'
        field.subfields[pos+1].value
      else
        nil
      end
      base = 'http://id.loc.gov/authorities/classification/G' +
        normalize_space(field.subfields[pos].value)
      uri = subcode ? base + subcode : base
      RDF::URI.new(uri)
    end

    def generate_find_aid_work(field, subject)
      property = field.indicator1=='0' ? BF.findingAid : BF.index
      bn_findaid = RDF::Node.uuid
      @graph << [subject, property, bn_findaid]
      @graph << [bn_findaid, RDF.type, BF.Work]
      @graph << [bn_findaid, BF.authorizedAccessPoint, field['a']]
      @graph << [bn_findaid, BF.title, field['a']]
      if field['u']
        bn_instance = RDF::Node.uuid
        @graph << [bn_findaid, BF.hasInstance, bn_instance]
        @graph << [bn_instance, RDF.type, BF.Instance]
        handle_856u(field, bn_instance)
      end
    end

    def generate_holdings(subject)
      # marcxml//hld:holdings は無視
      shelfs = []
      targets = @record.tags.select{|t| %w(050 055 060 070 080 082 084).include?(t)}
      if targets.size > 0
        @record.fields(targets).each do |field|
          sfa = field.values_of('a')
          sfb = field.values_of('b')
          values = []
          if sfa.size > 0 && sfb.size > 0
            values << normalize_space(sfa[0] + ' ' + sfb[0])
            values << sfa[1..-1] if sfa.size > 1
          elsif sfa.size > 0
            values = sfa
          end
          property = case field.tag
            when /(050|055|070)/ then BF.shelfMarkLcc
            when '060' then BF.shelfMarkNlm
            when '080' then BF.shelfMarkUdc
            when '082' then BF.shelfMarkDdc
            when '084' then BF.shelfMark
            end
          shelfs << [property, values]
        end
      end

      d852 = []
      @record.fields('852').each do |field|
        field.values_of('a').each do |value|
          d852 << [BF.heldBy, value]
        end
        field.values_of('b').each do |value|
          d852 << [BF.subLocation, value]
        end

        shelf = field.subfields.select{|s| %w(k h l i m t).include?(s.code)}.map{|s| s.value}.join(' ')
        d852 << [BF.shelfMark, shelf] unless shelf == ''
        field.values_of('u').each do |value|
          if value.include?('doi')
            d852 << [BF.doi, RDF::URI.new(value)]
          elsif value.include?('hdl')
            d852 << [BF.hdl, RDF::URI.new(value)]
          else
            d852 << [BF.uri, RDF::URI.new(value)]
          end
        end
        field.values_of('z').each do |value|
          d852 << [BF.copyNote, value]
        end
      end

      @record.fields(%w(051 061 071)).each do |field|
        note = field.subfields.select{|s| %w(a b c).include?(s.code)}.map{|s| s.value}.join(' ')
        d852 << [BF.copyNote, note] unless note == ''
      end

      if shelfs.size > 0 || d852.size > 0
        bn_item = RDF::Node.uuid
        @graph << [subject, RDF::URI.new("http://bibframe.org/vocab/heldItem"), bn_item]   # bf:heldItemは未定義
        @graph << [bn_item, RDF.type, BF.HeldItem]
        @graph << [bn_item, BF.holdingFor, subject]
        @graph << [bn_item, BF.label, shelfs[0][1][0]] if shelfs.size > 0
        shelfs.each do |shelf|
          property, values = shelf
          values.each do |value|
            @graph << [bn_item, property, value]
          end
        end
        @record.fields('561').each do |field|
          generate_simple_property(field, 'helditem', bn_item)
        end
        d852.each do |ary|
          property, object = ary
          @graph << [bn_item, property, object]
        end
      end
    end

    def generate_isbns
      return unless @record['020']
      isbn10 = {}
      isbn13 = {}
      isbn_pairs = []
      @record.fields('020').each do |field|
        field.subfields.each do |s|
          if s.code == 'a'
            isbn = s.value.upcase.gsub(/[^0-9X]/, '')
            next unless /^\d+$/ =~ isbn || /^\d{9}X$/ =~ isbn
            if isbn.length == 10
              isbn10[isbn] = s.value
            elsif isbn.length == 13
              isbn13[isbn] = s.value
            end
          end
        end
      end

      isbn10.each do |isbn, value|
        isbn_13 = get_isbn13(isbn)
        if isbn13.keys.include?(isbn_13)
          isbn_pairs << [isbn, isbn_13, [value, isbn13[isbn_13]]]
          isbn13.delete(isbn_13)
        else
          isbn_pairs << [isbn, isbn_13, [value, nil]]
        end
      end

      isbn13.each do |isbn, value|
        isbn_10 = get_isbn10(isbn)
        isbn_pairs << [isbn_10, isbn, [nil, value]]
      end
      isbn_pairs
    end

    def get_isbn13(isbn)
      digits = '978' + isbn[0...-1]
      multiples = [1, 3] * 6
      total = get_total(digits, multiples)
      digits + (total % 10 == 0 ? '0' : (10 - total % 10).to_s)
    end

    def get_isbn10(isbn)
      digits = isbn[3...-1]
      multiples = [10, 9, 8, 7, 6, 5, 4, 3, 2]
      total = get_total(digits, multiples)
      cd = 11 - total % 11
      digits + (cd == 11 ? '0' : cd == 10 ? 'X' : cd.to_s)
    end

    def get_total(digits, multiples)
      total = 0
      multiples.each_with_index do |n, i|
        total += n * digits[i].to_i
      end
      total
    end

    def generate_instance_from260(field, subject, isbns)
      bn_instance = RDF::Node.uuid
      @graph << [subject, BF.hasInstance, bn_instance]
      @graph << [bn_instance, RDF.type, BF.Instance]
      get_instance_types.each do |type|
        @graph << [bn_instance, RDF.type, BF[type]]
      end
      @record.fields(%w(245 246 247 222 242 210)).each do |f|
        generate_title(f, 'instance', bn_instance)
      end
      if %w(260 264).include?(field.tag)
        generate_publication(field, bn_instance)
      elsif %w(261 262).include?(field.tag)
        generate_26x_publication(field, bn_instance)
      end
      generate_phys_map(bn_instance)
      generate_issuance(bn_instance)
      @record.each do |fld|
        next if /^0/ =~ fld.tag
        generate_simple_property(fld, 'instance', bn_instance)
      end
      generate_500_notes(bn_instance)
      generate_i504(bn_instance)
      generate_identifiers('instance', bn_instance)
      generate_phys_desc('instance', bn_instance)
      @graph << [bn_instance, BF.instanceOf, subject]
      lccn = get_lccn
      @graph << [bn_instance, BF.derivedFrom, RDF::URI.new("http://lccn.loc.gov/#{lccn}")] if lccn
      generate_holdings(bn_instance)
      generate_instance_from_isbn(bn_instance, isbns) if isbns.size > 0
    end

    def get_instance_types
      types = []

      if @record['007']
        cf007 = @record['007'].value
        types << INSTANCE_TYPES['cf007'][cf007] if INSTANCE_TYPES['cf007'].has_key?(cf007)
      end

      @record.fields('336').each do |field|
        %w(a b).each do |code|
          key = 'sf336' + code
          value = field[code]
          types << INSTANCE_TYPES[key][value] if value && INSTANCE_TYPES[key].has_key?(value)
        end
      end

      leader = @record.leader
      @types << INSTANCE_TYPES['leader6'][leader[6]] if INSTANCE_TYPES['leader6'].has_key?(leader[6])
      @types << INSTANCE_TYPES['leader8'][leader[8]] if INSTANCE_TYPES['leader8'].has_key?(leader[8])
      case leader[7]
      when 'a', 'm'
        if leader[19] == 'a'
          types << 'MultipartMonograph'
        else
          types << 'Monograph'
        end
      else
        types << INSTANCE_TYPES['leader7'][leader[7]] if INSTANCE_TYPES['leader7'].has_key?(leader[7])
      end

      types.flatten.uniq
    end

    def generate_publication(field, subject)
      if field['b']
        i = 0
        sfa_values = field.values_of('a')
        sfc_values = field.values_of('c')
        field.subfields.each do |sb|
          next unless sb.code == 'b'
          property = if field.tag == '264' && field.indicator2 == '3'
            BF.manufacture
          elsif field.tag == '264' && field.indicator2 == '2'
            BF.distribution
          else
            BF.publication
          end
          bn_provider = RDF::Node.uuid
          @graph << [subject, property, bn_provider]
          @graph << [bn_provider, RDF.type, BF.Provider]
          bn_organ = RDF::Node.uuid
          @graph << [bn_provider, BF.providerName, bn_organ]
          @graph << [bn_organ, RDF.type, BF.Organization]
          @graph << [bn_organ, BF.label, clean_string(sb.value)]
          generate_880_label(field, 'provider', bn_provider)
          if sfa_values[i]
            bn_place = RDF::Node.uuid
            @graph << [bn_provider, BF.providerPlace, bn_place]
            @graph << [bn_place, RDF.type, BF.Place]
            @graph << [bn_place, BF.label, clean_string(sfa_values[i])]
            generate_880_label(field, 'place', bn_place)
          end
          if sfc_values[i]
            if sfc_values[i].start_with?('c')
              @graph << [bn_provider, BF.copyrightDate, clean_string(sfc_values[i])]
            else
              @graph << [bn_provider, BF.providerDate, chop_puctuation(sfc_values[i], '.')]
            end
          end
          i += 1
        end
      elsif field['a'] || field['c']
        bn_provider = RDF::Node.uuid
        @graph << [subject, BF.publication, bn_provider]
        @graph << [bn_provider, RDF.type, BF.Provider]
        field.values_of('a').each do |value|
          bn_place = RDF::Node.uuid
          @graph << [bn_provider, BF.providerPlace, bn_place]
          @graph << [bn_place, RDF.type, BF.Place]
          @graph << [bn_place, BF.label, value]
          generate_880_label(field, 'place', bn_place)
        end
        field.values_of('c').each do |value|
          if value.start_with?('c')
            @graph << [bn_provider, BF.copyrightDate, clean_string(sfc_values[i])]
          else
            @graph << [bn_provider, BF.providerDate, chop_puctuation(sfc_values[i], '.')]
          end
        end
      elsif field['e']
        sfd_values = field.values_of('d')
        sff_values = field.values_of('f')
        i = 0
        field.values_of('e').each do |value|
          bn_provider = RDF::Node.uuid
          @graph << [subject, BF.manufacture, bn_provider]
          @graph << [bn_provider, RDF.type, BF.Provider]
          bn_organ = RDF::Node.uuid
          @graph << [bn_provider, BF.providerName, bn_organ]
          @graph << [bn_organ, RDF.type, BF.Organization]
          @graph << [bn_organ, BF.label, clean_string(value)]
          generate_880_label(field, 'place', bn_provider)
          if sfd_values[i]
            bn_place = RDF::Node.uuid
            @graph << [bn_provider, BF.providerPalce, bn_place]
            @graph << [bn_place, RDF.type, BF.Place]
            @graph << [bn_place, BF.label, clean_string(sfd_values[i])]
            generate_880_label(field, 'place', bn_place)
          end
          if sff_values[i]
            if sff_values.start_with?('c')
              @graph << [bn_provider, BF.providerDate, chop_puctuation(sff_values[i], '.')]
            end
          end
          i += 1
        end
      elsif field['d'] || field['f']
        bn_provider = RDF::Node.uuid
        @graph << [subject, BF.publication, bn_provider]
        @graph << [bn_provider, RDF.type, BF.Provider]
        field.values_of('d').each do |value|
          bn_place = RDF::Node.uuid
          @graph << [bn_provider, BF.providerPlace, bn_place]
          @graph << [bn_place, RDF.type, BF.Place]
          @graph << [bn_place, BF.label, value]
          generate_880_label(field, 'place', bn_place)
        end
        field.values_of('f').each do |value|
          @graph << [bn_provider, BF.providerDate, chop_puctuation(sfc_values[i], '.')]
        end
      end
    end

    def generate_26x_publication(field, subject)
      bn_provider = RDF::Node.uuid
      @graph << [subject, BF.publication, bn_provider]
      @graph << [bn_provider, RDF.type, BF.Provider]
      name = if field.tag == '261' && field['a']
        field['a']
      elsif field.tag == '262' && field['b']
        field['b']
      else
        nil
      end
      if name
        bn_organ = RDF::Node.uuid
        @graph << [bn_provider, BF.providerName, bn_organ]
        @graph << [bn_organ, RDF.type, BF.Organization]
        @graph << [bn_organ, BF.label, clean_string(name)]
      end
      place = if field.tag == '261' && field['f']
        field['f']
      elsif field.tag == '262' && field['a']
        field['a']
      else
        nil
      end
      if place
        bn_place = RDF::Node.uuid
        @graph << [bn_provider, BF.providerPlace, bn_place]
        @graph << [bn_place, RDF.type, BF.Place]
        @graph << [bn_place, BF.label, clean_string(place)]
      end
      date = if field.tag == '261' && field['d']
        field['d']
      elsif field.tag == '262' && field['c']
        field['c']
      else
        nil
      end
      if date
        @graph << [bn_provider, BF.providerDate, chop_puctuation(date)]
      end
    end

    def generate_phys_map(subject)
      if @record['034']
        @record.fields('034') do |field|
          field.subfields.each do |sb|
            case sb.code
            when 'a'
              scale = case sb.value
                when 'a' then 'Linear scale'
                when 'b' then 'Angular scale'
                when 'z' then 'Other type'
                else 'invalid'
                end
              @graph << [subject, BF.cartographicScale, scale]
            when 'b', 'c'
              @graph << [subject, BF.cartographicScale, sb.value]
            when /[defg]/
              @graph << [subject, BF.cartographicCoordinates, sb.value]
            end
          end
        end
      end

      if @record['255']
        @record.fields('255') do |field|
          field.subfields.each do |sb|
            case sb.code
            when 'a'
              @graph << [subject, BF.cartographicScale, sb.value]
            when 'b'
              @graph << [subject, BF.cartographicProjection, sb.value]
            when 'c'
              @graph << [subject, BF.cartographicCoordinates, sb.value]
            end
          end
        end
      end
    end

    def generate_issuance(subject)
      leader = @record.leader
      issuance = case leader[7]
        when /[acdm]/ then 'monograph'
        when 'b' then 'continuing'
        when 'm'
          if /[abc]/ =~ leader[19]
            'multipart monograph'
          elsif leader[19] == ' '
            'single unit'
          else nil
          end
        when 'i' then 'integrating resource'
        when 's' then 'serial'
        else nil
        end
      if issuance
        @graph << [subject, BF.modeOfIssuance, issuance]
      end
    end

    def generate_500_notes(subject)
      targets = @record.tags.select{|t| t.start_with?('5')}.reject{|t| %w(500 502 504 505 506 507 508 511 513 518 522 524 525 541 546 555).include?(t)} # 520?
      if targets.size > 0
        @record.fields(targets).each do |field|
          note = field.subfields.select{|s| %w(3 a).include?(s.code)}.map{|s| s.value}.join(' ')
          @graph << [subject, BF.note, note] unless note == ''
        end
      end
    end

    def generate_i504(subject)
      @record.fields('504').each do |field|
        value = normalize_space(field['a'] + (field['b'] ? ' Referances: ' + field['b'] : ''))
        @graph << [subject, BF.supplementaryContentNote, value]
      end
    end

    def generate_phys_desc(domain, subject)
      if  domain == 'instance'
        @record.fields('337').each do |field|
          src = field['2']
          if src == 'rdamedia'
            if field['a']
              field.values_of('a').each do |value|
                @graph << [subject, BF.mediaCategory, RDF::URI.new("http://id.loc.gov/vocabulary/mediaTypes/#{MEDIA_TYPES_CODE[value]}")] if MEDIA_TYPES_CODE[value]
              end
            elsif field['b']
              field.values_of('b').each do |value|
                @graph << [subject, BF.mediaCategory, RDF::URI.new("http://id.loc.gov/vocabulary/mediaTypes/#{value}")]
              end
            end
          elsif field['a']
            field.values_of('a').each do |value|
              bn_category = RDF::Node.uuid
              @graph << [subject, BF.mediaCategory, bn_category]
              @graph << [bn_category, RDF.type, BF.Category]
              @graph << [bn_category, BF.label, value]
              @graph << [bn_category, BF.categoryValue, value]
              @graph << [bn_category, BF.categoryType, "media category"]
            end
          end
        end
        @record.fields('338').each do |field|
          src = field['2']
          if src == 'rdacarrier'
            if field['a']
              field.values_of('a').each do |value|
                if CARRIERS_CODE[value]
                  @graph << [subject, BF.carrierCategory, RDF::URI.new("http://id.loc.gov/vocabulary/carriers/#{CARRIERS_CODE[value]}")]
                else
                  bn_category = RDF::Node.uuid
                  @graph << [subject, BF.carrierCategory, bn_category]
                  @graph << [bn_category, RDF.type, BF.Category]
                  @graph << [bn_category, BF.categoryType, value]
                end
              end
            elsif field['b']
              field.values_of('b').each do |value|
                @graph << [subject, BF.carrierCategory, RDF::URI.new("http://id.loc.gov/vocabulary/carriers/#{value}")]
              end
            end
          elsif field['a']
            field.values_of('a').each do |value|
              @graph << [subject, BF.carrierCategory, RDF::URI.new("http://somecarrier.example.org/#{calue}")]
            end
          end
        end
        @record.fields('362').each do |field|
          supplement = field['a']
          if field.indicator1 == '0' && supplement.include?('-')
            first, last = supplement.split('-')
            @graph << [subject, BF.serialFirstIssue, normalize_space(first)] if first
            @graph << [subject, BF.serialLastIssue, normalize_space(last)] if last
          else
            @graph << [subject, BF.serialFirstIssue, normalize_space(supplement)] if supplement
          end
        end
        @record.fields('351').each do |field|
          bn_arrangement = RDF::Node.uuid
          @graph << [subject, BF.arrangement, bn_arrangement]
          @graph << [bn_arrangement, RDF.type, BF.Arrangement]
          generate_simple_property(field, 'arrangment', bn_arrangement)
        end
      else # work
        @record.fields('336').each do |field|
          src = field['2']
          if src == 'rdacontent'
            if field['a']
              field.values_of('a').each do |value|
                @graph << [subject, BF.contentCategory, RDF::URI.new("http://id.loc.gov/vocabulary/contentTypes/#{CONTENT_TYPES_CODE[value]}")] if CONTENT_TYPES_CODE[value]
              end
            elsif field['b']
              field.values_of('b').each do |value|
                @graph << [subject, BF.contentCategory, RDF::URI.new("http://id.loc.gov/vocabulary/contentTypes/#{value}")]
              end
            end
          elsif field['a']
            field.values_of('a').each do |value|
              bn_category = RDF::Node.uuid
              @graph << [subject, BF.contentCategory, bn_category]
              @graph << [bn_category, RDF.type, BF.Category]
              @graph << [bn_category, BF.categoryValue, value]
              @graph << [bn_category, BF.categoryType, "content category"]
            end
          end
        end
        SIMPLE_PROPERTIES['contentcategory'].each_key do |tag|
          h = SIMPLE_PROPERTIES['contentcategory'][tag]
          @record.fields(tag).each do |field|
            field.values_of(h[:sfcodes]).each do |value|
              bn_category = RDF::Node.uuid
              @graph << [subject, BF.contentCategory, bn_category]
              @graph << [bn_category, RDF.type, BF.Category]
              @graph << [bn_category, BF.categoryValue, value]
              @graph << [bn_category, BF.categoryType, "content category"]
            end
          end
        end
      end
    end

    # @params isbns [isbn10, isbn13, [orig_isbn10, orig_isbn13]]
    def generate_instance_from_isbn(subject, isbns)
      isbns.each do |ary|
        isbn10, isbn13, orig = ary
        extra =
          if /\((.*)\)/ =~ orig[0]
            $~[1]
          elsif /\((.*)\)/ =~ orig[1]
            $~[1]
          else
            nil
          end
        vol, form = nil, nil
        if extra
          form = case extra
            when /(pbk|softcover)/i then 'paperback'
            when /(hbk|hdbk|hardcover|hc|hard)/i then 'hardback'
            when /(ebook|eresource|e-isbn|ebk)/i then 'electronic resource'
            when /lib\. bdg\./i then 'library binding'
            when /(acid-free|acid free|alk)/i then 'acid free'
            end

          if /(v\.|vol)/i =~ extra
            vol = extra
            if /(pbk|softcover|hbk|hdbk|hardcover|hc|hard|ebook|eresource|e-isbn|ebk|lib\. bdg\.|acid-free|acid free|alk)/i =~ vol
              vol = normalize_space($~.pre_match + $~.post_match)
            end
          end
        end

        @graph << [subject, BF.isbn10, RDF::URI.new("http://isbn.example.org/#{isbn10}")]
        @graph << [subject, BF.isbn13, RDF::URI.new("http://isbn.example.org/#{isbn13}")]
        if form || vol
          bn_id = RDF::Node.uuid
          @graph << [subject, BF.isbn10, bn_id]
          @graph << [bn_id, RDF.type, BF.Identifier]
          @graph << [bn_id, BF.identifierValue, isbn10]
          @graph << [bn_id, BF.identifierScheme, "isbn"]
          @graph << [bn_id, BF.identifierQualifier, form] if form
          @graph << [bn_id, BF.identifierQualifier, vol] if vol
        end
      end
    end

    def get_resource_role(field)
      relator_code = field['4'] ? field['4'] : field['e']
      if relator_code
        RDF::URI.new('relators:'+relator_code)
      elsif field.tag.start_with?('1')
        BF.creator
      elsif field.tag.start_with?('7') && field['t']
        BF.creator
      else
        BF.contributor
      end
    end

    def get_bf_class(field)
      if field.tag.end_with?('00') && field.indicator1 == '3'
        BF.Family
      elsif field.tag.end_with?('00')
        BF.Person
      elsif field.tag.end_with?('10')
        BF.Organization
      elsif field.tag.end_with?('11')
        BF.Meeting
      elsif field.tag == '720' && field.indicator1 == '1'
        BF.Person
      elsif field.tag == '720' && field.indicator1 == '2'
        BF.Organization
      else
        BF.Agent
      end
    end

    def get_label(field)
      label = if field.tag == '534'
        field['a']
      else
        field.subfields.select{|sb| %w(a b c d q n).include?(sb.code)}.map{|s| s.value}.join(' ')
      end
      label = clean_name_string(label)
    end

    def generate_element_list(label, subject)
      bn_authority = RDF::Node.uuid
      @graph << [subject, BF.hasAuthority, bn_authority]
      @graph << [bn_authority, RDF.type, RDF::MADS.Authority]
      @graph << [bn_authority, RDF::MADS.authoritativeLabel, label]
    end

    # @param [datafield] field
    # @param [String] workid: "person" or uri string
    # @param [RDF::Resource] subject: the subject of this objects
    def generate_instance_from856(field, workid, subject)
      category = if field.values_of('u').join('').include?('hdl.') && (field['3'] =~ /finding aid/i) == nil
        'instance'
      elsif field['3'] =~ /finding aid/i
        'findaid'
      elsif field['3'] =~ /(pdf|page view)/i
        'instance'
      elsif field.indicator1 == '4' && field.indicator2 == '0'
        'instance'
      elsif field.indicator1 == '4' && field.indicator2 == '1' && field['3'] == nil
        'instance'
      else
        'annotation'
      end

      type = if field.values_of('u').join('').include?('catdir.')
        case field['3']
        when /contents/i
          'table of contents'
        when /sample/i
          'sample text'
        when /contributor/i
          'contributor biography'
        when /publisher/i
          'publisher summary'
        else
          nil
        end
      else
        nil
      end

      if category == 'instance'
        bn_instance = RDF::Node.uuid
        @graph << [subject, BF.hasInstance, bn_instance]
        @graph << [bn_instance, RDF.type, BF.Instance]
        @graph << [bn_instance, RDF.type, BF.Electronic]
        if field['3']
          @graph << [bn_instance, BF.label, normalize_space(field['3'])]
        else
          @graph << [bn_instance, BF.label, 'Electronic Resource']
        end
        field.values_of('u').each do |value|
          if value.include?('doi')
            @graph << [bn_instance, BF.doi, RDF::URI.new(value)]
          elsif value.include?('hdl')
            @graph << [bn_instance, BF.hdl, RDF::URI.new(value)]
          else
            @graph << [bn_instance, BF.uri, RDF::URI.new(value)]
          end
        end
        @graph << [bn_instance, BF.instanceOf, subject]
        if workid != 'person' && category == 'annotation'
          @graph << [bn_instance, BF.annotates, RDF::URI.new(workid)]
        end
      else
        bn_annotation = RDF::Node.uuid
        @graph << [subject, BF.hasAnnotation, bn_annotation]
        bf_type = case type
          when 'table of contents' then BF.TableOfContents
          when 'publisher summary' then BF.Summary
          else                          BF.Annotation
        end
        @graph << [bn_annotation, RDF.type, bf_type]
        if field['3']
          @graph << [bn_annotation, BF.label, field['3']]
        elsif $type
          @graph << [bn_annotation, BF.label, $type]
        end
        bf_property = case type
          when 'table of contents' then BF.tableOfContents
          when 'publisher summary' then BF.review
          else                          BF.annotationBody
        end
        field.values_of('u').each do |value|
          @graph << [bn_annotation, bf_property, RDF::URI.new(normalize_space(value))]
        end
        field.values_of('z').each do |value|
          @graph << [bn_annotation, BF.copyNote, value]
        end
        if workid != 'person' && category == 'annotation'
          @graph << [bn_annotation, BF.annotates, RDF::URI.new(workid)]
        end
      end
    end


    # リソース間の関係を表すプロパティを返す
    # @param [String] domain 対象となるリソース種別
    # @param [String] tag 対象となるフィールドタグ
    # @param [String] ind2 対象となるフィールドインディケーター2
    # @return [String|nil] 関係を表すプロパティ文字列。該当しない場合はnil
    def getRelationship(domain, tag, ind2)
      return unless RELATIONSHIPS[domain] && RELATIONSHIPS[domain][tag]
      if ind2
        hs = RELATIONSHIPS[domain][tag].find{|h| h[:ind2] == ind2}
        hs ? hs[:property] : nil
      else
        RELATIONSHIPS[domain][tag] ? RELATIONSHIPS[domain][tag][:property] : nil
      end
    end

    # リソース間の関係に関連するトリプルを作成する
    #   generate_related_worksの下請けメソッドで実際のトリプル作成はこのメソッドで行う
    # @param [MARC::Datafield] field 処理対象フィールド (243|245|247)
    # @param [String] domain 処理対象のリソース種別
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    def generate_related_works_graph(field, property, subject)
      return unless property
      sfcodes = case field.tag
        when /(630|730|740)/ then %w(a n p)
        when /(440|490|830)/ then %w(a n p v)
        when '534' then %w(t b f)
        else %w(t f k m n o p s)
        end
      title = clean_title_string(field.subfields.select{|s| sfcodes.include?(s.code)}.map{|s| s.value}.join(' '))
      alabel = ''
      bn_work = RDF::Node.uuid
      if field['a'] && field.tag = '740' and field.indicator2 == '2' &&
        @record.fields(%w(100 110 111)).size > 0
        heading = @reocrd.fields(%w(100 110 111))[0]
        generate_names(heading, bn_work)
        alabel = get_label(field)
      elsif !(%w(400 410 411 440 490 80 810 811 510 630 730 740 830).include?(field.tag)) && field['a']
        generate_names(field, bn_work)
        alabel = get_label(field) if alabel == ''
      end

      alabel = alabel + (alabel ? ' ' : '') + title
      alabel = normalize_space(alabel)
      label_880 = generate_880_label(field, 'title', subject, false)
      @graph << [subject, BF[property], bn_work]
      @graph << [bn_work, RDF.type, BF.Work]
      @graph << [bn_work, BF.label, title]
      @graph << [bn_work, BF.title, title]
      @graph << [bn_work, BF.authorizedAccessPoint, alabel]
      @graph << [bn_work, BF.authorizedAccessPoint, label_880] if label_880
      if field.tag != '630'
        field.subfields.each do |sf|
          next unless %w(w x).include?(sf.code)
          if sf.value.include?('(OCoLC)')
            @graph << [bn_work, BF.systemNumber, RDF::URI.new("http://id.loc.gov/authorities/test/identifiers/lccn/#{clean_id(sf.value)}")]
          elsif sf.code == 'x'
            bn_instance = RDF::Node.uuid
            @graph << [bn_work, BF.hasInstance, bn_instance]
            @graph << [bn_instance, RDF.type, BF.Instance]
            @graph << [bn_instance, BF.label, title]
            @graph << [bn_instance, BF.title, title]
            @graph << [bn_instance, BF.issn, RDF::URI.new("http://issn.example.org/#{clean_string(sf.value).gsub(/ /, '')}")]
          end
        end
      end
      generate_title_non_sort(field, title, BF.title, bn_work)

      if field.tag == '774'
        @graph << [bn_work, BF.partOf, subject]
      end
    end

    def generate_related_reporoduction(field, property, subject)
      return unless property
      title = @record['245']['a']
      carrier = if field['a'] then field['a']
        elsif field['3'] then field['3']
        else nil
        end
      places = field.values_of('b')
      agents = field.values_of('c')
      pdate  = field['d'] ? chop_puctuation(field['d']) : nil
      extent = field['e']
      coverage = field['m']
      notes  = field.values_of('n')

      bn_work = RDF::Node.uuid
      @graph << [subject, BF[property], bn_work]
      @graph << [bn_work, RDF.type, BF.Work]
      @graph << [bn_work, BF.authorizedAccessPoint, title]
      @graph << [bn_work, BF.title, title]
      @graph << [bn_work, BF.label, title]
      if places.size > 0 || agents.size > 0 || notes.size > 0 || pdate || extent || coverage
        bn_instance = RDF::Node.uuid
        @graph << [bn_work, BF.hasInstance, bn_instance]
        @graph << [bn_instance, RDF.type, BF.Instance]
        bn_title = RDF::Node.uuid
        @graph << [bn_instance, BF.instanceTitle, bn_title]
        @graph << [bn_title, RDF.type, BF.Title]
        @graph << [bn_title, BF.label, title]
        if places.size > 0 || agents.size > 0 || pdate
          bn_provider = RDF::Node.uuid
          @graph << [bn_instance, BF.publication, bn_provider]
          @graph << [bn_provider, RDF.type, BF.Provider]
          places.each do |place|
            bn_place = RDF::Node.uuid
            @graph << [bn_provider, BF.providerPlace, bn_place]
            @graph << [bn_place, RDF.type, BF.Place]
            @graph << [bn_place, BF.label, place]
          end
          @graph << [bn_provider, BF.providerDate, pdate] if pdate
          agents.each do |agent|
            bn_agent = RDF::Node.uuid
            @graph << [bn_provider, BF.providerName, bn_agent]
            @graph << [bn_agent, RDF.type, BF.Organization]
            @graph << [bn_agent, BF.label, agent]
          end
          @graph << [bn_instance, BF.extent, extent] if extent
          @graph << [bn_instance, BF.temporalCoverageNote, coverage] if coverage
          if carrier
            bn_catetory = RDF::Node.uuid
            @graph << [bn_instance, BF.carrierCategory, bn_catetory]
            @graph << [bn_catetory, RDF.type, BF.Category]
            @graph << [bn_catetory, BF.categoryValue, carrier]
          end
          notes.each do |note|
            @graph << [bn_instance, BF.note, note]
          end
        end
      end
    end

    # 件名ラベルを作成
    # @return [String] 件名ラベル
    def get_subject_label(field)
      label =
        case field.tag
        when /(600|610|611)/
          cont1 = field.subfields.reject{|s| %w(w v x y z 6).include?(s.code)}.map{|s| s.value}.join(' ')
          cont2 = field.subfields.select{|s| %w(v x y z).include?(s.code)}.map{|s| s.value}.join('--')
          cont1 + (cont2=='' ? '' : '--' + cont2)
        when /(648|650|651|655|751)/
          field.subfields.reject{|s| %w(w 6).include?(s.code)}.map{|s| s.value}.join('--').sub(/\.$/, '')
        when /(662|752)/
          field.subfields.reject{|s| %w(a b c d f g h).include?(s.code)}.map{|s| s.value}.join('. ')
        else
          field.subfields.reject{|s| s.code == '6'}.map{|s| s.value}.join(' ')
        end
      normalize_space(label)
    end

    def get_title(field)
      title = field.subfields.select{|s| %w(a b h k n p s).include?(s.code)}.map{|s| s.value}.join(' ').sub(/\/$/, '').sub(/\.$/, '')
      normalize_space(title)
    end

    def get_element_name(field, domain)
      case
      when %w(246 247 242).include?(field.tag)
        BF.titleVariation
      when field.tag == '222'
        BF.keyTitle
      when field.tag == '210'
        BF.abbreviatedTitle
      when domain == 'work'
        BF.workTitle
      else
        BF.instanceTitle
      end
    end

    def get_title_type(field)
      return unless %w(242 246 247).include?(field.tag)
      case field.tag
      when '242' then 'Translated title'
      when '247' then 'Former title'
      else
        if field.indicator2 == ' ' && field['i']
          field['i']
        else
          case field.indicator2
          when '0' then 'portion'
          when '1' then 'parallel'
          when '2' then 'distinctive'
          when '4' then 'cover'
          when '6' then 'caption'
          when '7' then 'running'
          when '8' then 'spine'
          else nil
          end
        end
      end
    end

    # Tag880の処理
    # @param [MARC::Datafield] field 処理対象フィールド
    # @param [String] domain 処理対象種別
    # @param [RDF::Resource] subject このメソッドのトップレベルで作成されるトリプルの主語
    # @param [boolean] set_graph true: BF.titleValueのトリプルを作成（デフォルト）、
    #                            false: トリプルは作成せず、titleを返す。
    # @return [String] domainが'title'で、set_graphがfalseの時、titleを返す
    # @return [nil] それ以外は返り値はなし
    def generate_880_label(field, domain, subject, set_graph=true)
      return unless field['6'] && field['6'].start_with?('880')

      target = field.tag + '-' + field['6'].split('-')[1][0, 2]
      target_field = @record.fields('880').find {|f| f['6'] && f['6'].start_with?(target)}
      return unless target_field

      scr = target_field['6'].split('/')[1]
      lang = @record['008'].value[35, 3]
      xml_lang = get_xml_lang(scr, lang)
      case domain
      when 'name'
        value = if field.tag == '534'
          target_field['a']
        else
          target_field.subfields.select{|f| %w(a b c d q).include?(f.code)}.map{|f| f.value}.join(' ')
        end
        @graph << [subject, BF.authorizedAccessPoint, RDF::Literal.new(clean_string(value), :language => xml_lang.to_sym)]
      when 'title'
        subfs = if %w(245 242 243 246 490 510 630 730 740 830).include?(field.tag)
          %w(a b f h k n p)
        else
          %w(t f k m n p s)
        end
        value = target_field.subfields.select{|f| subfs.include?(f.code)}.map{|f| f.value}.join(' ')
        if set_graph
          @graph << [subject, BF.titleValue, RDF::Literal.new(clean_title_string(value), :language => xml_lang.to_sym)]
        else
          return RDF::Literal.new(clean_title_string(value), :language => xml_lang.to_sym)
        end
      when 'subject'
        value = target_field.subfields.reject{|f| f.code == '6'}.map{|f| f.value}.join(' ')
        @graph << [subject, BF.authorizedAccessPoint, RDF::Literal.new(clean_title_string(value), :language => xml_lang.to_sym)]
      when 'place'
        target_field.each do |sbfield|
          next unless sbfield.code == 'a'
          value = clean_string(sbfield.value)
          bn_place = RDF::Node.uuid
          @graph << [subject, BF.providerPlace, bn_place]
          @graph << [bn_place, RDF.type, BF.Place]
          if value =~ /[a-zA-Z]/
            @graph << [bn_place, BF.label, value]
          else
            @graph << [bn_place, BF.label, RDF::Literal.new(value, :language => xml_lang.to_sym)]

          end
        end
      when 'provider'
        target_field.each do |sbfield|
          next unless sbfield.code == 'b'
          value = clean_string(sbfield.value)
          bn_provider = RDF::Node.uuid
          @graph << [subject, BF.providerName, bn_provider]
          @graph << [bn_provider, RDF.type, BF.Organization]
          @graph << [bn_provider, BF.label, RDF::Literal.new(value, :language => xml_lang.to_sym)]
        end
      else
        @graph << [subject, BF[domain], target_field['a']]
      end
    end

    def get_xml_lang(scr, lang)
      require 'iso-639'

      entry = ISO_639.find(lang)
      xml_lang = if entry
        entry.alpha2 ? entry.alpha2 : entry.alpha3
      elsif @source == 'ndl'
        'ja'
      else
        'en'
      end
      script  =
        case scr
        when '(3' then 'arab'
        when '(B' then 'latn'
        when '$1'
          case lang
          when 'kor' then 'hang'
          when 'chi' then 'hani'
          when 'jpn' then 'jpan'
          else nil
          end
        when '(N' then 'cyrl'
        when '(S' then 'grek'
        when '(2' then 'hebr'
        else nil
        end
      if script
        xml_lang + '-' + script
      else
        xml_lang
      end
    end

    def generate_title_non_sort(field, title, property, subject)
      title_literal = if %w(222 242 243 245 440 240).include?(field.tag) && field.indicator2.to_i > 0
        RDF::Literal.new(title[field.indicator2.to_i..-1], :language => :"x-bf-sortable")
      elsif %w(130 630).include?(field.tag) && field.indicator1.to_i > 0
        RDF::Literal.new(title[field.indicator1.to_i..-1], :language => :"x-bf-sortable")
      else
        nil
      end

      if title_literal
        @graph << [subject, property, title_literal]
      end
    end

    def handle_856u(field, subject)
      field.values_of('u').each do |value|
        property = case value
          when /doi/ then BF.doi
          when /hdl/ then BF.hdl
          else BF.uri
          end
        @graph << [subject, property, RDF::URI.new(value)]
      end
    end

  end   # BFRDF

end # Bibframe