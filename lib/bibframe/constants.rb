# -*- encoding: utf-8 -*-

module Bibframe

  CARRIERS_CODE = {
      'audio cartridge' => 'sg',
      'audio cylinder' => 'se',
      'audio disc' => 'sd',
      'sound track reel' => 'si',
      'audio roll' => 'sq',
      'audiocassette' => 'ss',
      'audiotape reel' => 'st',
      'other audio Carrier' => 'sz',
      'computer card' => 'ck',
      'computer chip cartridge' => 'cb',
      'computer disc' => 'cd',
      'computer disc cartridge' => 'ce',
      'computer tape cartridge' => 'ca',
      'computer tape cassette' => 'cf',
      'computer tape reel' => 'ch',
      'online resource' => 'cr',
      'other computer carrier' => 'cz',
      'aperture card' => 'ha',
      'microfiche' => 'he',
      'microfiche cassette' => 'hf',
      'microfilm cartridge' => 'hb',
      'microfilm cassette' => 'hc',
      'microfilm reel' => 'hd',
      'microfilm roll' => 'hj',
      'microfilm slip' => 'hh',
      'microopaque' => 'hg',
      'other microform carrier' => 'hz',
      'microscope slide' => 'pp',
      'other microscopic carrier' => 'pz',
      'film cartridge' => 'mc',
      'film cassette' => 'mf',
      'film reel' => 'mr',
      'film roll' => 'mo',
      'filmslip' => 'gd',
      'filmstrip' => 'gf',
      'filmstrip cartridge' => 'gc',
      'overhead transparency' => 'gt',
      'slide' => 'gs',
      'other projected-image carrier' => 'mz',
      'stereograph card' => 'eh',
      'stereograph disc' => 'es',
      'other stereographic Carrier' => 'ez',
      'card' => 'no',
      'flipchart' => 'nn',
      'roll' => 'na',
      'sheet' => 'nb',
      'volume' => 'nc',
      'object' => 'nr',
      'other unmediated carrier' => 'nz',
      'video cartridge' => 'vc',
      'videocassette' => 'vf',
      'videodisc' => 'vd',
      'videotape reel' => 'vr',
      'other video carrier' => 'vz',
      'unspecified' => 'zu',
    }.freeze

  CLASSES = {
    'work' => {
      '050' => 'classificationLcc',
      '051' => 'classificationLcc',
      '052' => 'classificationLcc',
      '055' => 'classificationLcc',
      '060' => 'classificationNlm',
      '061' => 'classificationNlm',
      '070' => 'classificationLcc',
      '071' => 'classificationLcc',
      '080' => 'classificationUdc',
      '082' => 'classificationDdc',
      '083' => 'classificationDdc',
      '084' => 'classification',
      '086' => 'classification',
    },
    'Holding' => {
    }
  }.freeze


  CONTENT_TYPES_CODE = {
    'cartographic dataset' => 'crd',
    'cartographic image' => 'cri',
    'cartographic moving image' => 'crm',
    'cartographic tactile image' => 'crt',
    'cartographic tactile three-dimensional form' => 'crn',
    'cartographic three-dimensional form' => 'crf',
    'computer dataset' => 'cod',
    'computer program' => 'cop',
    'notated movement' => 'ntv',
    'notated music' => 'ntm',
    'performed music' => 'prm',
    'sounds' => 'snd',
    'spoken word' => 'spw',
    'still image' => 'sti',
    'tactile image' => 'tci',
    'tactile notated music' => 'tcm',
    'tactile notated movement' => 'tcn',
    'tactile text' => 'tct',
    'tactile three-dimensional form' => 'tcf',
    'text' => 'txt',
    'three-dimensional form' => 'tdf',
    'three-dimensional moving image' => 'tdm',
    'two-dimensional moving image' => 'tdi',
    'other' => 'xxx',
    'unspecified' => 'zzz',
  }.freeze

  FORMS_OF_ITEMS = {
    'a' => {form: 'Microfilm', rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
    'b' => {form: 'Microfiche', rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
    'c' => {form: 'Microopaque', rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
    'd' => {form: 'Large print', rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
    'f' => {form: 'Braille', rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
    'o' => {form: 'Online', rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial SoftwareApplication)},
    'q' => {form: 'Direct electronic', rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial SoftwareApplication)},
    'r' => {form: 'Regular print reproduction', rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
    's' => {form: 'Electronic', rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
  }.freeze

  INSTANCE_TYPES = {
    'cf007' => {
      'c' => 'Electronic',
      'f' => 'Tactile',
    },
    'leader6' => {
      'd' => 'Manuscript',
      'f' => 'Manuscript',
      't' => 'Manuscript',
    },
    'leader7' => {
      'b' => 'Serial',
      'c' => 'Collection',
      'd' => 'Collection',
      'i' => 'Integrating',
      's' => 'Serial',
    },
    'leader8' => {
      'a' => 'Archival',
    },
    'sf336a' => {
      'tactile text' => 'Tactile',
    },
    'sf336b' => {
      'tct' => 'Tactile',
    },
  }.freeze

  LANG_PART = {
    'a' => 'text',
    'b' => 'summary or abstract',
    'd' => 'sung or spoken text',
    'e' => 'librettos',
    'f' => 'table of contents',
    'g' => 'accompanying material other than librettos',
    'h' => 'original',
    'j' => 'subtitles or captions',
    'k' => 'intermediate translations',
    'm' => 'original accompanying materials other than librettos',
    'n' => 'original libretto',
  }.freeze

  MEDIA_TYPES_CODE = {
    'audio'         => 's',
    'computer'      => 'c',
    'microform'     => 'h',
    'microscopic'   => 'p',
    'projected'     => 'g',
    'stereographic' => 'e',
    'unmediated'    => 'n',
    'video'         => 'v',
    'other'         => 'x',
    'unspecified'   => 'z',
  }.freeze

  RELATIONSHIPS = {
    'work' => {
      '400' => {property: 'series', reverse: 'hasParts'},
      '410' => {property: 'series', reverse: 'hasParts'},
      '411' => {property: 'series', reverse: 'hasParts'},
      '430' => {property: 'series', reverse: 'hasParts'},
      '440' => {property: 'series', reverse: 'hasParts'},
      '490' => {property: 'series', reverse: 'hasParts'},
      '533' => {property: 'reproduction', reverse: ''},
      '534' => {property: 'originalVersion', reverse: ''},
      '630' => {property: 'subject', reverse: 'isSubjectOf'},
      '700' => [
        {ind2: '2', property: 'hasPart', reverse: 'isIncludedIn'},
        {ind2: ' ', property: 'relatedResource', reverse: 'relatedWork'},
        {ind2: '0', property: 'relatedResource', reverse: 'relatedWork'},
        {ind2: '1', property: 'relatedResource', reverse: 'relatedWork'},

      ],
      '710' => [
        {ind2: '2', property: 'hasPart', reverse: 'isIncludedIn'},
        {ind2: ' ', property: 'relatedResource', reverse: 'relatedWork'},
        {ind2: '0', property: 'relatedResource', reverse: 'relatedWork'},
        {ind2: '1', property: 'relatedResource', reverse: 'relatedWork'},
      ],
      '711' => [
        {ind2: '2', property: 'hasPart', reverse: 'isIncludedIn'},
        {ind2: ' ', property: 'relatedResource', reverse: 'relatedWork'},
        {ind2: '0', property: 'relatedResource', reverse: 'relatedWork'},
        {ind2: '1', property: 'relatedResource', reverse: 'relatedWork'},
      ],
      '720' => [
        {ind2: '2', property: 'hasPart', reverse: 'isIncludedIn'},
        {ind2: ' ', property: 'relatedResource', reverse: 'relatedWork'},
        {ind2: '0', property: 'relatedResource', reverse: 'relatedWork'},
        {ind2: '1', property: 'relatedResource', reverse: 'relatedWork'},
      ],
      '730' => [
        {ind2: ' ', property: 'relatedWork', reverse: 'relatedItem'},
        {ind2: '2', property: 'hasPart', reverse: 'partOf'},
      ],
      '740' => [
        {ind2: ' ', property: 'relatedWork', reverse: 'relatedWork'},
        {ind2: '2', property: 'partOf', reverse: 'hasPart'},
      ],
      '760' => {property: 'subseriesOf', reverse: 'hasParts'},
      '762' => {property: 'subseries', reverse: 'hasParts'},
      '765' => {property: 'translationOf', reverse: 'hasTranslation'},
      '767' => {property: 'translation', reverse: 'translationOf'},
      '770' => {property: 'supplement', reverse: 'supplement'},
      '772' => [
        {ind2: ' ', property: 'supplementTo', reverse: 'isSupplemented'},
      ],
      '773' => {property: 'partOf', reverse: 'hasConstituent'},
      '774' => {property: 'hasPart', reverse: 'has Part'},
      '775' => {property: 'otherEdition' , reverse: 'hasOtherEdition'},
      '777' => {property: 'issuedWith', reverse: 'issuedWith'},
      '780' => [
        {ind2: '0', property: 'continues', reverse: 'continuationOf'},
        {ind2: '1', property: 'continuesInPart', reverse: 'partiallyContinuedBy'},
        {ind2: '2', property: 'supersedes', reverse: 'continuationOf'},
        {ind2: '3', property: 'supersedesInPartBy', reverse: 'partiallyContinuedBy'},
        {ind2: '4', property: 'unionOf', reverse: 'preceding'},
        {ind2: '5', property: 'absorbed', reverse: 'isAbsorbedBy'},
        {ind2: '6', property: 'absorbedInPartBy', reverse: 'isPartlyAbsorbedBy'},
        {ind2: '7', property: 'separatedFrom', reverse: 'formerlyIncluded'},
      ],
      '785' => [
        {ind2: '0', property: 'continuedBy', reverse: 'continues'},
        {ind2: '1', property: 'continuedInPartBy', reverse: 'partiallyContinues'},
        {ind2: '2', property: 'supersededBy', reverse: 'continues'},
        {ind2: '3', property: 'supersededInPartBy', reverse: 'partiallyContinues'},
        {ind2: '4', property: 'absorbedBy', reverse: 'absorbs'},
        {ind2: '5', property: 'absorbedInPartBy', reverse: 'partiallyAbsorbs'},
        {ind2: '6', property: 'splitInto', reverse: 'splitFrom'},
        {ind2: '7', property: 'mergedToForm', reverse: 'mergedFrom'},
        {ind2: '8', property: 'continuedBy', reverse: 'formerlyNamed'},
      ],
      '786' => {property: 'dataSource', reverse: ''},
      '787' => {property: 'relatedResource', reverse: 'relatedItem'},
      '800' => {property: 'series', reverse: 'hasParts'},
      '810' => {property: 'series', reverse: 'hasParts'},
      '811' => {property: 'series', reverse: 'hasParts'},
      '830' => {property: 'series', reverse: 'hasParts'},
    },
    'instance' => [
      '776' => {property: 'otherPhysicalFormat', reverse: 'hasOtherPhysicalFormat'}
    ],
  }.freeze

  RESOURCE_TYPES = {
    :leader => {
      'a' => 'Text',
      'c' => 'NotatedMusic',
      'd' => 'NotatedMusic',
      'e' => 'Cartography',
      'f' => 'Cartography',
      'g' => 'MovingImage',
      'i' => 'Audio',
      'j' => 'Audio',
      'k' => 'StillImage',
      'm' => 'Dataset',
      'm' => 'Multimedia',
      'o' => 'MixedMaterial',
      'p' => 'MixedMaterial',
      'r' => 'ThreeDimensionalObject',
      't' => 'Text',
    },
    :cf007 => {
      'a' => 'Cartography',
      'd' => 'Cartography',
      'f' => 'Tactile',
      'm' => 'MovingImage',
      'o' => 'MixedMaterial',
      'q' => 'NotatedMusic',
      'r' => 'Cartography',
      's' => 'Audio',
      't' => 'Text',
      'v' => 'MovingImage',
    },
    :sf336a => {
      'cartographic dataset' => ['Cartography', 'Dataset'],
      'cartographic image' => ['Cartography', 'StillImage'],
      'cartographic moving image' => ['Cartography', 'MovingImage'],
      'cartographic tactile image' => ['Cartography', 'Dataset'],
      'cartographic tactile three dimensional form' => ['Cartography', 'Dataset', 'ThreeDimensionalObject'],
      'cartographic three dimensional form' => ['Cartography', 'ThreeDimensionalObject'],
      'computer dataset' => ['Dataset'],
      'computer program' => ['Multimedia'],
      'notated movement' => ['NotatedMovement'],
      'notated music' => ['NotatedMusic'],
      'performed music' => ['Audio'],
      'sounds' => ['Audio'],
      'spoken word' => ['Audio'],
      'still image' => ['StillImage'],
      'tactile image' => ['Dataset', 'StillImage'],
      'tactile notated movement' => ['Dataset', 'NotatedMovement'],
      'tactile notated music' => ['Dataset'],
      'tactile notated music' => ['NotatedMusic'],
      'tactile text' => ['Dataset', 'Text'],
      'tactile three-dimensional form' => ['Dataset', 'ThreeDimensionalObject'],
      'text' => ['Text'],
      'three-dimensional form' => ['ThreeDimensionalObject'],
      'three-dimensional moving image' => ['MovingImage', 'ThreeDimensionalObject'],
      'two-dimensional moving image' => ['MovingImage'],
    },
    :sf336b => {
      'ccm' => ['NotatedMusic'],
      'cod' => ['Ddataset'],
      'cop' => ['Multimedia'],
      'crd' => ['Cartography', 'Ddataset'],
      'crf' => ['Cartography', 'ThreeDimensionalObject'],
      'cri' => ['Cartography', 'StillImage'],
      'crm' => ['Cartography'],
      'crn' => ['Cartography', 'Dataset', 'ThreeDimensionalObject'],
      'crt' => ['Cartography', 'Dataset'],
      'ntm' => ['NotatedMusic'],
      'ntv' => ['NotatedMovement'],
      'prm' => ['Audio'],
      'snd' => ['Audio'],
      'spw' => ['Audio'],
      'sti' => ['StillImage'],
      'tcf' => ['Dataset', 'ThreeDimensionalObject'],
      'tci' => ['Dataset', 'StillImage'],
      'tcm' => ['Dataset', 'ThreeDimensionalObject'],
      'tcn' => ['Dataset', 'NotatedMovement'],
      'tct' => ['Dataset', 'Text'],
      'tdf' => ['ThreeDimensionalObject'],
      'tdi' => ['MovingImage'],
      'tdm' => ['MovingImage'],
      'txt' => ['Text'],
    },
    :sf337a => {
      'audio' => 'Audio',
    },
    :sf337b => {
      's' => 'Audio',
    }
  }.freeze

  SIMPLE_PROPERTIES = {
    'annotation' => {
      '040' => [
        {property: 'descriptionSource', sfcodes: 'a', uri: 'http://id.loc.gov/vocabulary/organizations/', group: 'identifiers'},
        {property: 'descriptionLanguage', sfcodes: 'b', uri: 'http://id.loc.gov/vocabulary/languages/'},
        {property: 'descriptionConventions', sfcodes: 'e', uri: 'http://id.loc.gov/vocabulary/descriptionConventions/'},
      ],
    },
    'arrangement' => {
      '351' => [
      {property: 'materialOrganization', sfcodes: 'a'},
      {property: 'materialArrangement', sfcodes: 'b'},
      {property: 'materialHierarchicalLevel', sfcodes: 'c'},
      {property: 'materialPart', sfcodes: '3'},
      ],
    },
    'cartography' => {
      '255' => [
        {property: 'cartographicScale', sfcodes: 'a'},
        {property: 'cartographicProjection', sfcodes: 'b'},
        {property: 'cartographicCoordinates', sfcodes: 'c'},
        {property: 'cartographicAscensionAndDeclination', sfcodes: 'd'},
        {property: 'cartographicEquinox', sfcodes: 'e'},
        {property: 'cartographicOuterGRing', sfcodes: 'f'},
        {property: 'cartographicExclusionGRing', sfcodes: 'g'},
      ],
      '034' => [
        {property: 'cartographicScale', sfcodes: ''},
      ]
    },
    'classification' => {
      '082' => [
        {property: 'classificationEdition', sfcodes: ''},
      ],
      '083' => [
        {property: 'classificationEdition', sfcodes: ''},
        {property: 'classificationAssigner', sfcodes: ''},
        {property: 'classificationSpanEnd', sfcodes: 'c'},
        {property: 'classificationTable', sfcodes: 'z'},
        {property: 'classificationTableSeq', sfcodes: 'y'},
      ],
    },
    'contentcategory' => {
      '130' => {property: 'contentCategory', sfcodes: 'h'},
      '240' => {property: 'contentCategory', sfcodes: 'h'},
      '243' => {property: 'contentCategory', sfcodes: 'h'},
      '245' => {property: 'contentCategory', sfcodes: 'k'},
      '513' => {property: 'contentCategory', sfcodes: 'a'},
      '516' => {property: 'contentCategory', sfcodes: 'a'},
      '700' => {property: 'contentCategory', sfcodes: 'h'},
      '710' => {property: 'contentCategory', sfcodes: 'h'},
      '711' => {property: 'contentCategory', sfcodes: 'h'},
      '730' => {property: 'contentCategory', sfcodes: 'h'},
    },
    'event' => {
      '518' => {property: 'eventDate', sfcodes: 'd'},
    },
    'findingAid' => {
      '555' => {property: 'findingAidNote', sfcodes: '3abc'},
    },
    'helditem' => {
       '561' => {property: 'custodialHistory', sfcodes: 'a'},
    },
    'instance' => {
      '010' => {property: 'lccn', sfcodes: 'a', uri: 'http://id.loc.gov/authorities/test/identifiers/lccn/', group: 'identifiers'},
      '015' => {property: 'nbn', sfcodes: 'a', group: 'identifiers'},
      '016' => {property: 'nban',  sfcodes: 'a', group: 'identifiers'},
      '017' => {property: 'legalDeposit', sfcodes: 'a', group: 'identifiers'},
      '022' => {property: 'issn', sfcodes: 'a', group: 'identifiers', uri: 'http://issn.example.org/'},
      '024' => [
        {property: '$2', sfcodes: 'a', ind1: '7', group: 'identifiers'},
        {property: 'ean', sfcodes: 'azd', ind1: '3', group: 'identifiers', comment: '(sep by -)'},
        {property: 'ismn', sfcodes: 'a', ind1: '2', group: 'identifiers'},
        {property: 'isrc', sfcodes: 'a', ind1: '0', group: 'identifiers'},
        {property: 'sici', sfcodes: 'a', ind1: '4', group: 'identifiers'},
        {property: 'upc', sfcodes: 'a', ind1: '1', group: 'identifiers'},
      ],
      '025' => {property: 'lcOverseasAcq', sfcodes: 'a', group: 'identifiers'},
      '026' => {property: 'fingerprint', sfcodes: 'e', group: 'identifiers'},
      '027' => {property: 'strn', sfcodes: 'a', group: 'identifiers'},
      '028' => [
        {property: 'matrixNumber', sfcodes: 'a', ind1: '1', group: 'identifiers'},
        {property: 'musicPlate', sfcodes: 'a', ind1: '2', group: 'identifiers'},
        {property: 'musicPublisherNumber', sfcodes: 'a', ind1: '3', group: 'identifiers'},
        {property: 'publisherNumber', sfcodes: 'a', ind1: '5', group: 'identifiers'},
        {property: 'videorecordingNumber', sfcodes: 'a', ind1: '4', group: 'identifiers'},
      ],
      '030' => {property: 'coden', sfcodes: 'a', group: 'identifiers'},
      '032' => {property: 'postalRegistration', sfcodes: 'a', group: 'identifiers'},
      '035' => {property: 'systemNumber', sfcodes: 'a', group: 'identifiers', uri: 'http://www.worldcat.org/oclc/'},
      '036' => {property: 'studyNumber', sfcodes: 'a', group: 'identifiers'},
      '037' => {property: 'stockNumber', sfcodes: 'a', group: 'identifiers'},
      '088' => {property: 'reportNumber', sfcodes: 'a', group: 'identifiers'},
      '245' => [
        {property: 'formDesignation', sfcodes: 'h'},
        {property: 'formDesignation', sfcodes: 'k'},
        {property: 'responsibilityStatement', sfcodes: 'c'},
        {property: 'titleStatement', sfcodes: 'ab'},
      ],
      '250' => [
        {property: 'edition', sfcodes: 'a'},
        {property: 'editionResponsibility', sfcodes: 'b'},
      ],
      '258' => {property: 'philatelicDataNote', sfcodes: 'ab'},
      '260' => {property: 'providerStatement', sfcodes: 'abc'},
      '264' => {property: 'copyrightDate', sfcodes: 'c', ind2: '4'},
      '300' => [
        {property: 'dimensions', sfcodes: 'c'},
        {property: 'extent', sfcodes: 'af'},
        {property: 'illustrationNote', sfcodes: 'b'},
      ],
      '345' => {property: 'aspectRatio', sfcodes: 'a'},
      '500' => {property: 'note', sfcodes: '3a'},
      '505' => {property: 'contentsNote', sfcodes: 'agrtu', ind2: ' '},
      '506' => {property: 'accessCondition', sfcodes: 'a'},
      '507' => {property: 'graphicScaleNote', sfcodes: 'a'},
      '508' => {property: 'creditsNote', startwith: 'Credits: '},
      '511' => {property: 'performerNote', startwith: 'Cast: '},
      '524' => {property: 'preferredCitation', sfcodes: 'a'},
      '541' => {property: 'immediateAcquisition', sfcodes: 'cad'},
      '546' => {property: 'languageNote', sfcodes: '3a'},
      '546' => {property: 'notation', sfcodes: 'b'},
    },
    'specialinstnc' => {
      '337' => [
        {property: 'mediaCategory', sfcodes: 'a', uri: 'http://id.loc.gov/vocabulary/mediaCategory/'},
        {property: 'mediaCategory', sfcodes: 'b', uri: 'http://id.loc.gov/vocabulary/mediaCategory/'},
      ],
      '338' => [
        {property: 'carrierCategory', sfcodes: 'a', uri: 'http://id.loc.gov/vocabulary/carriers/'},
        {property: 'carrierCategory', sfcodes: 'b', uri: 'http://id.loc.gov/vocabulary/carriers/'},
      ],
    },
    'title' => {
      '130' => [
        {property: 'titleValue', sfcodes: 'a'},
        {property: 'titleAttribute', sfcodes: 'g'},
        {property: 'partNumber', sfcodes: 'n'},
        {property: 'partTitle', sfcodes: 'p'},
      ],
      '210' => [
        {property: 'titleValue', sfcodes: 'a'},
        {property: 'titleQualifier', sfcodes: 'b'},
        {property: 'titleSource', sfcodes: '2'},
      ],
      '222' => [
        {property: 'titleValue', sfcodes: 'a'},
        {property: 'titleQualifier', sfcodes: 'b'},
      ],
      '240' => [
        {property: 'titleValue', sfcodes: 'a'},
        {property: 'titleAttribute', sfcodes: 'g'},
        {property: 'partNumber', sfcodes: 'n'},
        {property: 'titleAttribute', sfcodes: 'o'},
        {property: 'partTitle', sfcodes: 'p'},
      ],
      '242' => [
        {property: 'titleValue', sfcodes: 'a'},
        {property: 'partTitle', sfcodes: 'p'},
      ],
      '245' => [
        {property: 'titleValue', sfcodes: 'a'},
        {property: 'subtitle', sfcodes: 'b'},
        {property: 'partNumber', sfcodes: 'n'},
        {property: 'partTitle', sfcodes: 'p'},
      ],
      '246' => [
        {property: 'titleValue', sfcodes: 'a'},
        {property: 'subtitle', sfcodes: 'b'},
        {property: 'titleVariationDate', sfcodes: 'f'},
        {property: 'partNumber', sfcodes: 'n'},
        {property: 'partTitle', sfcodes: 'p'},
      ],
      '247' => [
        {property: 'titleValue', sfcodes: 'a'},
        {property: 'subtitle', sfcodes: 'b'},
        {property: 'titleVariationDate', sfcodes: 'f'},
        {property: 'partNumber', sfcodes: 'n'},
        {property: 'partTitle', sfcodes: 'p'},
      ],
      '730' => {property: 'partTitle', sfcodes: 'p'},
    },
    'work' => {
      '022' => {property: 'issnL', sfcodes: 'l', group: 'identifiers', uri: 'http://issn.example.org/'},
      '046' => {property: 'originDate', sfcodes: 'kl', stringjoin: '-'},
      '130' => [
        {property: 'legalDate', sfcodes: 'd'},
        {property: 'originDate', sfcodes: 'f'},
        {property: 'formDesignation', sfcodes: 'k'},
        {property: 'musicMediumNote', sfcodes: 'm'},
        {property: 'musicNumber', sfcodes: 'n'},
        {property: 'musicVersion', sfcodes: 'o'},
        {property: 'musicKey', sfcodes: 'r'},
        {property: 'musicVersion', sfcodes: 's'},
      ],
      '240' => [
        {property: 'formDesignation', sfcodes: 'k'},
        {property: 'musicMediumNote', sfcodes: 'm'},
        {property: 'musicVersion', sfcodes: 'o'},
        {property: 'musicKey', sfcodes: 'r'},
        {property: 'musicVersion', sfcodes: 's'},
      ],
      '243' => {property: 'musicMediumNote', sfcodes: 'm'},
      '306' => {property: 'duration', sfcodes: 'a'},
      '310' => {property: 'frequencyNote', sfcodes: 'ab'},
      '321' => {property: 'frequencyNote', sfcodes: 'ab'},
      '382' => {property: 'musicMediumNote', sfcodes: 'adp'},
      '384' => {property: 'musicKey', sfcodes: 'a'},
      '500' => {property: 'note', sfcodes: '3a'},
      '502' => [
        {property: 'dissertationNote', sfcodes: 'a'},
        {property: 'dissertationDegree', sfcodes: 'b'},
        {property: 'dissertationYear', sfcodes: 'd'},
      ],
      '513' => {property: 'temporalCoverageNote', sfcodes: 'b'},
      '522' => {property: 'geographicCoverageNote', sfcodes: 'a'},
      '525' => {property: 'supplementaryContentNote', sfcodes: 'a'},
      '586' => {property: 'awardNote', sfcodes: '3a'},
      '710' => {property: 'treatySignator', sfcodes: 'g'},
      '730' => [
        {property: 'legalDate', sfcodes: 'd'},
        {property: 'originDate', sfcodes: 'f'},
        {property: 'formDesignation', sfcodes: 'k'},
        {property: 'musicMediumNote', sfcodes: 'm'},
        {property: 'musicNumber', sfcodes: 'n'},
      ],
    },
  }.freeze

  SUBJECTS_TYPES = {
    '600' => 'Person',
    '610' => 'Organization',
    '611' => 'Meeting',
    '648' => 'Temporal',
    '650' => 'Topic',
    '651' => 'Place',
    '654' => 'Topic',
    '655' => 'Topic',
    '656' => 'Topic',
    '657' => 'Topic',
    '658' => 'Topic',
    '662' => 'Place',
    '653' => 'Topic',
    '751' => 'Place',
    '752' => 'Topic',
  }

  TARGET_AUDIENCES = {
    'a' => 'Pre',
    'b' => 'Pri',
    'c' => 'Pra',
    'd' => 'Ado',
    'e' => 'Adu',
    'f' => 'Spe',
    'g' => 'Gen',
    'j' => 'Juv',
  }.freeze

  VALID_LCC = [
    'DAW','DJK','KBM','KBP','KBR','KBU','KDC','KDE','KDG','KDK','KDZ','KEA','KEB',
    'KEM','KEN','KEO','KEP','KEQ','KES','KEY','KEZ','KFA','KFC','KFD','KFF','KFG',
    'KFH','KFI','KFK','KFL','KFM','KFN','KFO','KFP','KFR','KFS','KFT','KFU','KFV',
    'KFW','KFX','KFZ','KGA','KGB','KGC','KGD','KGE','KGF','KGG','KGH','KGJ','KGK',
    'KGL','KGM','KGN','KGP','KGQ','KGR','KGS','KGT','KGU','KGV','KGW','KGX','KGY',
    'KGZ','KHA','KHC','KHD','KHF','KHH','KHK','KHL','KHM','KHN','KHP','KHQ','KHS',
    'KHU','KHW','KJA','KJC','KJE','KJG','KJH','KJJ','KJK','KJM','KJN','KJP','KJR',
    'KJS','KJT','KJV','KJW','KKA','KKB','KKC','KKE','KKF','KKG','KKH','KKI','KKJ',
    'KKK','KKL','KKM','KKN','KKP','KKQ','KKR','KKS','KKT','KKV','KKW','KKX','KKY',
    'KKZ','KLA','KLB','KLD','KLE','KLF','KLH','KLM','KLN','KLP','KLQ','KLR','KLS',
    'KLT','KLV','KLW','KMC','KME','KMF','KMG','KMH','KMJ','KMK','KML','KMM','KMN',
    'KMP','KMQ','KMS','KMT','KMU','KMV','KMX','KMY','KNC','KNE','KNF','KNG','KNH',
    'KNK','KNL','KNM','KNN','KNP','KNQ','KNR','KNS','KNT','KNU','KNV','KNW','KNX',
    'KNY','KPA','KPC','KPE','KPF','KPG','KPH','KPJ','KPK','KPL','KPM','KPP','KPS',
    'KPT','KPV','KPW','KQC','KQE','KQG','KQH','KQJ','KQK','KQM','KQP','KQT','KQV',
    'KQW','KQX','KRB','KRC','KRE','KRG','KRK','KRL','KRM','KRN','KRP','KRR','KRS',
    'KRU','KRV','KRW','KRX','KRY','KSA','KSC','KSE','KSG','KSH','KSK','KSL','KSN',
    'KSP','KSR','KSS','KST','KSU','KSV','KSW','KSX','KSY','KSZ','KTA','KTC','KTD',
    'KTE','KTF','KTG','KTH','KTJ','KTK','KTL','KTN','KTQ','KTR','KTT','KTU','KTV',
    'KTW','KTX','KTY','KTZ','KUA','KUB','KUC','KUD','KUE','KUF','KUG','KUH','KUN',
    'KUQ','KVB','KVC','KVE','KVH','KVL','KVM','KVN','KVP','KVQ','KVR','KVS','KVU',
    'KVW','KWA','KWC','KWE','KWG','KWH','KWL','KWP','KWQ','KWR','KWT','KWW','KWX',
    'KZA','KZD','AC','AE','AG','AI','AM','AN','AP','AS','AY','AZ','BC','BD','BF',
    'BH','BJ','BL','BM','BP','BQ','BR','BS','BT','BV','BX','CB','CC','CD','CE','CJ',
    'CN','CR','CS','CT','DA','DB','DC','DD','DE','DF','DG','DH','DJ','DK','DL','DP',
    'DQ','DR','DS','DT','DU','DX','GA','GB','GC','GE','GF','GN','GR','GT','GV','HA',
    'HB','HC','HD','HE','HF','HG','HJ','HM','HN','HQ','HS','HT','HV','HX','JA','JC',
    'JF','JJ','JK','JL','JN','JQ','JS','JV','JX','JZ','KB','KD','KE','KF','KG','KH',
    'KJ','KK','KL','KM','KN','KP','KQ','KR','KS','KT','KU','KV','KW','KZ','LA','LB',
    'LC','LD','LE','LF','LG','LH','LJ','LT','ML','MT','NA','NB','NC','ND','NE','NK',
    'NX','PA','PB','PC','PD','PE','PF','PG','PH','PJ','PK','PL','PM','PN','PQ','PR',
    'PS','PT','PZ','QA','QB','QC','QD','QE','QH','QK','QL','QM','QP','QR','RA','RB',
    'RC','RD','RE','RF','RG','RJ','RK','RL','RM','RS','RT','RV','RX','RZ','SB','SD',
    'SF','SH','SK','TA','TC','TD','TE','TF','TG','TH','TJ','TK','TL','TN','TP','TR',
    'TS','TT','TX','UA','UB','UC','UD','UE','UF','UG','UH','VA','VB','VC','VD','VE',
    'VF','VG','VK','VM','ZA','A','B','C','D','E','F','G','H','J','K','L','M','N',
    'P','Q','R','S','T','U','V','Z'].freeze

end