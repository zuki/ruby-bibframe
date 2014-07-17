# -*- encoding: utf-8 -*-

module Bibframe

  class BFRDF

    include Bibframe::Utils

    attr_reader :graph, :resolve, :baseuri

    def initialize(repository, record, resolve=true, baseuri=nil)
      @record = record
      record_id = @record['001'].value.strip
      record_id += '.' + @record['003'].value.strip.downcase.gsub(/[^a-z]/, '') if @record['003']
      @baseuri = baseuri ? baseuri : "http://id.loc.gov/resources/bibs/" + record_id
      @graph = RDF::Graph.new(RDF::URI.new(@baseuri), {data: repository})
      @num = 0
      @resolve = resolve
      @types = []
      parse
    end

    private

    def parse
      #@baseuri += @record['001'].value
      work = RDF::URI.new(@baseuri)

      # フィールドごとに処理できない（その1）
      @graph << [work, RDF.type, BF.Work]
      generate_work_type(work)
      generate_alabel(work)                              # 130  240 (245) 100 110 111
      generate_uniform_title(work)
      # generate_alabels_work880(subject) 翻訳形のauthor+title 今のロジックでは難しい
      generate_langs(work)
      generate_identifiers('work', work)

      # フィールド毎に処理可能
      @record.each do |field|
        case field.tag
        when '502'
          generate_dissertation(field, work)
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
        when /(060|061|086|050|055|070|080|082|083|084|086)/
          generate_classes(field, 'work', work)
        when '505'
          generate_complex_notes(field, work)
        when /(400|410|411|430|440|490|533|534|630|700|710|711|720|730|740|760|762|765|767|770|772|773|774|775|776|777|780|785|786|787|800|810|811|830)/
          generate_related_works(field, 'work', work)
        when /(856|859)/
          generate_bio_links(field, work)
        end
        # フィールドが設定ファイルで指定されており、独立に処理可能
        generate_simple_property(field, "work", work)
      end

      # フィールドごとに処理できない（その2）
      @graph << [work, BF.derivedFrom, RDF::URI.new(@baseuri)]
      generate_hashtable(work)
      generate_admin(work)
      generate_instances(work)
    end

    def generate_abstract(field, subject)
      if field['c'] || field['u']
        generate_abstract_annotation_graph(field, subject)
      else
        generate_simple_property(field, 'work', subject)
      end
    end

    def generate_abstract_annotation_graph(field, subject)
      if field.indicator1 == '1'
        type_vocab = BF.Review
        invert_vocab = BF.reviewOf
        type_string = "Review"
        uri_anno = get_uri('review')
      else
        type_vocab = BF.Summary
        invert_vocab = BF.summaryOf
        type_string = "Summary"
        uri_anno = get_uri('summary')
      end
      @graph << [subject, BF.hasAnnotation, uri_anno]
      @graph << [uri_anno, RDF.type, type_vocab]
      @graph << [uri_anno, BF.label, type_string]
      if field['c']
        field.each do |sbfield|
          @graph << [uri_anno, BF.annotationAssertedBy, sbfield.value] if sbfield.code == 'c'
        end
      else
        @graph << [uri_anno, BF.annotationAssertedBy, RDF::URI.new('http://id.loc.gov/vocabulary/organizations/dlc')]
      end
      field.each do |sbfield|
        @graph << [uri_anno, BF.annotationBody, RDF::URI.new(sbfield.value)] if sbfield.code == 'u'
      end
      @graph << [uri_anno, type_vocab, subject]
    end

    def generate_admin(subject)
      require 'date'
      require 'iso-639'

      lccn = get_lccn
      uri_anno = get_uri('annotation')
      @graph << [subject, BF.hasAnnotation, uri_anno]
      @graph << [uri_anno, RDF.type, BF.Annotation]
      @graph << [uri_anno, BF.derivedFrom, RDF::URI.new("http://lccn.loc.gov/#{lccn}")] if lccn
      @graph << [uri_anno, BF.generationProcess, "Ruby-rdf: "+DateTime.now.iso8601]
      if @record['005']
        dt = clean_string(@record['005'].value)
        #edited = "%04d-%02d-%02dT%02d:%02d:%02d" % [dt[0,4], dt[4,2], dt[6,2], dt[8,2], dt[10,2], dt[12,2]]
        @graph << [uri_anno, BF.changeDate, DateTime.parse(dt).iso8601]
      end
      @record.fields('040').each do |field|
        generate_simple_property(field, 'annotation', uri_anno)
      end
      case @record.leader[18]
      when 'a'
        @graph << [uri_anno, BF.descriptionConventions, RDF::URI.new("http://id.loc.gov/vocabulary/descriptionConventions/aacr2")]
      when ' '
        @graph << [uri_anno, BF.descriptionConventions, RDF::URI.new("http://id.loc.gov/vocabulary/descriptionConventions/nonisbd")]
      when 'c', 'i'
        @graph << [uri_anno, BF.descriptionConventions, RDF::URI.new("http://id.loc.gov/vocabulary/descriptionConventions/isbd")]
      end
      @graph << [uri_anno, BF.annotates, subject]
    end

    def get_lccn
      if @record['010'] && @record['010']['a']
        value = @record['010']['a'].gsub(/[^0-9]/, '')
        value == '' ? nil : value
      else
        nil
      end
    end

    def generate_alabel(subject)
      title = nil
      @record.fields(%w(130 240)).each do |field|
        title = field.subfields.reject{|s| %w(0 6 8).include?(sbfield.code)}.map{|s| s.value}.join(' ')
        break if alabel != ''
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

    def generate_audience(field, subject)
      audience = field.value[22]
      type008 = get_type_of_008
      if audience != ' ' && %w(BK CF MU VM).include?(type008) && TARGET_AUDIENCES[audience]
        @graph << [subject, BF.intendedAudience, RDF::URI.new("http://id.loc.gov/vocabulary/targetAudiences/#{TARGET_AUDIENCES[audience]}")]
      end
    end

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

    def generate_audience_521(field, subject)
      uri_audience = get_uri('audience')
      @graph << [subject, BF.intendedAudience, uri_audience]
      @graph << [uri_audience, RDF.type, BF.IntendedAudience]
      @graph << [uri_audience, BF.audience, field['a']]
      @graph << [uri_audience, BF.audienceAssigner, field['b']] if field['b']
    end

    def generate_cartography(field, subject)
      generate_simple_property(field, 'cartography', subject)
    end

    def generate_classes(field, domain, subject)
      case field.tag
      when /(060|061)/
        field.values_of('a') do |value|
          classification = normalize_space(value.split(' ')[0])
          @graph << [subject, BF.classificationNlm, RDF::URI.new("http://nlm.example.org/classification/#{classification}")]
        end
      when '086'
        return unless field['z']
        uri_class = get_uri('classification')
        @graph << [subject, BF.classification, uri_class]
        @graph << [uri_class, RDF.type, BF.Classification]
        if field.indicator1 == ' ' && field['2']
          @graph << [uri_class, BF.classificationScheme, field['2']]
        elsif field.indicator1 == '0'
          @graph << [uri_class, BF.classificationScheme, 'SUDOC']
        elsif field.indicator1 == '1'
          @graph << [uri_class, BF.classificationScheme, 'Government of Canada classification']
        end
        @graph << [uri_class, BF.classificationNumber, field['z']]
        @graph << [uri_class, BF.classificationStatus, 'canceled/invalid']
      when /(050|055|070|080|082|083|084|086)/
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
             (field.codes().size == 2 && field['b'])
            property = get_class_property(domain, tag)
            property = 'classification' unless property
            case property
            when 'classificationLcc'
              @graph << [subject, BF.classificationLcc, RDF::URI.new("http://id.loc.gov/authorities/classification/#{classification}")]
            when 'classificationDdc'
              @graph << [subject, BF.classificationDdc, RDF::URI.new("http://dewey.info/class/#{classification}/about")]
            else
              uri_class = get_uri('classification')
              @graph << [subject, BF[property], uri_class]
              @graph << [uri_class, RDF.type, BF.Classification]
              @graph << [uri_class, BF.classificationNumber, classification]
              scheme = if tag == '086' and ind1 = ' ' && field['2'] then field['2']
                elsif tag == '086' and ind1 == '0' then 'SUDOC'
                elsif tag == '086' and ind1 == '1' then 'Government of Canada classification'
                else property
                end
              @graph << [uri_class, BF.classificationScheme, scheme]
            end
          else
            assigner = if tag == '050' && ind2 == '0' then 'dlc'
              elsif %w(060 061).include?(tag) then 'dnlm'
              elsif %w(070 071).include?(tag) then 'dnal'
              elsif %w(082 083 084).include?(tag) && field['q'] then field['q']
              else nil
              end
            uri_class = get_uri('classification')
            @graph << [subject, BF.classification, uri_class]
            @graph << [uri_class, RDF.type, BF.Classification]
            scheme = case tag
             when '050' then 'lcc'
             when '060' then 'nlm'
             when '080' then 'udc'
             when '082', '083' then 'ddc'
             when '084', '086'
              if field['2'] then field['2'] else nil end
             else nil
            end
            @graph << [uri_class, BF.classificationScheme, scheme] if scheme
            if %w(082 083).include?(tag) && field['m']
              if field['m'] == 'a'
                @graph << [uri_class, BF.classificationDesignation, 'standard']
              elsif field['m'] == 'b'
                @graph << [uri_class, BF.classificationDesignation, 'optional']
              end
            end
            @graph << [uri_class, BF.classificationNumber, classification]
            @graph << [uri_class, BF.label, classification]
            @graph << [uri_class, BF.classificationAssigner, RDF::URI.new("http://id.loc.gov/vocabulary/organizations/#{assigner}")] if assigner
            if (%w(080 082 083).include?(tag) && %w(0 1).include?(ind1)) ||
               (%w(082 083).include?(tag) && field['2'])
              edition = if %w(080 082 083).include?(tag) && ind1 == '1' then 'abridged'
                elsif %w(080 082 083).include?(tag) && ind1 == '0' then 'full'
                elsif %w(082 083).include?(tag) && field['2'] then field['2']
                else nil
                end
              generate_property_from_text(tag, '', edition, 'classification', uri_class) if edition
            end
            generate_simple_property(field, 'classification', uri_class) if tag == '083'
          end
        end
      end
    end

    def get_class_property(domain, tag)
      if CLASSES[domain]
        selected = CLASSES[domain].select{|h| h[:tag].include?(tag)}
        return selected[0][:name] if selected.size > 0
      end
    end

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
        uri_work = nt[:uri] ? nt[:uri] : get_uri('work')
        @graph << [subject, BF.contains, uri_work]
        @graph << [uri_work, RDF.type, BF.Work]
        @graph << [uri_work, BF.title, nt[:title]]
        case nt[:element]
        when 'note'
          @graph << [uri_work, BF.note, value]
        when 'creator'
          nt[:value].each do |value|
            uri_agent = get_uri('agent')
            @graph << [uri_work, BF.creator, uri_agent]
            @graph << [uri_agent, RDF.type, BF.Agent]
            @graph << [uri_agent, BF.label, value]
          end
        end
      end
    end

    def generate_name_from_SOR(value, property, subject)
      value = normalize_space(value[3..-1]) if value.include?(' by')
      uri_agent = get_uri('agent')
      @graph << [subject, property, uri_agent]
    end

    def generate_dissertation(field, subject)
      if field['c']
        uri_organ = get_uri('organization')
        @graph << [subject, BF.dissertationInstitution, uri_organ]
        [uri_organ, RDF.type, BF.Organization]
        [uri_organ, BF.label, field['c']]
      end
      if field['o']
        bn_id = RDF::Node.uuid
        @graph << [subject, BF.dissertationIdentifier, bn_id]
        [bn_id, RDF.type, BF.Identifier]
        [bn_id, BF.identifierValue, field['o']]
      end
    end

    # generate_events: event関連トリプルの作成
    #
    # params [MARC::Datafield] field 作成対象のフィールド
    # params [RDF::Resource] subject このトリプルのサブジェクト
    def generate_events(field, subject)
      uri_event = get_uri('event')
      @graph << [subject, BF.envet, uri_event]
      @graph << [uri_event, RDF.type, BF.Event]
      subfields = field.subfields
      subfields.each_index do |i|
        case subfield[i].code
        when 'a'
          @graph << [uri_event, BF.eventDate, get_event_date(field)]
        when 'b'
          @graph << [uri_event, BF.eventPlace, get_event_palce(field, i)]
        when 'p'
          uri_place = get_uri('place')
          @graph << [uri_event, BF.eventPlace, uri_place]
          @graph << [uri_place, RDF.type, BF.Place]
          @graph << [uri_place, BF.label, subfields[i].value]
          if subfields[i+1] && subfields[i+1].code == '0'
            @graph << [uri_place, BF.systemNumber, subfields[i+1].value]
          end
        end
      end
    end

    def get_event_date(field)
      case field.indicator1
      when '2'
        field.values_of('a').join('-')
      when '1'
        field.values_of('a').join(', ')
      else
        RDF::Literal.new(field['a'], :datatype => RDF::XSD.dateTime)
      end
    end

    def get_event_palce(field, pos)
      subcode = if field.subfields[pos+1] && field.subfields[pos+1] == 'c'
        field.subfields[pos+1].value
      else
        nil
      end
      base = 'http://id.loc.gov/authorities/classification/G' +
        nomalize_space(field.subfields[i].value)
      uri = subcode ? base + subcode : base
      RDF::URI.new(uri)
    end

    def generate_findaids(field, subject)
      if field['u']
        generate_find_aid_work(field, subject)
      else
        generate_simple_property(field, 'findingaid', subject)
      end
    end

    def generate_find_aid_work(field, subject)
      property = field.indicator1=='0' ? BF.findingAid : BF.index
      uri_findaid = get_uri('work')
      @graph << [subject, property, uri_findaid]
      @graph << [uri_findaid, RDF.type, BF.Work]
      @graph << [uri_findaid, BF.authorizedAccessPoint, field['a']]
      @graph << [uri_findaid, BF.title, field['a']]
      if field['d']
        uri_instance = get_uri('instance')
        @graph << [uri_findaid, BF.hasInstance, uri_instance]
        @graph << [uri_instance, RDF.type, BF.Instance]
        handle_856u(field, uri_instance)
      end
    end

    def generate_gacs(field, subject)
      if field['a']
        gac = normalize_space(field['a']).gsub(/[\-\+\$]/, '')
        @graph << [subject, BF.subject, RDF::URI.new("http://id.loc.gov/vocabulary/geographicAreas/#{gac}")]
      end
    end

    def generate_genre(field, rtype, subject)
      genre = field.value[23]
      # おそらく BF.Categoryでトリプルを作成するようになる
      if FORMS_OF_ITEMS[genre] && FORMS_OF_ITEMS[genre][:rtype].include?(rtype)
        @graph << [subject, BF.genre, FORMS_OF_ITEMS[genre][:form]]
      end
    end

    def generate_hashtable(subject)
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
          elsif value.include?(hdl)
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
        uri_item = get_uri('helditem')
        #@graph << [subject, BF.heldItem, uri_item]   bf:heldItemが未定義
        @graph << [uri_item, RDF.type, BF.HeldItem]
        @graph << [uri_item, BF.holdingFor, subject]
        @graph << [uri_item, BF.label, shelfs[0][1][0]] if shelfs.size > 0
        shelfs.each do |shelf|
          property, values = shelf
          values.each do |value|
            @graph << [uri_item, property, value]
          end
        end
        @record.fields('561').each do |field|
          generate_simple_property(field, 'helditem', uri_item)
        end
        d852.each do |ary|
          property, object = ary
          @graph << [uri_item, property, object]
        end
      end
    end

    def generate_identifiers(domain, subject)
      properties = SIMPLE_PROPERTIES[domain].select{|h| h[:group] == 'identifiers'}
      return if properties.size == 0

      @record.each do |field|
        next if MARC::ControlField.control_tag?(field.tag)
        tag, ind1, ind2 = field.tag, field.indicator1, field.indicator2
        properties.each do |h|
          next unless h[:tag] == tag && h[:ind1] == nil
          if h[:uri] == nil || field.has_subfields(%w(b q 2)) ||
            (field.tag == '037' && field['c']) ||
            (field.tag == '040' && field['a'] && normalize_space(field['a']).start_with?('Ca'))
            bn_identifier = RDF::Node.uuid
            @graph << [subject, BF[h[:property]], bn_identifier]
            @graph << [bn_identifier, RDF.type, BF.Identifier]
            @graph << [bn_identifier, BF.identifierScheme, h[:property]]
            @graph << [bn_identifier, BF.identifierValue, field['a'].strip]
            field.subfields.select{|s| %w(b 2).include?(s.code)}.map{|s| s.value}.each do |value|
              @graph << [bn_identifier, BF.identifierAssigner, value]
            end
            unless field.tag == '856'
              field.values_of('q').each do |value|
                @graph << [bn_identifier, BF.identifierQualifier, value]
              end
            end
            if field.tag == '037'
              field.subfiels.values_of('c').each do |value|
                @graph << [bn_identifier, BF.identifierQualifier, value]
              end
            end
          else
            generate_simple_property(field, domain, subject)
          end
          field.each do |sbfield|
            next unless %w(m y z).include?(sbfield.code)
            bn_identifier = RDF::Node.uuid
            @graph << [subject, BF[h[:property]], bn_identifier]
            @graph << [bn_identifier, RDF.type, BF.Identifier]
            handle_cancels(field, sbfield, h[:property], bn_identifier)
          end
        end
      end
    end

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
      uri_instance = get_uri('instance')
      @graph << [subject, BF.hasInstance, uri_instance]
      @graph << [uri_instance, RDF.type, BF.Instance]
      get_instance_types.each do |type|
        @graph << [uri_instance, RDF.type, BF[type]]
      end
      @record.fields(%w(245 246 247 222 242 210)).each do |f|
        generate_title(f, 'instance', uri_instance)
      end
      if %w(260 264).include?(field.tag)
        generate_publication(field, uri_instance)
      elsif %w(261 262).include?(field.tag)
        generate_26x_publication(field, uri_instance)
      end
      generate_phys_map(uri_instance)
      generate_issuance(uri_instance)
      @record.each do |fld|
        next if /^0/ =~ fld.tag
        generate_simple_property(fld, 'instance', uri_instance)
      end
      generate_500_notes(uri_instance)
      generate_i504(uri_instance)
      generate_identifiers('instance', uri_instance)
      generate_phys_desc('instance', uri_instance)
      @graph << [uri_instance, BF.instanceOf, subject]
      lccn = get_lccn
      @graph << [uri_instance, BF.derivedFrom, RDF::URI.new("http://lccn.loc.gov/#{lccn}")] if lccn
      generate_holdings(uri_instance)
      generate_instance_from_isbn(uri_instance, isbns) if isbns.size > 0
    end

    def get_instance_types
      types = []
      cf007 = @record['007'] ? @record['007'].value[0] : nil
      types << INSTANCE_TYPES['cf007'][cf007]
      @record.fields('336').each do |field|
        types << INSTANCE_TYPES['336a'][field['a']]
        types << INSTANCE_TYPES['336b'][field['b']]
      end
      leader = @record.leader
      types << INSTANCE_TYPES['leader6'][leader[6]]
      types << INSTANCE_TYPES['leader8'][leader[8]]
      case leader[7]
      when 'a', 'm'
        if leader[19] == 'a'
          types << 'MultipartMonograph'
        else
          types << 'Monograph'
        end
      else
        types << INSTANCE_TYPES['leader7'][leader[7]]
      end
      types.uniq!.delete(nil)
      types
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
      targets = @record.tags.select{|t| t.start_with?('5')}.reject{|t| %w(500 502 504 505 506 507 508 511 513 518 520 522 524 525 541 546 555).include?(t)}
      if targets.size > 0
        @record.fields(targets) do |field|
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
              uri_category = get_uri('category')
              @graph << [subject, BF.mediaCategory, uri_category]
              @graph << [uri_category, RDF.type, BF.Category]
              @graph << [uri_category, BF.label, value]
              @graph << [uri_category, BF.categoryValue, value]
              @graph << [uri_category, BF.categoryType, "media category"]
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
                  uri_category = get_uri('category')
                  @graph << [subject, BF.carrierCategory, uri_category]
                  @graph << [uri_category, RDF.type, BF.Category]
                  @graph << [uri_category, BF.categoryType, value]
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
          if field.indicator1 == '0' && supplement.includes?('-')
            first, last = supplement.split('-')
            @graph << [suject, BF.serialFirstIssue, normalize_space(first)] if first
            @graph << [suject, BF.serialLastIssue, normalize_space(last)] if last
          else
            @graph << [suject, BF.serialFirstIssue, normalize_space(supplement)] if supplement
          end
        end
        @record.fields('351').each do |field|
          uri_arrange = get_uri('arrangement')
          @graph << [subject, BF.arrangement, uri_arrange]
          @graph << [uri_arrange, RDF.type, BF.Arrangement]
          generate_simple_property(field, 'arrangment', uri_arrange)
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
              uri_category = get_uri('category')
              @graph << [subject, BF.contentCategory, uri_category]
              @graph << [uri_category, RDF.type, BF.Category]
              @graph << [uri_category, BF.categoryValue, value]
              @graph << [uri_category, BF.categoryType, "content category"]
            end
          end
        end
        SIMPLE_PROPERTIES['contentcategory'].each do |h|
          @record.fields(h[:tag]).each do |field|
            field.values_of(h[:sfcodes]).each do |value|
              uri_category = get_uri('category')
              @graph << [subject, BF.contentCategory, uri_category]
              @graph << [uri_category, RDF.type, BF.Category]
              @graph << [uri_category, BF.categoryValue, value]
              @graph << [uri_category, BF.categoryType, "content category"]
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

    def generate_langs(subject)
      lang_008 = normalize_space(@record['008'].value[35, 3])
      lang_041 = []
      @record.fields('041').each do |field|
        lang_041 << field.values_of('a')
      end
      lang_041 = lang_041.flatten.uniq

      lang_041.each do |lang|
        @graph << [subject, BF.language, RDF::URI.new("http://id.loc.gov/vocabulary/languages/#{lang}")]
      end
      if lang_008 != '   ' && lang_008 != '|||' && (lang_041.length == 0 || lang_008 != lang_041[0])
        @graph << [subject, BF.language, RDF::URI.new("http://id.loc.gov/vocabulary/languages/#{lang_008}")]
      end

      @record.fields('041').each do |field|
        field.subfields.each do |sf|
          next unless %w(b d e f g h j k m n).include?(sf.code)
          uri_lang = get_uri('language')
          @graph << [subject, BF.language, uri_lang]
          @graph << [uri_lang, RDF.type, BF.Language]
          @graph << [uri_lang, BF.resourcePart, LANG_PART[sf.code]] if LANG_PART[sf.code]
          sf.value.strip.scan(/.{3}/).each do |code|
            @graph << [uri_lang, BF.languageOfPartUri, RDF::URI.new("http://id.loc.gov/vocabulary/languages/#{code}")]
          end
          @graph << [uri_lang, BF.languageSource, field['2']] if field['2']
        end
      end
    end

    def generate_names(field, subject)
      resource_role = get_resource_role(field)
      bf_class = get_bf_class(field)
      label = get_label(field)

      uri_name = get_uri(bf_class.to_s['http://bibframe.org/vocab/'.length..-1].downcase)
      @graph << [subject, resource_role, uri_name]
      @graph << [uri_name, RDF.type, bf_class]
      @graph << [uri_name, BF.label, label]
      unless field.tag == '534'
        @graph << [uri_name, BF.authorizedAccessPoint, label]
        auth_id = resolve ? getAuthorityID(bf_class.label, label) : nil
        if auth_id
          @graph << [uri_name, BF.hasAuthority, RDF::URI.new(auth_id)]
        else
          ## TODO これは必要か（mads vocabularyを使用）
          generate_element_list(label, uri_name)
        end
      end

      generate_880_label(field, "name", uri_name) if field['6']
      generate_bio_links(field, uri_name)
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

    def generate_element_list(label, resource)
      bn_authority = RDF::Node.uuid
      @graph << [resource, BF.hasAuthority, bn_authority]
      @graph << [bn_authority, RDF.type, RDF::MADS.Authority]
      @graph << [bn_authority, RDF::MADS.authoritativeLabel, label]
    end

    def generate_bio_links(field, resource)
      if %w(856 859).include?(field.tag)
        field.each do |sbfield|
          if sbfield.code == '3' && sbfield.value =~ /contributor/i
            generate_instance_from856(field, "person", resource)
          end
        end
      end
    end

    # @param [datafield] field
    # @param [String] workid: "person" or uri string
    # @param [RDF::Resource] resource: the subject of this objects
    def generate_instance_from856(field, workid, resource)
      category = if field.values_of('u').join('').include?('hdl.') && (field['3'] =~ /finding aid/i) == nil
        'instance'
      elsif field['3'] =~ /(pdf|page view)/i
        'instance'
      elsif field.indicator1 == '4' && field.indicator2 == '0'
        'instance'
      elsif field.indicator1 == '4' && field.indicator2 == '1' && field['3'] == nil
        'instance'
      elsif field['3'] =~ /finding aid/i
        'findaid'
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
        uri_instance = get_uri('instance')
        @graph << [resource, BF.hasInstance, uri_instance]
        @graph << [uri_instance, RDF.type, BF.Instance]
        @graph << [uri_instance, RDF.type, BF.Electronic]
        if field['3']
          @graph << [uri_instance, BF.label, normalize_space(field['3'])]
        else
          @graph << [uri_instance, BF.label, 'Electronic Resource']
        end
        field.each do |sbfield|
          next unless sbfield.code == 'u'
          if sbfield.value.include?('doi')
            @graph << [uri_instance, BF.doi, RDF::URI.new(sbfild.value)]
          elsif sbfield.value.include?('hdl')
            @graph << [uri_instance, BF.hdl, RDF::URI.new(sbfild.value)]
          else
            @graph << [uri_instance, BF.uri, RDF::URI.new(sbfild.value)]
          end
        end
        @graph << [uri_instance, BF.instanceOf, @work]
        if workid != 'person' && category == 'annotation'
          @graph << [uri_instance, BF.annotates, RDF::URI.new(workid)]
        end
      else
        uri_annotation = get_uri('annotation')
        @graph << [resource, BF.hasAnnotation, uri_annotation]
        bf_type =
          case type
          when 'table of contents'
            BF.TableOfContents
          when 'publisher summary'
            BF.Summary
          else
            BF.Annotation
          end
        @graph << [uri_annotation, RDF.type, bf_type]
        if field['3']
          @graph << [uri_annotation, BF.label, field['3']]
        elsif $type
          @graph << [uri_annotation, BF.label, $type]
        end
        field.each do |sbfield|
          code, value = sbfield.code, sbfield.value
          if code == 'u'
            bf_property =
              case type
              when 'table of contents'
                BF.TableOfContents
              when 'publisher summary'
                BF.review
              else
                BF.annotationBody
              end
            @graph << [uri_annotation, bf_property, RDF::URI.new(normalize_space(value))]
          elsif code == 'z'
            @graph << [uri_annotation, BF.copyNote, value]
          end
        end
        if workid != 'person' && category == 'annotation'
          @graph << [uri_annotation, BF.annotates, RDF::URI.new(workid)]
        end
      end
    end

    def generate_related_works(field, domain, subject)
      tag, ind2 = field.tag, field.indicator2
      case tag
      when /(730|740|772|780|785)/
        RELATIONSHIPS[domain].select{|h| h[:tag].include?(tag) && h[:ind2].include?(ind2)}.map{|h| h[:property]}.each do |property|
            generate_related_works_graph(field, property, subject)
          end
      when '533'
        RELATIONSHIPS[domain].select{|h| h[:tag].include?(tag)}.map{|h| h[:property]}.each do |property|
          generate_related_reporoduction(field, property, subject)
        end
      when /(700|710|711|720)/
        return unless field['t'] && ind2 == '2'
        RELATIONSHIPS[domain].select{|h| h[:tag].include?(tag) && h[:ind2].include?(ind2)}.map{|h| h[:property]}.each do |property|
          generate_related_works_graph(field, property, subject)
        end
      when /(490|630|830)/
        return unless field['a']
        RELATIONSHIPS[domain].select{|h| h[:tag].include?(tag)}.map{|h| h[:property]}.each do |property|
          generate_related_works_graph(f, property, subject)
        end
      when '534'
        return unless field['f']
        RELATIONSHIPS[domain].select{|h| h[:tag].include?(tag)}.map{|h| h[:property]}.each do |property|
          generate_related_works_graph(field, property, subject)
        end
      else
        return unless field['t'] || field['s']
        RELATIONSHIPS[domain].select{|h| h[:tag].include?(tag)}.map{|h| h[:property]}.each do |property|
          generate_related_works_graph(field, property, subject)
        end
      end
    end

    def generate_related_works_graph(field, property, subject)
      sfcodes = case field.tag
        when /(630|730|740)/ then %w(a n p)
        when /(440|490|830)/ then %w(a n p v)
        when '534' then %w(t b f)
        else %w(t f k m n o p s)
        end
      title = clean_title_string(field.subfields.select{|s| sfcodes.include?(s.code)}.map{|s| s.value}.join(' '))
      alabel = ''
      uri_work = get_uri('work')
      if field['a'] && field.tag = '740' and field.indicator2 == '2' &&
        @record.fields(%w(100 110 111)).size > 0
        heading = @reocrd.fields(%w(100 110 111))[0]
        generate_names(heading, uri_work)
        alabel = get_label(field)
      elsif !(%w(400 410 411 440 490 80 810 811 510 630 730 740 830).include?(field.tag)) && field['a']
        generate_names(field, uri_work)
        alabel = get_label(field) if alabel == ''
      end

      alabel = alabel + (alabel ? ' ' : '') + title
      alabel = normalize_space(alabel)
      label_880 = generate_880_label(field, 'title', subject, false)
      @graph << [subject, BF[property], uri_work]
      @graph << [uri_work, RDF.type, BF.Work]
      @graph << [uri_work, BF.label, title]
      @graph << [uri_work, BF.title, title]
      @graph << [uri_work, BF.authorizedAccessPoint, alabel]
      @graph << [uri_work, BF.authorizedAccessPoint, label_880] if label_880
      if field.tag != '630'
        field.subfields.each do |sf|
          next unless %w(w x).include?(sf.code)
          if sf.value.include?('(OCoLC)')
            @graph << [uri_work, BF.systemNumber, RDF::URI.new("http://id.loc.gov/authorities/test/identifiers/lccn/#{clean_id(sf.value)}")]
          elsif sf.code == 'x'
            uri_instance = get_uri('instance')
            @graph << [uri_work, BF.hasInstance, uri_instance]
            @graph << [uri_instance, RDF.type, BF.Instance]
            @graph << [uri_instance, BF.label, title]
            @graph << [uri_instance, BF.title, title]
            @graph << [uri_instance, BF.issn, RDF::URI.new("http://issn.example.org/#{clean_string(sf.value).gsub(/ /, '')}")]
          end
        end
      end
      generate_title_non_sort(field, title, BF.title, uri_work)

      if field.tag == '774'
        @graph << [uri_work, BF.partOf, subject]
      end
    end

    def generate_related_reporoduction(field, property, subject)
      title = @record['245']['a']
      carrier = if field['a'] then field['a']
        elsif field['3'] then field['3']
        else nil
        end
      places = field.subfields.select{|s| s.code=='b'}.map{|s| s.value}
      agents = field.subfields.select{|s| s.code=='c'}.map{|s| s.value}
      pdate  = field['d'] ? chop_puctuation(field['d']) : nil
      extent = field['e']
      coverage = field['m']
      notes  = field.subfields.select{|s| s.code=='n'}.map{|s| s.value}

      uri_work = get_uri('work')
      @graph << [subject, property, uri_work]
      @graph << [uri_work, RDF.type, BF.Work]
      @graph << [uri_work, BF.authorizedAccessPoint, title]
      @graph << [uri_work, BF.title, title]
      @graph << [uri_work, BF.label, title]
      if places.size > 0 || agents.size > 0 || notes.size > 0 || pdate || extent || coverage
        uri_instance = get_uri('instance')
        @graph << [uri_work, BF.hasInstance, uri_instance]
        @graph << [uri_instance, RDF.type, BF.Instance]
        bn_title = RDF::Node.uuid
        @graph << [uri_instance, BF.instanceTitle, bn_title]
        @graph << [bn_title, RDF.type, BF.Title]
        @graph << [bn_title, BF.label, title]
        if places.size > 0 || agents.size > 0 || pdate
          bn_provider = RDF::Node.uuid
          @graph << [uri_instance, BF.publication, bn_provider]
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
          @graph << [uri_instance, BF.extent, extent] if extent
          @graph << [uri_instance, BF.temporalCoverageNote, coverage] if coverage
          if carrier
            bn_catetory = RDF::Node.uuid
            @graph << [uri_instance, BF.carrierCategory, bn_catetory]
            @graph << [bn_catetory, RDF.type, BF.Category]
            @graph << [bn_catetory, BF.categoryValue, carrier]
          end
          notes.each do |note|
            @graph << [uri_instance, BF.note, note]
          end
        end
      end
    end

    def generate_subjects(field, subject)
      if SUBJECTS_TYPES[field.tag]
        generate_subject_graph(field, SUBJECTS_TYPES[field.tag], subject)
      end
    end

    # MADSボキャブラリを使った詳細情報は無視した
    def generate_subject_graph(field, type, subject)
      type = 'Work' if field.tag == '600' && field['t']
      label = get_subject_label(field)
      uri_subject = get_uri(type.downcase)
      @graph << [subject, BF.subject, uri_subject]
      @graph << [uri_subject, RDF.type, BF[type]]
      @graph << [uri_subject, BF.authorizedAccessPoint, label]
      auth_id = resolve ? getAuthorityID(BF[type].label, label) : nil
      @graph << [uri_subject, BF.hasAuthority, RDF::URI.new(auth_id)] if auth_id
      @graph << [uri_subject, BF.label, label]
      generate_880_label(field, 'subject', uri_subject)
      field.each do |sf|
        handle_system_number(subfield.value, uri_subject) if sf.code == '0'
      end
    end

    def get_subject_label(field)
      label = if %w(600 610 611 648 650 651 655 751).include?(field.tag)
        if %w(00 10 11 30).include?(field.tag[1, 2])
          cont1 = field.subfields.reject{|s| %w(w v x y z 6).include?(s.code)}.map{|s| s.value}.join(' ')
          cont2 = field.subfields.select{|s| %w(v x y z).include?(s.code)}.map{|s| s.value}.join('--')
          cont1 + (cont2=='' ? '' : '--' + cont2)
        else
          field.subfields.reject{|s| %w(w 6).include?(s.code)}.map{|s| s.value}.join('--').sub(/\.$/, '')
        end
      elsif %w(662 752).include?(field.tag)
        field.subfields.reject{|s| %w(a b c d f g h).include?(s.code)}.map{|s| s.value}.join('. ')
      else
        field.subfields.reject{|s| s.code == '6'}.map{|s| s.value}.join(' ')
      end
      normalize_space(label)
    end

    # generate_title: title関連トリプルの作成
    #
    # params [MARC::Datafield] field 作成対象のフィールド
    # params [RDF::Resource] subject このトリプルのサブジェクト
    def generate_title(field, domain, subject)
      title = get_title(field)
      element_name = get_element_name(field, domain)
      xml_lang = (field.tag == '242' && field['y']) ? field['f'] : nil
      title_literal = xml_lang ? RDF::Literal.new(title, :language => xml_lang.to_sym) : title
      title_type = get_title_type(field)

      uri_title = get_uri('title')
      @graph << [subject, BF.title, title_literal]
      @graph << [subject, element_name, uri_title]
      @graph << [uri_title, RDF.type, BF.Title]
      if title_type
        @graph << [uri_title, BF.titleType, title_type]
      else
        generate_simple_property(field, 'title', uri_title)
        generate_880_label(field, 'title', uri_title)
      end
      generate_title_non_sort(field, title, element_name, uri_title)
      field.subfields.each do |s|
        handle_system_number(s.value, uri_title) if s.code == '0'
      end
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

    def generate_uniform_title(subject)
      require 'iso-639'

      field = @record['130'] ? @record['130'] : @record['240'] ? @record['240'] : nil
      return unless field

      label = field.subfields.reject{|s| %w(0 6 8).include?(s.code)}.map{|s| s.value}.join(' ')
      @graph << [subject, BF.label, label]
      @graph << [subject, RDF::MADS.authoritativeLabel, label]
      generate_title_non_sort(field, label, BF.title, subject)

      uri_title = get_uri('title')
      @graph << [subject, BF.workTitle, uri_title]
      generate_simple_property(field, 'title', uri_title)

      if field['0']
        field.each do |sbfield|
          next unless sbfield.code == '0'
          bn_id = RDF::Node.uuid
          @graph << [subject, BF.identifier, bn_id]
          @graph << [bn_id, RDF.type, BF.Identifier]
          @graph << [bn_id, BF.identifierValue, sbfield.value]
          @graph << [bn_id, BF.identifierScheme, 'local']
        end
      end

      field.each do |sbfield|
        bn_authority = RDF::Node.uuid
        bn_list = RDF::Node.uuid
        bn_element = RDF::Node.uuid
        @graph << [subject, BF.hasAuthority, bn_authority]
        @graph << [bn_authority, RDF.type, RDF::MADS.Authority]
        @graph << [bn_authority, RDF::MADS.authoritativeLabel, label]
        @graph << [bn_authority, RDF::MADS.elementList, bn_list]
        @graph << [bn_list, RDF.first, bn_element]
        @graph << [bn_list, RDF.rest, RDF.nil]
        value = clean_title_string(sbfield.value)
        case sbfield.code
        when 'a'
          @graph << [bn_element, RDF.type, RDF::MADS.MainTitleElement]
          @graph << [bn_element, RDF::MADS.elementValue, value]
        when 'p'
          @graph << [bn_element, RDF.type, RDF::MADS.PartNameElement]
          @graph << [bn_element, RDF::MADS.elementValue, value]
        when 'l'
          @graph << [bn_element, RDF.type, RDF::MADS.LanguageElement]
          @graph << [bn_element, RDF::MADS.elementValue, value]
        when 's'
          @graph << [bn_element, RDF.type, RDF::MADS.TitleElement]
          @graph << [bn_element, RDF::MADS.elementValue, value]
        when 'k',
          @graph << [bn_element, RDF.type, RDF::MADS.GenreFormElement]
          @graph << [bn_element, RDF::MADS.elementValue, value]
        when 'd', 'f'
          @graph << [bn_element, RDF.type, RDF::MADS.TemporalElement]
          @graph << [bn_element, RDF::MADS.elementValue, value]
        else
          @graph << [bn_element, RDF.type, RDF::MADS.TitleElement]
          @graph << [bn_element, RDF::MADS.elementValue, value]
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
        uri_trans = get_uri('work')
        @graph << [subject, BF.translationOf, uri_trans]
        @graph << [uri_trans, RDF.type, BF.Work]
        @graph << [uri_trans, BF.title, tlabel]
        title_non_sort = get_title_non_sort(field, tlabel)
        @graph << [uri_trans, BF.title, title_non_sort] if title_non_sort
        @graph << [uri_trans, BF.authoritativeLabel, tlabel]
        if @record['100']
          uri_agent = get_uri('agent')
          @graph << [uri_trans, BF.creator, uri_agent]
          @graph << [uri_agent, RDF.type, BF.Agent]
          @graph << [uri_agent, BF.label, @record['100']['a']]
        end
      end
    end



    def generate_work_type(subject)
      get_types.each do |type|
        @graph << [subject, RDF.type, BF[type]]
      end
    end

    # hese properties are transformed as either literals or appended to the @uri parameter inside their @domain
    #
    #  generate_simple_property: generate triples for properties which are are transformed as either literals or appended to the @uri parameter inside their @domain
    #  @param [MARC#datafield] field
    #  @param [String] domain
    #  @param [RDF::Resource] subject
    #
    def generate_simple_property(field, domain, subject)
      return if MARC::ControlField.control_tag?(field.tag)
      return unless SIMPLE_PROPERTIES[domain]
      tag, ind1, ind2 = field.tag, field.indicator1, field.indicator2
      SIMPLE_PROPERTIES[domain].each do |node|
        next unless node[:tag] == tag
        next unless node[:ind1] == nil || node[:ind1] == ind1
        next unless node[:ind2] == nil || node[:ind2] == ind2

        startwith = node[:startwith] ? node[:startwith] : ''
        sfcodes = node[:sfcodes] ? node[:sfcodes].split('').delete_if{|x| x==','} : []
        values = []
        if sfcodes.length > 1
          stringjoin = node[:stringjoin] ? node[:stringjoin] : ' '
          value = field.subfields.select{|sf| sfcodes.include?(sf.code) }.map{|sf| sf.value}.join(stringjoin)
          values << startwith + value if value != ''
        else
          field.each do |sbfield|
            # {domain: "instance", property: "$2", tag: "024", sfcodes: "a", ind1: "7", group: "identifiers", label: "contents of $2"}
            if node[:property]=='$2' && sbfield.code == '2'
              node[:property] = sbfield.value
              node[:label] = node[:label].sub(/\$2/, sbfield.value)
              next
            end
            next unless sbfield.code == sfcodes[0]
            values << startwith + sbfield.value
          end
        end

        if node[:group] == 'identifiers'
          values.each do |value|
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
          end
        elsif node[:uri] == nil
          values.each do |value|
            @graph << [subject, BF[node[:property]], value]
          end
        elsif node[:uri].include?('loc.gov/vocabulary/organizations')
          values.each do |value|
            if value.length < 10 && !value.include?(' ')
              @graph << [subject, BF[node[:property]], RDF::URI.new(node[:uri]+value.gsub(/-/, ''))]
            else
              @num += 1
              nd_organization = RDF::Node.uuid
              @graph << [subject, BF[node[:property]], nd_organization]
              @graph << [nd_organization, BF.label, value]
            end
          end
        elsif node[:property] == 'lccn'
          values.each do |value|
            @graph << [subject, BF[node[:property]], RDF::URI.new(node[:uri]+value.gsub(/ /, ''))]
          end
        else
          values.each do |value|
            @graph << [subject, BF[node[:property]], RDF::URI.new(node[:uri]+value)]
          end
        end
      end
    end



    def generate_880_label(field, node_name, resource, set_graph=true)
      return unless field['6'] && field['6'].start_with?('880')

      target = field.tag + '-' + field['6'].split('-')[1][0, 2]
      lang = @record['008'].value[35, 3]
      target_field = @record.fields('880').find {|f| f['6'].start_with?(target)}
      scr = target_field['6'].split('/')[1]
      xml_lang = get_xml_lang(scr, lang)
      case node_name
      when 'name'
        value = if field.tag == '534'
          target_field['a']
        else
          target_field.subfields.select{|f| %w(a b c d q).include?(f.code)}.map{|f| f.value}.join(' ')
        end
        @graph << [resource, BF.authorizedAccessPoint, RDF::Literal.new(clean_string(value), :language => xml_lang.to_sym)]
      when 'title'
        subfs = if %w(245 242 243 246 490 510 630 730 740 830).include?(field.tag)
          %w(a b f h k n p)
        else
          %w(t f k m n p s)
        end
        value = target_field.subfields.select{|f| subfs.include?(f.code)}.map{|f| f.value}.join(' ')
        if set_graph
          @graph << [resource, BF.titleValue, RDF::Literal.new(clean_title_string(value), :language => xml_lang.to_sym)]
        else
          return RDF::Literal.new(clean_title_string(value), :language => xml_lang.to_sym)
        end
      when 'subject'
        value = target_field.subfields.reject{|f| f.code == '6'}..map{|f| f.value}.join(' ')
        @graph << [resource, BF.authorizedAccessPoint, RDF::Literal.new(clean_title_string(value), :language => xml_lang.to_sym)]
      when 'place'
        target_field.each do |sbfield|
          next unless sbfield.code == 'a'
          value = clean_string(sbfield.value)
          uri_place = get_uri('place')
          @graph << [resource, BF.providerPlace, uri_place]
          @graph << [uri_place, RDF.type, BF.Place]
          if value =~ /[a-zA-Z]/
            @graph << [uri_place, BF.label, value]
          else
            @graph << [uri_place, BF.label, RDF::Literal.new(value, :language => xml_lang.to_sym)]

          end
        end
      when 'provider'
        target_field.each do |sbfield|
          next unless sbfield.code == 'b'
          value = clean_string(sbfield.value)
          uri_provider = get_uri('organization')
          @graph << [resource, BF.providerName, uri_provider]
          @graph << [uri_provider, RDF.type, BF.Organization]
          @graph << [uri_provider, BF.label, RDF::Literal.new(value, :language => xml_lang.to_sym)]
        end
      else
        @graph << [resource, BF[node_name], target_field['a']]
      end
    end

    def get_xml_lang(scr, lang)
      entry = ISO_639.find(lang)
      xml_lang = entry.alpha2 ? entry.alpha2 : entry.alpha3
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
      field.each do |sbfield|
        next unless sbfield.code == 'u'
        property = case sbfield.value
          when /doi/ then BF.doi
          when /hdl/ then BF.hdl
          else BF.uri
          end
        @graph << [subject, property, RDF::URI.new(sbfield.value)]
      end
    end

    def generate_property_from_text(tag, sfcode, text, domain, subject)
      SIMPLE_PROPERTIES[domain].each do |h|
        next unless h[:tag] == tag && (h[:sfcodes].include?(sfcode) || h[:sfcodes] == '')
        #rcode = h[:sfcodes] != '' ? h[:sfcodes] : 'a'
        startwith = h[:startwith] ? h[:startwith] : ''
        object =
          if h[:uri] == nil
            startwith + text
          elsif h[:uri].include?('loc.gov/vocabulary/organizations')
            text = normalize_space(text).downcase.gsub(/-/, '')
            RDF::URI.new(h[:uri]+text)
          elsif h[:property].include?('lccn')
            RDF::URI.new(h[:uri]+text.gsub(/ /, ''))
          else
            RDF::URI.new(h[:uri]+text)
          end
        @graph << [subject, BF[h[:property]], object]
      end
    end

  end   # BFRDF

end # Bibframe