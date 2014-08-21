require 'spec_helper'
require 'marc'
require 'rdf'
include RDF

describe Bibframe do
  it 'バージョン番号を持っていること' do
    expect(Bibframe::VERSION).not_to be nil
  end
end

describe Bibframe::BFRDF do
  before {
    @record = MARC::Record.new()
    @record.leader = '00000nam a5212345zi 4500'
    @record.append(MARC::ControlField.new('001', '12345678'))
    @bf = Bibframe::BFRDF.new(@record, resolve: true, source: 'ndl')
    @work = RDF::URI.new(@bf.baseuri)
  }

  context '初期化した場合' do
    it 'idが設定されること' do
      expect(@bf.baseuri).to eq('http://id.ndl.go.jp/bib/12345678')
    end
  end

  context 'generate_typesメソッドを実行した場合' do

    it '初期化した段階でトリプルが1つ作成されること' do
      @bf.generate_types(@work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'Tag007追加でもトリプルが1つであること' do
      @record.append(MARC::ControlField.new('007', 'ta'))
      @bf.generate_types(@work)
      expect(@bf.graph.count).to eq(1)
    end


    it 'Tag336a追加でトリプルが2つ作成されること' do
      @record.append(MARC::DataField.new('336', ' ', ' ', ['a', 'notated movement']))
      @bf.generate_types(@work)
      expect(@bf.graph.count).to eq(2)
    end
  end

  context 'generate_accesspointsメソッドを実行した場合' do

    it 'Tag130追加でトリプルが1つ作成されること' do
      @record.append(MARC::DataField.new('130', ' ', ' ', ['a', '統一書名']))
      @bf.generate_accesspoints(@work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'Tag245追加でトリプルが1つ作成されること' do
      @record.append(MARC::DataField.new('245', ' ', ' ', ['a', '本書名 :'], ['b', '副書名 /'], ['c', '山田太郎 [著]']))
      @bf.generate_accesspoints(@work)
      expect(@bf.graph.count).to eq(1)
    end
  end

  context 'generate_uniform_titleメソッドを実行した場合' do

    it 'Tag130aもTag240aもないとトリプルが作成されないこと' do
      @bf.generate_uniform_title(@work)
      expect(@bf.graph.count).to eq(0)
    end

    it 'Tag130aがあるとトリプルが4つ作成されること' do
      @record.append(MARC::DataField.new('130', ' ', ' ', ['a', '統一書名130']))
      @bf.generate_uniform_title(@work)
      expect(@bf.graph.count).to eq(4)
    end

    it 'Tag240aがあるとトリプルが4つ作成されること' do
      @record.append(MARC::DataField.new('240', ' ', ' ', ['a', '統一書名240']))
      @bf.generate_uniform_title(@work)
      expect(@bf.graph.count).to eq(4)
    end

    it 'Tag130aとTag240aの両者があっても作成されるトリプルは4つであること' do
      @record.append(MARC::DataField.new('240', ' ', ' ', ['a', '統一書名240']))
      @record.append(MARC::DataField.new('130', ' ', ' ', ['a', '統一書名130']))
      @bf.generate_uniform_title(@work)
      expect(@bf.graph.count).to eq(4)
    end

    it 'Tag130aとTag240aにサブフィールド"0"があるとトリプルが8つ作成されること' do
      @record.append(MARC::DataField.new('130', ' ', ' ', ['a', '統一書名130'], ['0', 'id']))
      @bf.generate_uniform_title(@work)
      expect(@bf.graph.count).to eq(8)
    end

    it 'Tag130aとTag240aにサブフィールド"l"があるとトリプルが10個作成されること' do
      @record.append(MARC::DataField.new('130', ' ', ' ', ['a', '統一書名130'], ['l', 'Japanese']))
      @bf.generate_uniform_title(@work)
      expect(@bf.graph.count).to eq(10)
    end
  end

  context 'generate_langsメソッドを実行した場合' do

    it 'Tag008[35-37]に言語コードがあるとトリプルが1つ作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| ||||||jpn  '))
      @bf.generate_langs(@work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'Tag041aがあるとトリプルが1つ作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| |||||||||  '))
      @record.append(MARC::DataField.new('041', ' ', ' ', ['a', 'jpn']))
      @bf.generate_langs(@work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'Tag041aが2つあるとトリプルが2つ作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| |||||||||  '))
      @record.append(MARC::DataField.new('041', ' ', ' ', ['a', 'jpn'], ['a', 'eng']))
      @bf.generate_langs(@work)
      expect(@bf.graph.count).to eq(2)
    end

    it 'Tag041bがあるとトリプルが4つ作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| |||||||||  '))
      @record.append(MARC::DataField.new('041', ' ', ' ', ['b', 'eng']))
      @bf.generate_langs(@work)
      expect(@bf.graph.count).to eq(4)
    end

    it 'Tag0412があるとトリプルが1つ作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| |||||||||  '))
      @record.append(MARC::DataField.new('041', ' ', ' ', ['2', 'iso639-1']))
      @bf.generate_langs(@work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'Tag008[35-37]とTag041aの値が異なるとトリプルが2つ作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| ||||||jpn  '))
      @record.append(MARC::DataField.new('041', ' ', ' ', ['a', 'eng']))
      @bf.generate_langs(@work)
      expect(@bf.graph.count).to eq(2)
    end

  end

  context 'generate_identifiersメソッドを実行した場合' do

    it 'Tag022lがないとトリプルが作成されないこと' do
      @bf.generate_identifiers('work', @work)
      expect(@bf.graph.count).to eq(0)
    end

    it 'Tag022lがあるとトリプルが4つ作成されること' do
      @record.append(MARC::DataField.new('022', ' ', ' ', ['l', '1234-5678']))
      @bf.generate_identifiers('work', @work)
      expect(@bf.graph.count).to eq(4)
    end

  end

  context 'tag502がある場合' do

    it 'サブフィールドaがあるとgenerate_simple_propertyが実行されてトリプルが1つ作成されること' do
      field = MARC::DataField.new('502', ' ', ' ', ['a', 'Thesis (M.A.)--University College, London, 1969.'])
      @bf.generate_simple_property(field, 'work', @work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'サブフィールドcがあるとgenerate_dissertationsが実行されてトリプルが3つ作成されること' do
      field = MARC::DataField.new('502', ' ', ' ', ['c', 'International Faith Theological Seminary, London'])
      @bf.generate_dissertations(field, @work)
      expect(@bf.graph.count).to eq(3)
    end

    it 'サブフィールドoがあるとgenerate_dissertationsが実行されてトリプルが3つ作成されること' do
      field = MARC::DataField.new('502', ' ', ' ', ['o', 'U 58.4033'])
      @bf.generate_dissertations(field, @work)
      expect(@bf.graph.count).to eq(3)
    end

  end

  context 'tag(100|110|111|700|710|711|720)がある場合' do

    it 'サブフィールドaがあるとgenerate_namesが実行されてトリプルが7つ作成されること' do
      field = MARC::DataField.new('100', '1', ' ', ['a', '山田, 太郎'])
      @bf.generate_names(field, @work)
      expect(@bf.graph.count).to eq(7)
    end

    it 'サブフィールド[a, 0]があるとgenerate_namesが実行されてトリプルが5つ作成されること' do
      field = MARC::DataField.new('100', '1', ' ', ['a', '山田, 太郎'], ['0', '123456789'])
      @bf.generate_names(field, @work)
      expect(@bf.graph.count).to eq(5)
    end

    it 'サブフィールド[a, 0, 6]と対応するTag880があるとgenerate_namesが実行されてトリプルが6つ作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| ||||||jpn  '))
      @record.append(MARC::DataField.new('880', '1', ' ', ['6', '100-01/$1'], ['a', 'ヤマダ, タロウ'], ['0', '123456789']))
      field = MARC::DataField.new('100', '1', ' ', ['a', '山田, 太郎'], ['0', '123456789'], ['6', '880-01'])
      @bf.generate_names(field, @work)
      expect(@bf.graph.count).to eq(6)
    end

  end

  context 'tag(243|245|247)がある場合' do

    it 'ind2=0でサブフィールド[a, b]があるとgenerate_titleが実行されてトリプルが5つ作成されること' do
      field = MARC::DataField.new('245', '0', '0', ['a', '書名 :'], ['b', '副書名 /'], ['c', '山田, 太郎 [著]'])
      @bf.generate_title(field, 'work', @work)
      expect(@bf.graph.count).to eq(5)
    end

    it 'ind2>0でサブフィールド[a, b]があるとgenerate_titleが実行されてトリプルが6つ作成されること' do
      field = MARC::DataField.new('245', '0', '4', ['a', 'The Title :'], ['b', 'sub title /'], ['c', 'by Yamada Taro'])
      @bf.generate_title(field, 'work', @work)
      expect(@bf.graph.count).to eq(6)
    end

    it 'サブフィールド[a, b, 6]と対応するTag880があるとgenerate_titleが実行されてトリプルが6つ作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| ||||||jpn  '))
      @record.append(MARC::DataField.new('880', '0', '0', ['6', '245-01/$1'], ['a', 'ショメイ :'], ['b', 'フクショメイ /']))
      field = MARC::DataField.new('245', '0', '0', ['a', '書名 :'], ['b', '副書名 /'], ['c', '山田, 太郎 [著]'], ['6', '880-01'])
      @bf.generate_title(field, 'work', @work)
      expect(@bf.graph.count).to eq(6)
    end

=begin
    it 'source!="ndl"でサブフィールド[a, b, 0]があるとトリプルが8つ作成されること' do
      field = MARC::DataField.new('245', '0', '4', ['a', 'The Title :'], ['b', 'sub title /'], ['0', '987654321'])
      @bf.generate_title(field, 'work', @work)
      expect(@bf.graph.count).to eq(8)
    end
=end

  end

  context 'tag033がある場合' do

    it 'サブフィールド[a]があるとgenerate_eventsが実行されてトリプルが3つ作成されること' do
      field = MARC::DataField.new('033', '0', '0', ['a', '2014'])
      @bf.generate_events(field, @work)
      expect(@bf.graph.count).to eq(3)
    end

    it 'サブフィールド[a, b]があるとgenerate_eventsが実行されてトリプルが4つ作成されること' do
      field = MARC::DataField.new('033', '0', '0', ['a', '2014'], ['b', '3824'], ['c', 'P5'])
      @bf.generate_events(field, @work)
      expect(@bf.graph.count).to eq(4)
    end

    it 'サブフィールド[a, b, p]があるとgenerate_eventsが実行されてトリプルが7つ作成されること' do
      field = MARC::DataField.new('033', '0', '0', ['a', '2014'], ['b', '3824'], ['c', 'P5'], ['p', 'Tokyo'])
      @bf.generate_events(field, @work)
      expect(@bf.graph.count).to eq(7)
    end

    it 'サブフィールド[a, b, p, 0]があるとgenerate_eventsが実行されてトリプルが8つ作成されること' do
      field = MARC::DataField.new('033', '0', '0', ['a', '2014'], ['b', '3824'], ['c', 'P5'], ['p', 'Tokyo'], ['0', '123456'])
      @bf.generate_events(field, @work)
      expect(@bf.graph.count).to eq(8)
    end

  end

  context 'tag521がある場合' do

    it 'サブフィールド[a]があるとgenerate_audience_521が実行されてトリプルが3つ作成されること' do
      field = MARC::DataField.new('521', ' ', ' ', ['a', 'Clinical students, postgraduate house officers.'])
      @bf.generate_audience_521(field, @work)
      expect(@bf.graph.count).to eq(3)
    end

    it 'サブフィールド[a, b]があるとgenerate_audience_521が実行されてトリプルが4つ作成されること' do
      field = MARC::DataField.new('521', '3', ' ', ['a', 'Visually impaired'], ['b', 'LENOCA.'])
      @bf.generate_audience_521(field, @work)
      expect(@bf.graph.count).to eq(4)
    end

  end

  context 'tag555がある場合' do

    it 'サブフィールド[a|b|c|3]があるとgenerate_findaidsが実行されてトリプルが1つ作成されること' do
      field = MARC::DataField.new('555', '0', ' ', ['a', 'Preliminary inventory prepared in 1962;'], ['b', 'Available in NARS central search room;'], ['b', 'NARS Publications Sales Branch;'], ['3', 'Claims settled under Treaty of Washington, May 8, 1871'])
      @bf.generate_findaids(field, @work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'サブフィールド[a, u]があるとgenerate_findaidsが実行されてトリプルが7つ作成されること' do
      field = MARC::DataField.new('555', '8', ' ', ['a', 'Finding aid available in the Manuscript Reading Room and on Internet.'], ['u', 'http://hdl.loc.gov/loc.mss/eadmss.ms996001'])
      @bf.generate_findaids(field, @work)
      expect(@bf.graph.count).to eq(7)
    end


  end

  context 'tag520がある場合' do

    it 'サブフィールド[c|u]がないとgenerate_abstractが実行されてもトリプルは作成されないこと' do
      field = MARC::DataField.new('520', ' ', ' ', ['a', 'Describes associations made between different animal species for temporary gain or convenience as well as more permanent alliances formed for mutual survival.'])
      @bf.generate_abstract(field, @work)
      expect(@bf.graph.count).to eq(0)
    end

    it 'サブフィールド[c]があるとgenerate_abstractが実行されてトリプルが5つ作成されること' do
      field = MARC::DataField.new('520', '4', ' ', ['a', 'Contains swear words, sex scenes and violence'], ['b', 'NARS Publications Sales Branch;'], ['c', '[Revealweb organization code]'])
      @bf.generate_abstract(field, @work)
      expect(@bf.graph.count).to eq(5)
    end

    it 'サブフィールド[c, u]があるとgenerate_abstractが実行されてトリプルが6つ作成されること' do
      field = MARC::DataField.new('520', '4', ' ', ['a', '"Happy Feet" may be too much for many kids younger than 7 and some younger than 8. (Know how well your child separates animated fantasy from reality.)'], ['b', 'NARS Publications Sales Branch;'], ['c', 'Family Filmgoer.'], ['u', 'http://www.washingtonpost.com/wp-dyn/content/article/2006/11/16/AR2006111600269.html'])
      @bf.generate_abstract(field, @work)
      expect(@bf.graph.count).to eq(6)
    end

  end

  context 'tag008がある場合' do

    it 'Tag008[22]が空白でなく、資料コードが(BK|CF|MU|VM)であるとgenerate_audienceが実行されてトリプルが1つ作成されること' do
      field = MARC::ControlField.new('008', '140325s2014    ja ||||g |||| ||||||jpn  ')
      @bf.generate_audience(field, @work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'Tag008[23]が空白でなく、リソースタイプが(Text|Book|NotatedMusic|MusicRecording|MixedMaterial)であるとgenerate_genreが実行されてトリプルが1つ作成されること' do
      field = MARC::ControlField.new('008', '140325s2014    ja ||||ga|||| ||||||jpn  ')
      @bf.generate_genre(field, 'Book', @work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'Tag008[23]が空白でなく、リソースタイプが"Work"であるとgenerate_genreが実行されてトリプルが作成されないこと' do
      field = MARC::ControlField.new('008', '140325s2014    ja ||||ga|||| ||||||jpn  ')
      @bf.generate_genre(field, 'Work', @work)
      expect(@bf.graph.count).to eq(0)
    end

  end

  context 'tag255がある場合' do

    it 'サブフィールド[a|b|c|d|e|f|g]が1つあるとgenerate_cartographyが実行されてトリプルが1つ作成されること' do
      field = MARC::DataField.new('255', ' ', ' ', ['a', 'Scale 1:7,500,000'])
      @bf.generate_cartography(field, @work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'サブフィールド[a|b|c|d|e|f|g]が2つあるとgenerate_cartographyが実行されてトリプルが2つ作成されること' do
      field = MARC::DataField.new('255', ' ', ' ', ['a', 'Scale 1:7,500,000'], ['c', '(W 125°--W 65°/N 49°--N 25°).'])
      @bf.generate_cartography(field, @work)
      expect(@bf.graph.count).to eq(2)
    end

  end

  context 'tag(600|610|611|648|650|651|654|655|656|657|658|662|653|751|752)がある場合' do

    it 'サブフィールド[a]があるとgenerate_subjectsが実行されてトリプルが4つ作成されること' do
      field = MARC::DataField.new('650', ' ', '7', ['a', 'オブジェクト指向プログラミング'], ['2', 'ndlsh'])
      @bf.generate_subjects(field, @work)
      expect(@bf.graph.count).to eq(4)
    end

    it 'さらにサブフィールド[0]があり、@resolve=trueであるとgenerate_subjectsが実行されてトリプルが5つ作成されること' do
      field = MARC::DataField.new('650', ' ', '7', ['a', 'オブジェクト指向プログラミング'], ['2', 'ndlsh'], ['0', '00937980'])
      @bf.generate_subjects(field, @work)
      expect(@bf.graph.count).to eq(5)
    end

    it 'さらにサブフィールド[6]があり、対応するTag880があるとgenerate_subjectsが実行されてトリプルが6つ作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| ||||||jpn  '))
      @record.append(MARC::DataField.new('880', ' ', '7', ['6', '650-01/$1'], ['a', 'オブジェクトシコウプログラミング'], ['0', '00937980']))
      field = MARC::DataField.new('650', ' ', '7', ['a', 'オブジェクト指向プログラミング'], ['2', 'ndlsh'], ['0', '00937980'], ['6', '880-01'])
      @bf.generate_subjects(field, @work)
      expect(@bf.graph.count).to eq(6)
    end

  end

  context 'tag043がある場合' do

    it 'サブフィールド[a]があるとgenerate_gacsが実行されてトリプルが1つ作成されること' do
      field = MARC::DataField.new('043', ' ', ' ', ['a', 'n-us---'])
      @bf.generate_gacs(field, @work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'サブフィールド[a]が2つあるとgenerate_gacsが実行されてトリプルが2つ作成されること' do
      field = MARC::DataField.new('043', ' ', ' ', ['a', 'n-us---'], ['a', 'a-ja---'])
      @bf.generate_gacs(field, @work)
      expect(@bf.graph.count).to eq(2)
    end

  end

  context 'tag(050|055|060|061|070|080|082|083|084|086)がある場合' do

    it 'Tag050にサブフィールド[a]があり、正しいLCCコードを値として持つとgenerate_classesが実行されてトリプルが1つ作成されること' do
      field = MARC::DataField.new('050', '0', '0', ['a', 'QC861.2'], ['b', '.B36'])
      @bf.generate_classes(field, 'work', @work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'Tag050にサブフィールド[a]があり、不正なLCCコードを値として持つとgenerate_classesが実行されてもトリプルが作成されないこと' do
      field = MARC::DataField.new('050', '0', '0', ['a', 'ABC861.2'], ['b', '.B36'])
      @bf.generate_classes(field, 'work', @work)
      expect(@bf.graph.count).to eq(0)
    end

    it 'Tag060にサブフィールド[a]があるとgenerate_classesが実行されてトリプルが1つ作成されること' do
      field = MARC::DataField.new('060', '0', '0', ['a', 'W 22 DC2.1'], ['b', 'B8M'])
      @bf.generate_classes(field, 'work', @work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'Tag070にサブフィールド[a]があるとgenerate_classesが実行されてトリプルが4つ作成されること' do
      field = MARC::DataField.new('070', '0', ' ', ['a', 'HD3492.H8'], ['b', 'L3'])
      @bf.generate_classes(field, 'work', @work)
      expect(@bf.graph.count).to eq(4)
    end

    it 'Tag082にサブフィールド[a]だけがあるとgenerate_classesが実行されてトリプルが1つ作成されること' do
      field = MARC::DataField.new('082', '0', '0', ['a', '975.5/4252/00222'])
      @bf.generate_classes(field, 'work', @work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'Tag082にサブフィールド[a, 2]があるとgenerate_classesが実行されてトリプルが6つ作成されること' do
      field = MARC::DataField.new('082', '0', '0', ['a', '975.5/4252/00222'], ['2', '22'])
      @bf.generate_classes(field, 'work', @work)
      expect(@bf.graph.count).to eq(6)
    end

    it 'Tag082にサブフィールド[a, m, 2]があるとgenerate_classesが実行されてトリプルが7つ作成されること' do
      field = MARC::DataField.new('082', '0', '0', ['a', '975.5/4252/00222'], ['2', '22'], ['m', 'a'])
      @bf.generate_classes(field, 'work', @work)
      expect(@bf.graph.count).to eq(7)
    end

    it 'Tag082にサブフィールド[a, q, 2]があるとgenerate_classesが実行されてトリプルが7つ作成されること' do
      field = MARC::DataField.new('082', '0', '4', ['a', '004'], ['2', '22/ger'], ['q', 'DE-101b'])
      @bf.generate_classes(field, 'work', @work)
      expect(@bf.graph.count).to eq(7)
    end

    it 'Tag083にサブフィールド[a, z, 2]があるとgenerate_classesが実行されてトリプルが7つ作成されること' do
      field = MARC::DataField.new('083', '0', ' ', ['a', '94'], ['2', '22'], ['z', '2'])
      @bf.generate_classes(field, 'work', @work)
      expect(@bf.graph.count).to eq(7)
    end

    it 'Tag084にサブフィールド[a, 2]があるとgenerate_classesが実行されてトリプルが5つ作成されること' do
      field = MARC::DataField.new('084', ' ', ' ', ['a', 'M159'], ['2', 'kktb'])
      @bf.generate_classes(field, 'work', @work)
      expect(@bf.graph.count).to eq(5)
    end

    it 'Tag086にサブフィールド[a]があるとgenerate_classesが実行されてトリプルが4つ作成されること' do
      field = MARC::DataField.new('086', '0', ' ', ['a', 'HE 20.6209:13/45'])
      @bf.generate_classes(field, 'work', @work)
      expect(@bf.graph.count).to eq(4)
    end

    it 'Tag086にサブフィールド[a, z]があるとgenerate_classesが実行されてトリプルが9つ作成されること' do
      field = MARC::DataField.new('086', '0', ' ', ['a', 'A 1.1:'], ['z', 'A 1.1/3:984'])
      @bf.generate_classes(field, 'work', @work)
      expect(@bf.graph.count).to eq(9)
    end

  end

  context 'tag505がある場合' do

    it 'Tag505のind2が0でないとgenerate_complex_notesが実行されてもトリプルが作成されないこと' do
      field = MARC::DataField.new('505', '0', ' ', ['a', 'pt. 1. Carbon -- pt. 2. Nitrogen -- pt.3. Sulphur -- p. 4. Metals.'])
      @bf.generate_complex_notes(field, @work)
      expect(@bf.graph.count).to eq(0)
    end

    it 'Tag505のind2=0でサブフィールド[t, g]が1つずつあるとgenerate_complex_notesが実行されてトリプルが4つ作成されること' do
      field = MARC::DataField.new('505', '0', '0', ['t', 'Quatrain II'], ['g', '(16:35) --'])
      @bf.generate_complex_notes(field, @work)
      expect(@bf.graph.count).to eq(4)
    end

    it 'Tag505のind2=0でサブフィールド[t, g]が2つずつあるとgenerate_complex_notesが実行されてトリプルが8つ作成されること' do
      field = MARC::DataField.new('505', '0', '0', ['t', 'Quatrain II'], ['g', '(16:35) --'], ['t', 'Water ways'], ['g', '(1:57) --'])
      @bf.generate_complex_notes(field, @work)
      expect(@bf.graph.count).to eq(8)
    end

    it 'Tag505のind2=0でサブフィールド[t, r]が1つずつあるとgenerate_complex_notesが実行されてトリプルが6つ作成されること' do
      field = MARC::DataField.new('505', '0', '0', ['t', 'Quark models /'], ['r', 'J. Rosner --'])
      @bf.generate_complex_notes(field, @work)
      expect(@bf.graph.count).to eq(6)
    end

    it 'Tag505のind2=0でサブフィールド[t, r]が2つずつあるとgenerate_complex_notesが実行されてトリプルが12つ作成されること' do
      field = MARC::DataField.new('505', '0', '0', ['t', 'Quark models /'], ['r', 'J. Rosner --'], ['t', 'Introduction to gauge theories of the strong, weak, and electromagnetic interactions /'], ['r', 'C. Quigg --'])
      @bf.generate_complex_notes(field, @work)
      expect(@bf.graph.count).to eq(12)
    end

  end

  context 'tag(400|410|411|430|440|490|533|534|630|700|710|711|720|730|740|760|762|765|767|770|772|773|774|775|776|777|780|785|786|787|800|810|811|830)がある場合' do

    it 'Tag533でサブフィールド[abcdemn]があるとgenerate_related_worksが実行されてトリプルが25個作成されること' do
      @record.append(MARC::DataField.new('245', '0', '0', ['a', 'Spiritual unity'], ['c', 'by Ayler, Albert']))
      field = MARC::DataField.new('533', ' ', ' ', ['a', 'Microfiche.'], ['b', '[Ottawa] :'], ['c', 'National Archives of Canada,'], ['d', '[1978?]'], ['e', '2 microfiches (132 fr.) ; 11 x 15 cm.'], ['m', '1978'], ['n', 'note'])
      @bf.generate_related_works(field, 'work', @work)
      expect(@bf.graph.count).to eq(25)
    end

    it 'Tag730でサブフィールド[an]があるとgenerate_related_worksが実行されてトリプルが5つ作成されること' do
      field = MARC::DataField.new('730', '0', ' ', ['a', 'Actualités-Service. '], ['n', 'No 306 (Supplement 1)'])
      @bf.generate_related_works(field, 'work', @work)
      expect(@bf.graph.count).to eq(5)
    end


    it 'Tag740、ind2=2でサブフィールド[a]があり、同時にTag100がありその典拠がリゾルブできないとgenerate_related_worksが実行されてトリプルが12個作成されること' do
      @record.append(MARC::DataField.new('100', '1', ' ', ['a', 'Henry H. Foster']))
      field = MARC::DataField.new('740', '0', '2', ['a', 'Dissolution of the family unit.'], ['p', 'Divorce, separation, and annulment.'])
      @bf.generate_related_works(field, 'work', @work)
      expect(@bf.graph.count).to eq(12)
    end

    it 'Tag740、ind2=2でサブフィールド[a]があり、同時にTag100がありその典拠がリゾルブできるとgenerate_related_worksが実行されてトリプルが10個作成されること' do
      @record.append(MARC::DataField.new('100', '1', ' ', ['a', 'Henry H. Foster'], ['0', '123456789']))
      field = MARC::DataField.new('740', '0', '2', ['a', 'Dissolution of the family unit.'], ['p', 'Divorce, separation, and annulment.'])
      @bf.generate_related_works(field, 'work', @work)
      expect(@bf.graph.count).to eq(10)
    end

    it 'Tag774でサブフィールド[t]があるとgenerate_related_worksが実行されてトリプルが6つ作成されること' do
      @record.append(MARC::DataField.new('245', '1', '0', ['a', '[136th Street, southeastern section of the Bronx]'], ['h', '[graphic].']))
      field = MARC::DataField.new('774', '0', ' ', ['8', '1\c'], ['o', 'NYDA.1993.010.00130. '], ['n', '[DIAPimage].'], ['t', 'Map of area with highlighted street'])
      @bf.generate_related_works(field, 'work', @work)
      expect(@bf.graph.count).to eq(6)
    end

    it 'Tag780でサブフィールド[atwx]があり、サブフィールドwの値に(OCoLC)が含まれているとgenerate_related_worksが実行されてトリプルが11個作成されること' do
      field = MARC::DataField.new('780', '0', '0', ['a', 'American Hospital Association.'], ['t', 'Bulletin of the American Hospital Association'], ['w', '(OCoLC)1777831'], ['x', '1234-5678'])
      @bf.generate_related_works(field, 'work', @work)
      expect(@bf.graph.count).to eq(11)
    end

  end

  context 'tag(856|859)がある場合' do

    it 'Tag505でサブフィールド[3u]があり、サブフィールド3の内容が/finding aid/iだとgenerate_from_856が実行されてトリプルが4つ作成されること' do
      field = field = MARC::DataField.new('856', '4', '2', ['3', 'Finding aid'], ['u', 'http://www.loc.gov/ammem/ead/jackson.sgm'])
      @bf.generate_from_856(field, @work)
      expect(@bf.graph.count).to eq(4)
    end

    it 'Tag505でサブフィールド[3u]があり、サブフィールド3の内容が/finding aid/iでないとgenerate_from_856が実行されてトリプルが5つ作成されること' do
      field = MARC::DataField.new('856', '4', '2', ['3', 'French version'], ['u', 'http://www.cgiar.org/ifpri/reports/0297rpt/0297-ft.htm'])
      @bf.generate_from_856(field, @work)
      expect(@bf.graph.count).to eq(5)
    end

  end

context 'generate_simple_propertyをdomain="work"で呼び出した場合' do

    it 'Tag022でサブフィールド[l]があるとトリプルが4つ作成されること' do
      field = field = MARC::DataField.new('022', '0', ' ', ['l', '1234-1231'])
      @bf.generate_simple_property(field, 'work', @work)
      expect(@bf.graph.count).to eq(4)
    end

    it 'Tag046でサブフィールド[kl]があるとトリプルが1つ作成されること' do
      field = field = MARC::DataField.new('046', ' ', ' ', ['k', '19981022'], ['l', '19981030'])
      @bf.generate_simple_property(field, 'work', @work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'Tag130でサブフィールド[d|f|k|m|n|o|r|s]があるとトリプルが各1つ作成されること' do
      field = field = MARC::DataField.new('130', '0', ' ', ['a', 'Concertos,'], ['m', 'violin,string orchestra,'], ['r', 'D major.'])
      @bf.generate_simple_property(field, 'work', @work)
      expect(@bf.graph.count).to eq(2)
    end

  end

  context 'generate_hashableメソッドを実行した場合' do

    it 'Tag008, 100, 130の組でトリプルが1つ作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| ||||||jpn  '))
      @record.append(MARC::DataField.new('100', '1', ' ', ['a', '山田, 太郎']))
      @record.append(MARC::DataField.new('130', ' ', ' ', ['a', '統一書名']))
      @bf.generate_hashable(@work)
      expect(@bf.graph.count).to eq(1)
    end

    it 'Tag008, 100, 700, 245の組でトリプルが1つ作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| ||||||jpn  '))
      @record.append(MARC::DataField.new('100', '1', ' ', ['a', '山田, 太郎']))
      @record.append(MARC::DataField.new('245', ' ', ' ', ['a', '本書名 :'], ['b', '副書名']))
      @record.append(MARC::DataField.new('700', '1', ' ', ['a', '鈴木, 次郎']))
      @bf.generate_hashable(@work)
      expect(@bf.graph.count).to eq(1)
    end

  end

  context 'generate_adminメソッドを実行した場合' do

    it 'leaderがあればトリプルが6つ作成されること' do
      @bf.generate_admin(@work)
      expect(@bf.graph.count).to eq(6)
    end

    it 'leaderとTag005があるとトリプルが7つ作成されること' do
      @record.append(MARC::ControlField.new('005', '19921118161711.0'))
      @bf.generate_admin(@work)
      expect(@bf.graph.count).to eq(7)
    end

    it 'leaderとTag005, Tag040[a]があるとトリプルが11個作成されること' do
      @record.append(MARC::ControlField.new('005', '19921118161711.0'))
      @record.append(MARC::DataField.new('040', ' ', ' ', ['a', 'DLC']))
      @bf.generate_admin(@work)
      expect(@bf.graph.count).to eq(11)
    end

  end

  context 'generate_instancesメソッドを実行した場合' do

    it 'Tag260[abc]があるとトリプルが15個作成されること' do
      @record.append(MARC::DataField.new('260', ' ', ' ', ['a', '東京 :'], ['b', '東京出版,'], ['c', '2014']))
      @bf.generate_instances(@work)
      expect(@bf.graph.count).to eq(15)
    end

    it 'Tag020[a]とTag260[abc]があるとトリプルが17個作成されること' do
      @record.append(MARC::DataField.new('020', ' ', ' ', ['a', '2905143037']))
      @record.append(MARC::DataField.new('260', ' ', ' ', ['a', '東京 :'], ['b', '東京出版,'], ['c', '2014']))
      @bf.generate_instances(@work)
      expect(@bf.graph.count).to eq(17)
    end

    it 'Tag008, Tag020[a], Tag245[a], Tag260[abc]があるとトリプルが24個作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| ||||||jpn  '))
      @record.append(MARC::DataField.new('020', ' ', ' ', ['a', '2905143037']))
      @record.append(MARC::DataField.new('245', '0', '0', ['a', '書名 :'], ['b', '副書名 /'], ['c', '山田, 太郎 [著]']))
      @record.append(MARC::DataField.new('260', ' ', ' ', ['a', '東京 :'], ['b', '東京出版,'], ['c', '2014']))
      @bf.generate_instances(@work)
      expect(@bf.graph.count).to eq(24)
    end

    it 'Tag008, Tag020[a], Tag245[6a], Tag260[abc], Tag880[6a]があるとトリプルが25個作成されること' do
      @record.append(MARC::ControlField.new('008', '140325s2014    ja ||||g |||| ||||||jpn  '))
      @record.append(MARC::DataField.new('020', ' ', ' ', ['a', '2905143037']))
      @record.append(MARC::DataField.new('245', '0', '0', ['a', '書名 :'], ['b', '副書名 /'], ['c', '山田, 太郎 [著]'], ['6', '880-01']))
      @record.append(MARC::DataField.new('260', ' ', ' ', ['a', '東京 :'], ['b', '東京出版,'], ['c', '2014']))
      @record.append(MARC::DataField.new('880', '0', '0', ['6', '245-01/$1'], ['a', 'ショメイ :'], ['b', 'フクショメイ /']))
      @bf.generate_instances(@work)
      expect(@bf.graph.count).to eq(25)
    end

  end

end