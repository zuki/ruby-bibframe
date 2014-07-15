require 'bundler/setup'
require 'marc'
require 'rdf'
require 'linkeddata'
include RDF

include 'marc/bibframe/constatns'
include 'marc/bibframe/utils'

module MARC

  class Record
  	def include_member?(ary)
  		all_tags = self.tags
   		if ary.is_a?(Array)
  			ary.select{|t| all_tags.include?(t)}.size > 0
  		else
        raise MARC::Exception.new(),
        "parameter is not Array instance #{ary}"
      end
  	end
  end

  class DataField
    def values_of(code)
      subfields.select{|s| s.code == code}.map{|s| s.value}
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

	module Bibframe

  class BFRDF

		RESOURCE_TYPES = {
	    :leader => {
	      "a" => "Text",
	      "c" => "NotatedMusic",
	      "d" => "NotatedMusic",
	      "e" => "Cartography",
	      "f" => "Cartography",
	      "g" => "MovingImage",
	      "i" => "Audio",
	      "j" => "Audio",
	      "k" => "StillImage",
	      "m" => "Dataset",
	      "m" => "Multimedia",
	      "o" => "MixedMaterial",
	      "p" => "MixedMaterial",
	      "r" => "ThreeDimensionalObject",
	      "t" => "Text",
	    },
	    :cf007 => {
	      "a" => "Cartography",
	      "d" => "Cartography",
	      "f" => "Tactile",
	      "m" => "MovingImage",
	      "o" => "MixedMaterial",
	      "q" => "NotatedMusic",
	      "r" => "Cartography",
	      "s" => "Audio",
	      "t" => "Text",
	      "v" => "MovingImage",
	    },
	    :sf336a => {
	      "cartographic dataset" => ["Cartography", "Dataset"],
	      "cartographic image" => ["Cartography", "StillImage"],
	      "cartographic moving image" => ["Cartography", "MovingImage"],
	      "cartographic tactile image" => ["Cartography", "Dataset"],
	      "cartographic tactile three dimensional form" => ["Cartography", "Dataset", "ThreeDimensionalObject"],
	      "cartographic three dimensional form" => ["Cartography", "ThreeDimensionalObject"],
	      "computer dataset" => ["Dataset"],
	      "computer program" => ["Multimedia"],
	      "notated movement" => ["NotatedMovement"],
	      "notated music" => ["NotatedMusic"],
	      "performed music" => ["Audio"],
	      "sounds" => ["Audio"],
	      "spoken word" => ["Audio"],
	      "still image" => ["StillImage"],
	      "tactile image" => ["Dataset", "StillImage"],
	      "tactile notated movement" => ["Dataset", "NotatedMovement"],
	      "tactile notated music" => ["Dataset"],
	      "tactile notated music" => ["NotatedMusic"],
	      "tactile text" => ["Dataset", "Text"],
	      "tactile three-dimensional form" => ["Dataset", "ThreeDimensionalObject"],
	      "text" => ["Text"],
	      "three-dimensional form" => ["ThreeDimensionalObject"],
	      "three-dimensional moving image" => ["MovingImage", "ThreeDimensionalObject"],
	      "two-dimensional moving image" => ["MovingImage"],
	    },
	    :sf336b => {
	      "ccm" => ["NotatedMusic"],
	      "cod" => ["Ddataset"],
	      "cop" => ["Multimedia"],
	      "crd" => ["Cartography", "Ddataset"],
	      "crf" => ["Cartography", "ThreeDimensionalObject"],
	      "cri" => ["Cartography", "StillImage"],
	      "crm" => ["Cartography"],
	      "crn" => ["Cartography", "Dataset", "ThreeDimensionalObject"],
	      "crt" => ["Cartography", "Dataset"],
	      "ntm" => ["NotatedMusic"],
	      "ntv" => ["NotatedMovement"],
	      "prm" => ["Audio"],
	      "snd" => ["Audio"],
	      "spw" => ["Audio"],
	      "sti" => ["StillImage"],
	      "tcf" => ["Dataset", "ThreeDimensionalObject"],
	      "tci" => ["Dataset", "StillImage"],
	      "tcm" => ["Dataset", "ThreeDimensionalObject"],
	      "tcn" => ["Dataset", "NotatedMovement"],
	      "tct" => ["Dataset", "Text"],
	      "tdf" => ["ThreeDimensionalObject"],
	      "tdi" => ["MovingImage"],
	      "tdm" => ["MovingImage"],
	      "txt" => ["Text"],
	    },
	    :sf337a => {
	      "audio" => "Audio",
	    },
	    :sf337b => {
	      "s" => "Audio",
	    }
	  }.freeze

	  SIMPLE_PROPERTIES = {
	    "annotation" => [
	      {property: "descriptionConventions", tag: "040", sfcodes: "e", uri: "http://id.loc.gov/vocabulary/descriptionConventions/", label: "Description conventions"},
	      {property: "descriptionLanguage", tag: "040", sfcodes: "b", uri: "http://id.loc.gov/vocabulary/languages/", label: "Description Language"},
	      {property: "descriptionSource", tag: "040", sfcodes: "a", uri: "http://id.loc.gov/vocabulary/organizations/", group: "identifiers", label: "Description source"},
	    ],
	    "arrangement" => [
	      {property: "materialArrangement", tag: "351", sfcodes: "b", label: "ImaterialArrangement"},
	      {property: "materialArrangement", tag: "351", sfcodes: "b", label: "ImaterialArrangement"},
	      {property: "materialHierarchicalLevel", tag: "351", sfcodes: "c", label: "materialHierarchicalLevel"},
	      {property: "materialOrganization", tag: "351", sfcodes: "a", label: "material Organization"},
	      {property: "materialPart", tag: "351", sfcodes: "3", label: "material Organization"},
	    ],
	    "cartography" => [
	      {property: "cartographicAscensionAndDeclination", tag: "255", sfcodes: "d", label: "cartographicAscensionAndDeclination"},
	      {property: "cartographicCoordinates", tag: "255", sfcodes: "c", label: "cartographicCoordinates"},
	      {property: "cartographicEquinox", tag: "255", sfcodes: "e", label: "cartographicEquinox"},
	      {property: "cartographicExclusionGRing", tag: "255", sfcodes: "g", label: "CartographicExclusionGRing"},
	      {property: "cartographicOuterGRing", tag: "255", sfcodes: "f", label: "cartographicOuterGRing"},
	      {property: "cartographicProjection", tag: "255", sfcodes: "b", label: "cartographicProjection"},
	      {property: "cartographicScale", tag: "034", sfcodes: "", label: "cartographicScale"},
	      {property: "cartographicScale", tag: "255", sfcodes: "a", label: "cartographicScale"},
	    ],
	    "classification" => [
	      {property: "classificationAssigner", tag: "083", sfcodes: "", label: "various orgs assiger"},
	      {property: "classificationEdition", tag: "082", sfcodes: "", label: "classificationEdition"},
	      {property: "classificationEdition", tag: "083", sfcodes: "", label: "classificationEdition"},
	      {property: "classificationSpanEnd", tag: "083", sfcodes: "c", label: "classification span end for class number"},
	      {property: "classificationTable", tag: "083", sfcodes: "z", label: "DDC table"},
	      {property: "classificationTableSeq", tag: "083", sfcodes: "y", label: "DDC table sequence number"},
	    ],
	    "contentcategory" => [
	      {property: "contentCategory", tag: "130", sfcodes: "h", label: "Nature of content"},
	      {property: "contentCategory", tag: "240", sfcodes: "h", label: "Nature of content"},
	      {property: "contentCategory", tag: "243", sfcodes: "h", label: "Nature of content"},
	      {property: "contentCategory", tag: "245", sfcodes: "k", label: "Nature of content"},
	      {property: "contentCategory", tag: "513", sfcodes: "a", label: "Nature of content"},
	      {property: "contentCategory", tag: "516", sfcodes: "a", label: "Nature of content"},
	      {property: "contentCategory", tag: "700", sfcodes: "h", label: "Nature of content"},
	      {property: "contentCategory", tag: "710", sfcodes: "h", label: "Nature of content"},
	      {property: "contentCategory", tag: "711", sfcodes: "h", label: "Nature of content"},
	      {property: "contentCategory", tag: "730", sfcodes: "h", label: "Nature of content"},
	    ],
	    "event" => [
	      {property: "eventDate", tag: "518", sfcodes: "d", label: "Event Date"},
	    ],
	    "findingAid" => [
	      {property: "findingAidNote", tag: "555", sfcodes: "3abc", label: "Cumulative Index/Finding Aids Note "},
	    ],
	    "helditem" => [
	       {property: "custodialHistory", tag: "561", sfcodes: "a", label: "Copy specific custodial history"},
	    ],
	    "instance" => [
	      {property: "$2", tag: "024", sfcodes: "a", ind1: "7", group: "identifiers", label: "contents of $2"},
	      {property: "accessCondition", tag: "506", label: "Restrictions on Access Note"},
	      {property: "aspectRatio", tag: "345", sfcodes: "a", label: "Aspect Ratio"},
	      {property: "coden", tag: "030", sfcodes: "a", group: "identifiers", label: "CODEN"},
	      {property: "contentsNote", tag: "505", sfcodes: "agrtu", ind2: " ", label: "Formatted Contents Note"},
	      {property: "copyrightDate", tag: "264", sfcodes: "c", ind2: "4", label: "Copyright Date"},
	      {property: "creditsNote", tag: "508", startwith: "Credits: ", label: "Creation/Production Credits Note "},
	      {property: "dimensions", tag: "300", sfcodes: "c", label: "Physical Size"},
	      {property: "ean", tag: "024", sfcodes: "a,z,d", ind1: "3", group: "identifiers", comment: "(sep by -)", label: "International Article Identifier (EAN)"},
	      {property: "edition", tag: "250", sfcodes: "a", label: "Edition"},
	      {property: "editionResponsibility", tag: "250", sfcodes: "b", label: "Edition Responsibility"},
	      {property: "extent", tag: "300", sfcodes: "af", label: "Physical Description"},
	      {property: "fingerprint", tag: "026", sfcodes: "e", group: "identifiers", label: "fingerprint identifier"},
	      {property: "formDesignation", tag: "245", sfcodes: "h", label: "Form Designation"},
	      {property: "formDesignation", tag: "245", sfcodes: "k", label: "Form Designation"},
	      {property: "graphicScaleNote", tag: "507", sfcodes: "a", label: "Scale Note for Graphic Material"},
	      {property: "illustrationNote", tag: "300", sfcodes: "b", label: "Illustrative content note"},
	      {property: "immediateAcquisition", tag: "541", sfcodes: "cad", label: "Immediate Source of Acquisition Note"},
	      {property: "ismn", tag: "024", sfcodes: "a", ind1: "2", group: "identifiers", label: "International Standard Music Number"},
	      {property: "isrc", tag: "024", sfcodes: "a", ind1: "0", group: "identifiers", label: "International Standard Recording Code"},
	      {property: "issn", tag: "022", sfcodes: "a", group: "identifiers", uri: "http://issn.example.org/", label: "International Standard Serial Number"},
	      {property: "languageNote", tag: "546", sfcodes: "3a", label: "Language Note"},
	      {property: "lccn", tag: "010", sfcodes: "a", uri: "http://id.loc.gov/authorities/test/identifiers/lccn/", group: "identifiers", label: "Library of Congress Control Number"},
	      {property: "lcOverseasAcq", tag: "025", sfcodes: "a", group: "identifiers", label: "Library of Congress Overseas Acquisition Program number"},
	      {property: "legalDeposit", tag: "017", sfcodes: "a", group: "identifiers", label: "copyright or legal deposit number"},
	      {property: "matrixNumber", tag: "028", sfcodes: "a", ind1: "1", group: "identifiers", label: "sound recording publisher matrix master number"},
	      {property: "musicPlate", tag: "028", sfcodes: "a", ind1: "2", group: "identifiers", label: "music publication number assigned by publisher"},
	      {property: "musicPublisherNumber", tag: "028", sfcodes: "a", ind1: "3", group: "identifiers", label: "other publisher number for music"},
	      {property: "nban", tag: "016", sfcodes: "a", group: "identifiers", label: "National bibliography agency control number"},
	      {property: "nbn", tag: "015", sfcodes: "a", group: "identifiers", label: "National Bibliography Number"},
	      {property: "notation", tag: "546", sfcodes: "b", label: "Language Notation(script)"},
	      {property: "note", tag: "500", sfcodes: "3a", label: "General Note"},
	      {property: "performerNote", tag: "511", startwith: "Cast: ", label: "Participant or Performer Note "},
	      {property: "philatelicDataNote", tag: "258", sfcodes: "ab", label: "Philatelic data note"},
	      {property: "postalRegistration", tag: "032", sfcodes: "a", group: "identifiers", label: "postal registration number"},
	      {property: "preferredCitation", tag: "524", label: "Preferred Citation of Described Materials Note"},
	      {property: "providerStatement", tag: "260", sfcodes: "abc", label: "Provider statement"},
	      {property: "publisherNumber", tag: "028", sfcodes: "a", ind1: "5", group: "identifiers", label: "other publisher assigned number"},
	      {property: "reportNumber", tag: "088", sfcodes: "a", group: "identifiers", label: "technical report number"},
	      {property: "responsibilityStatement", tag: "245", sfcodes: "c", label: "responsibility Statement"},
	      {property: "sici", tag: "024", sfcodes: "a", ind1: "4", group: "identifiers", label: "Serial Item and Contribution Identifier"},
	      {property: "stockNumber", tag: "037", sfcodes: "a", group: "identifiers", label: "stock number for acquisition"},
	      {property: "strn", tag: "027", sfcodes: "a", group: "identifiers", label: "Standard Technical Report Number"},
	      {property: "studyNumber", tag: "036", sfcodes: "a", group: "identifiers", label: "original study number assigned by the producer of a computer file"},
	      {property: "systemNumber", tag: "035", sfcodes: "a", group: "identifiers", uri: "http://www.worldcat.org/oclc/", label: "system control number"},
	      {property: "titleStatement", tag: "245", sfcodes: "ab", label: "title Statement"},
	      {property: "upc", tag: "024", sfcodes: "a", ind1: "1", group: "identifiers", label: "Universal Product Code"},
	      {property: "videorecordingNumber", tag: "028", sfcodes: "a", ind1: "4", group: "identifiers", label: "publisher assigned videorecording number"},
	    ],
	    "specialinstnc" => [
	      {property: "carrierCategory", tag: "338", sfcodes: "a", uri: "http://id.loc.gov/vocabulary/carriers/", label: "Physical Description"},
	      {property: "carrierCategory", tag: "338", sfcodes: "b", uri: "http://id.loc.gov/vocabulary/carriers/", label: "Physical Description"},
	      {property: "mediaCategory", tag: "337", sfcodes: "a", uri: "http://id.loc.gov/vocabulary/mediaCategory/", label: "Media Category"},
	      {property: "mediaCategory", tag: "337", sfcodes: "b", uri: "http://id.loc.gov/vocabulary/mediaCategory/", label: "Media Category"},
	    ],
	    "title" => [
	      {property: "partNumber", tag: "130", sfcodes: "n", label: "part number"},
	      {property: "partNumber", tag: "240", sfcodes: "n", label: "part number"},
	      {property: "partNumber", tag: "245", sfcodes: "n", label: "part number"},
	      {property: "partNumber", tag: "246", sfcodes: "n", label: "part number"},
	      {property: "partNumber", tag: "247", sfcodes: "n", label: "part number"},
	      {property: "partTitle", tag: "130", sfcodes: "p", label: "part title"},
	      {property: "partTitle", tag: "240", sfcodes: "p", label: "part title"},
	      {property: "partTitle", tag: "242", sfcodes: "p", label: "part title"},
	      {property: "partTitle", tag: "245", sfcodes: "p", label: "part title"},
	      {property: "partTitle", tag: "246", sfcodes: "p", label: "part title"},
	      {property: "partTitle", tag: "247", sfcodes: "p", label: "part title"},
	      {property: "partTitle", tag: "730", sfcodes: "p", label: "part title"},
	      {property: "subtitle", tag: "245", sfcodes: "b", label: "subtitle "},
	      {property: "subtitle", tag: "246", sfcodes: "b", label: "subtitle"},
	      {property: "subtitle", tag: "247", sfcodes: "b", label: "subtitle"},
	      {property: "titleAttribute", tag: "130", sfcodes: "g", label: "title attributes"},
	      {property: "titleAttribute", tag: "240", sfcodes: "g", label: "Miscellaneous "},
	      {property: "titleAttribute", tag: "240", sfcodes: "o", label: "arrangement"},
	      {property: "titleQualifier", tag: "210", sfcodes: "b", label: "title qualifier"},
	      {property: "titleQualifier", tag: "222", sfcodes: "b", label: "title qualifier"},
	      {property: "titleSource", tag: "210", sfcodes: "2", label: "title source"},
	      {property: "titleValue", tag: "130", sfcodes: "a", label: "title itself"},
	      {property: "titleValue", tag: "210", sfcodes: "a", label: "title itself"},
	      {property: "titleValue", tag: "222", sfcodes: "a", label: "title itself"},
	      {property: "titleValue", tag: "240", sfcodes: "a", label: "title itself"},
	      {property: "titleValue", tag: "242", sfcodes: "a", label: "title itself"},
	      {property: "titleValue", tag: "245", sfcodes: "a", label: "title itself"},
	      {property: "titleValue", tag: "246", sfcodes: "a", label: "title itself"},
	      {property: "titleValue", tag: "247", sfcodes: "a", label: "title itself"},
	      {property: "titleVariationDate", tag: "246", sfcodes: "f", label: "title variation date"},
	      {property: "titleVariationDate", tag: "247", sfcodes: "f", label: "title variation date"},
	    ],
	    "work" => [
	      {property: "awardNote", tag: "586", sfcodes: "3a", label: "Awards Note"},
	      {property: "dissertationDegree", tag: "502", sfcodes: "b", label: "Dissertation Note"},
	      {property: "dissertationNote", tag: "502", sfcodes: "a", label: "Dissertation Note"},
	      {property: "dissertationYear", tag: "502", sfcodes: "d", label: "Dissertation Note"},
	      {property: "duration", tag: "306", sfcodes: "a", label: "Playing time"},
	      {property: "formDesignation", tag: "130", sfcodes: "k", label: "Form subheading from title"},
	      {property: "formDesignation", tag: "240", sfcodes: "k", label: "Form subheading from title"},
	      {property: "formDesignation", tag: "730", sfcodes: "k", label: "Form Designation"},
	      {property: "frequencyNote", tag: "310", sfcodes: "ab", label: "Issue frequency"},
	      {property: "frequencyNote", tag: "321", sfcodes: "ab", label: "Issue frequency"},
	      {property: "geographicCoverageNote", tag: "522", label: "Geographic Coverage Note"},
	      {property: "issnL", tag: "022", sfcodes: "l", group: "identifiers", uri: "http://issn.example.org/", label: "linking International Standard Serial Number"},
	      {property: "legalDate", tag: "130", sfcodes: "d", label: "Legal Date"},
	      {property: "legalDate", tag: "730", sfcodes: "d", label: "Legal Date"},
	      {property: "musicKey", tag: "130", sfcodes: "r", label: "Key "},
	      {property: "musicKey", tag: "240", sfcodes: "r", label: "Key "},
	      {property: "musicKey", tag: "384", sfcodes: "a", label: "Key "},
	      {property: "musicMediumNote", tag: "130", sfcodes: "m", label: "Music medium note "},
	      {property: "musicMediumNote", tag: "240", sfcodes: "m", label: "Music medium note "},
	      {property: "musicMediumNote", tag: "243", sfcodes: "m", label: "Music medium note "},
	      {property: "musicMediumNote", tag: "382", sfcodes: "adp", label: "Music medium note "},
	      {property: "musicMediumNote", tag: "730", sfcodes: "m", label: "Music medium note "},
	      {property: "musicNumber", tag: "130", sfcodes: "n", label: "Music Number"},
	      {property: "musicNumber", tag: "730", sfcodes: "n", label: "Music Number"},
	      {property: "musicVersion", tag: "130", sfcodes: "o", label: "Music Version"},
	      {property: "musicVersion", tag: "130", sfcodes: "s", label: "version"},
	      {property: "musicVersion", tag: "240", sfcodes: "o", label: "Music Version"},
	      {property: "musicVersion", tag: "240", sfcodes: "s", label: "version"},
	      {property: "note", tag: "500", sfcodes: "3a", label: "General Note"},
	      {property: "originDate", tag: "046", sfcodes: "kl", stringjoin: "-", label: "Date of origin"},
	      {property: "originDate", tag: "130", sfcodes: "f", label: "Date of origin"},
	      {property: "originDate", tag: "130", sfcodes: "f", label: "Legal Date"},
	      {property: "originDate", tag: "730", sfcodes: "f", label: "Date of origin"},
	      {property: "supplementaryContentNote", tag: "525", sfcodes: "a", label: "Supplement Note"},
	      {property: "temporalCoverageNote", tag: "513", sfcodes: "b", label: "Period Covered Note"},
	      {property: "treatySignator", tag: "710", sfcodes: "g", label: "treaty Signator"},
	    ]
	  }.freeze

		TARGET_AUDIENCES = {
	    "a" => "Pre",
	    "b" => "Pri",
	    "c" => "Pra",
	    "d" => "Ado",
	    "e" => "Adu",
	    "f" => "Spe",
	    "g" => "Gen",
	    "j" => "Juv",
	  }.freeze

	  FORMS_OF_ITEMS = {
		  "a" => {form: "Microfilm", rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
		  "b" => {form: "Microfiche", rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
		  "c" => {form: "Microopaque", rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
		  "d" => {form: "Large print", rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
		  "f" => {form: "Braille", rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
		  "o" => {form: "Online", rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial SoftwareApplication)},
		  "q" => {form: "Direct electronic", rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial SoftwareApplication)},
		  "r" => {form: "Regular print reproduction", rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
		  "s" => {form: "Electronic", rtype: %w(Text Book NotatedMusic MusicRecording MixedMaterial)},
	  }.freeze

	  SUBJECTS_TYPES = {
	  	"600" => "Person",
			"610" => "Organization",
			"611" => "Meeting",
			"648" => "Temporal",
			"650" => "Topic",
			"651" => "Place",
			"654" => "Topic",
			"655" => "Topic",
			"656" => "Topic",
			"657" => "Topic",
			"658" => "Topic",
			"662" => "Place",
			"653" => "Topic",
			"751" => "Place",
			"752" => "Topic",
	  }

	  CLASSES = {
	  	"work" => [
			    {name: "classificationNumber", label: "classification number", marc: "050,051,055,060,061,070,071,080,082,083,084,086--/a", tag: "(050|051|055|060|061|070|071|080|082|083|084|086)", sfcodes: "a"},
			    {name: "classificationSpanEnd", label: "classification span end for class number", marc: "083--/c", tag: "083", sfcodes: "c"},
			    {name: "classificationTableSeq", label: "DDC table sequence number", marc: "083--/y", tag: "083", sfcodes: "y"},
			    {name: "classificationTable", label: "DDC table", marc: "083--/z", tag: "083", sfcodes: "z"},
			    {name: "classificationScheme", label: "type of classification", marc: "086--/2", tag: "086", sfcodes: "2"},
			    {name: "classificationEdition", label: "edition of class scheme", marc: "If 080,082,083 1- then 'abridged'", tag: "(080|082|083)", ind1: "1"},
			    {name: "classificationEdition", label: "edition of class scheme", marc: "If 080,082,083 1- then 'full'", tag: "080|082|083", ind1: "0"},
			    {name: "classificationAssigner", label: "institution assigning classification", marc: "if 070,071 then NAL", tag: "(050|051|060|061|070|071|082|083|084)"},

			    {name: "classificationDesignation", label: "Part of class scheme used", marc: "if 082,083 --/m=a then'standard', m=b then 'optional'", tag: "(082|083)" , sfcodes: "m=a then'standard', m=b then 'optional'"},
			    {name: "classificationStatus", label: "status of classification", marc: "if 086/z then status=canceled/invalid", tag: "if " , sfcodes: "z then status=canceled/invalid"},
			    {name: "classificationLcc", label: "LCC Classification", marc: "050,051,055,070,071--/a", tag: "(050|051|052|055|070|071)", sfcodes: "a", level: "property"},
			    {name: "classificationNlm", label: "NLM Classification", marc: "060,061--/a", tag: "(060|061)", sfcodes: "a", level: "property"},
			    {name: "classification", label: "classification", marc: "084,086--/a", tag: "(084|086)", ind1: " ", sfcodes: "a", level: "property"},
			    {name: "classificationDdc", label: "DDC Classification", marc: "083--/a'hyphen'c", tag: "083", sfcodes: "a'hyphen'c", level: "property"},
			    {name: "classificationDdc", label: "DDC Classification", marc: "082--/a", tag: "082", sfcodes: "a", level: "property"},
			    {name: "classificationUdc", label: "UDC Classification", marc: "080--/a+c", tag: "080", sfcodes: "a+c", level: "property"},
	  		],
	  		"Holding" => [
	    			{name: "classificationItem", label: "classification item number", marc: "050|051,055,060,061,070,071,080,082,083,084,086--/b", tag: "(050|051|055|060|061|070|071|080|082|083|084|086)", sfcodes: "b"},
	    	]
	  }.freeze

		VALID_LCC = [
			"DAW","DJK","KBM","KBP","KBR","KBU","KDC","KDE","KDG","KDK","KDZ","KEA","KEB",
			"KEM","KEN","KEO","KEP","KEQ","KES","KEY","KEZ","KFA","KFC","KFD","KFF","KFG",
			"KFH","KFI","KFK","KFL","KFM","KFN","KFO","KFP","KFR","KFS","KFT","KFU","KFV",
			"KFW","KFX","KFZ","KGA","KGB","KGC","KGD","KGE","KGF","KGG","KGH","KGJ","KGK",
			"KGL","KGM","KGN","KGP","KGQ","KGR","KGS","KGT","KGU","KGV","KGW","KGX","KGY",
			"KGZ","KHA","KHC","KHD","KHF","KHH","KHK","KHL","KHM","KHN","KHP","KHQ","KHS",
			"KHU","KHW","KJA","KJC","KJE","KJG","KJH","KJJ","KJK","KJM","KJN","KJP","KJR",
			"KJS","KJT","KJV","KJW","KKA","KKB","KKC","KKE","KKF","KKG","KKH","KKI","KKJ",
			"KKK","KKL","KKM","KKN","KKP","KKQ","KKR","KKS","KKT","KKV","KKW","KKX","KKY",
			"KKZ","KLA","KLB","KLD","KLE","KLF","KLH","KLM","KLN","KLP","KLQ","KLR","KLS",
			"KLT","KLV","KLW","KMC","KME","KMF","KMG","KMH","KMJ","KMK","KML","KMM","KMN",
			"KMP","KMQ","KMS","KMT","KMU","KMV","KMX","KMY","KNC","KNE","KNF","KNG","KNH",
			"KNK","KNL","KNM","KNN","KNP","KNQ","KNR","KNS","KNT","KNU","KNV","KNW","KNX",
			"KNY","KPA","KPC","KPE","KPF","KPG","KPH","KPJ","KPK","KPL","KPM","KPP","KPS",
			"KPT","KPV","KPW","KQC","KQE","KQG","KQH","KQJ","KQK","KQM","KQP","KQT","KQV",
			"KQW","KQX","KRB","KRC","KRE","KRG","KRK","KRL","KRM","KRN","KRP","KRR","KRS",
			"KRU","KRV","KRW","KRX","KRY","KSA","KSC","KSE","KSG","KSH","KSK","KSL","KSN",
			"KSP","KSR","KSS","KST","KSU","KSV","KSW","KSX","KSY","KSZ","KTA","KTC","KTD",
			"KTE","KTF","KTG","KTH","KTJ","KTK","KTL","KTN","KTQ","KTR","KTT","KTU","KTV",
			"KTW","KTX","KTY","KTZ","KUA","KUB","KUC","KUD","KUE","KUF","KUG","KUH","KUN",
			"KUQ","KVB","KVC","KVE","KVH","KVL","KVM","KVN","KVP","KVQ","KVR","KVS","KVU",
			"KVW","KWA","KWC","KWE","KWG","KWH","KWL","KWP","KWQ","KWR","KWT","KWW","KWX",
			"KZA","KZD","AC","AE","AG","AI","AM","AN","AP","AS","AY","AZ","BC","BD","BF",
			"BH","BJ","BL","BM","BP","BQ","BR","BS","BT","BV","BX","CB","CC","CD","CE","CJ",
			"CN","CR","CS","CT","DA","DB","DC","DD","DE","DF","DG","DH","DJ","DK","DL","DP",
			"DQ","DR","DS","DT","DU","DX","GA","GB","GC","GE","GF","GN","GR","GT","GV","HA",
			"HB","HC","HD","HE","HF","HG","HJ","HM","HN","HQ","HS","HT","HV","HX","JA","JC",
			"JF","JJ","JK","JL","JN","JQ","JS","JV","JX","JZ","KB","KD","KE","KF","KG","KH",
			"KJ","KK","KL","KM","KN","KP","KQ","KR","KS","KT","KU","KV","KW","KZ","LA","LB",
			"LC","LD","LE","LF","LG","LH","LJ","LT","ML","MT","NA","NB","NC","ND","NE","NK",
			"NX","PA","PB","PC","PD","PE","PF","PG","PH","PJ","PK","PL","PM","PN","PQ","PR",
			"PS","PT","PZ","QA","QB","QC","QD","QE","QH","QK","QL","QM","QP","QR","RA","RB",
			"RC","RD","RE","RF","RG","RJ","RK","RL","RM","RS","RT","RV","RX","RZ","SB","SD",
			"SF","SH","SK","TA","TC","TD","TE","TF","TG","TH","TJ","TK","TL","TN","TP","TR",
			"TS","TT","TX","UA","UB","UC","UD","UE","UF","UG","UH","VA","VB","VC","VD","VE",
			"VF","VG","VK","VM","ZA","A","B","C","D","E","F","G","H","J","K","L","M","N",
			"P","Q","R","S","T","U","V","Z"].freeze

		RELATIONSHIPS = {
			'work' => [
				#{all_tags: "(400|410|411|430|440|490|510|533|534|630|700|710|711|720|730|740|760|762|765|767|770|772|773|774|775|777|780|785|787|800|810|811|830)"},
				{tag: "(700|710|711|720)", ind2: "2", property: "hasPart", label: "isIncludedIn"},
				{tag: "(700|710|711|720)", ind2: "( |0|1)", property: "relatedResource", label: "relatedWork"},
				{tag: "740", ind2: " ", property: "relatedWork", label: "relatedWork"},
				{tag: "740", property: "partOf", ind2: "2", label: "hasPart"},
				{tag: "760", property: "subseriesOf", label: "hasParts"},
				{tag: "762", property: "subseries", label: "hasParts"},
				{tag: "765", property: "translationOf", label: "hasTranslation"},
				{tag: "767", property: "translation", label: "translationOf"},
				{tag: "770", property: "supplement", label: "supplement"},
				{tag: "772", ind2: " ", property: "supplementTo", label: "isSupplemented"},
				{tag: "773", property: "partOf", label: "hasConstituent"},
				{tag: "774", property: "hasPart", label: "has Part"},
				{tag: "775", property: "otherEdition" , label: "hasOtherEdition"},
				{tag: "777", property: "issuedWith", label: "issuedWith"},
				{tag: "780", ind2: "0", property: "continues", label: "continuationOf"},
				{tag: "780", ind2: "1", property: "continuesInPart", label: "partiallyContinuedBy"},
				{tag: "780", ind2: "2", property: "supersedes", label: "continuationOf"},
				{tag: "780", ind2: "3", property: "supersedesInPartBy", label: "partiallyContinuedBy"},
				{tag: "780", ind2: "4", property: "unionOf", label: "preceding"},
				{tag: "780", ind2: "5", property: "absorbed", label: "isAbsorbedBy"},
				{tag: "780", ind2: "6", property: "absorbedInPartBy", label: "isPartlyAbsorbedBy"},
				{tag: "780", ind2: "7", property: "separatedFrom", label: "formerlyIncluded"},
				{tag: "785", ind2: "0" , property: "continuedBy", label: "continues"},
				{tag: "785", ind2: "1", property: "continuedInPartBy", label: "partiallyContinues"},
				{tag: "785", ind2: "2" , property: "supersededBy", label: "continues"},
				{tag: "785", ind2: "3", property: "supersededInPartBy", label: "partiallyContinues"},
				{tag: "785", ind2: "4", property: "absorbedBy", label: "absorbs"},
				{tag: "785", ind2: "5" , property: "absorbedInPartBy", label: "partiallyAbsorbs"},
				{tag: "785", ind2: "6" , property: "splitInto", label: "splitFrom"},
				{tag: "785", ind2: "7" , property: "mergedToForm", label: "mergedFrom"},
				{tag: "785", ind2: "8" , property: "continuedBy", label: "formerlyNamed"},
				{tag: "786", property: "dataSource"},
				{tag: "533", property: "reproduction"},
				{tag: "534", property: "originalVersion"},
				{tag: "787", property: "relatedResource", label: "relatedItem"},
				{tag: "630" , property: "subject", label: "isSubjectOf"},
				{tag: "(400|410|411|430|440|490|800|810|811|830)", property: "series", label: "hasParts"},
				{tag: "730", property: "relatedWork" , ind2: " ", label: "relatedItem"},
				{tag: "730", property: "hasPart", ind2: "2" , label: "partOf"},
			],
			'instance' => [
				#{all_tags: "(776|530)"}
				],
		}.freeze

		INSTANCE_TYPES = {
			'cf007' => {
				"c" => "Electronic",
				"f" => "Tactile",
			},
			'leader6' => {
				"d" => "Manuscript",
				"f" => "Manuscript",
				"t" => "Manuscript",
			},
			'leader7' => {
				"b" => "Serial",
				"c" => "Collection",
				"d" => "Collection",
				"i" => "Integrating",
				"s" => "Serial",
			},
			'leader8' => {
				"a" => "Archival",
			},
			'sf336a' => {
				"tactile text" => "Tactile",
			},
			'sf336b' => {
				"tct" => "Tactile",
			},
		}.freeze

		MEDIA_TYPES = {
		  "s" => "audio",
		  "c" => "computer",
		  "h" => "microform",
		  "p" => "microscopic",
		  "g" => "projected",
		  "e" => "stereographic",
		  "n" => "unmediated",
		  "v" => "video",
		  "x" => "other",
		  "z" => "unspecified",
		}.freeze

		MEDIA_TYPES_CODE = {}
		MEDIA_TYPES.each do |key, value|
			MEDIA_TYPES_CODE[value] = key
		end
		MEDIA_TYPES_CODE.freeze

		CARRIERS = {
				"sg" => "audio cartridge",
				"se" => "audio cylinder",
				"sd" => "audio disc",
				"si" => "sound track reel",
				"sq" => "audio roll",
				"ss" => "audiocassette",
				"st" => "audiotape reel",
				"sz" => "other audio Carrier",
				"ck" => "computer card",
				"cb" => "computer chip cartridge",
				"cd" => "computer disc",
				"ce" => "computer disc cartridge",
				"ca" => "computer tape cartridge",
				"cf" => "computer tape cassette",
				"ch" => "computer tape reel",
				"cr" => "online resource",
				"cz" => "other computer carrier",
				"ha" => "aperture card",
				"he" => "microfiche",
				"hf" => "microfiche cassette",
				"hb" => "microfilm cartridge",
				"hc" => "microfilm cassette",
				"hd" => "microfilm reel",
				"hj" => "microfilm roll",
				"hh" => "microfilm slip",
				"hg" => "microopaque",
				"hz" => "other microform carrier",
				"pp" => "microscope slide",
				"pz" => "other microscopic carrier",
				"mc" => "film cartridge",
				"mf" => "film cassette",
				"mr" => "film reel",
				"mo" => "film roll",
				"gd" => "filmslip",
				"gf" => "filmstrip",
				"gc" => "filmstrip cartridge",
				"gt" => "overhead transparency",
				"gs" => "slide",
				"mz" => "other projected-image carrier",
				"eh" => "stereograph card",
				"es" => "stereograph disc",
				"ez" => "other stereographic Carrier",
				"no" => "card",
				"nn" => "flipchart",
				"na" => "roll",
				"nb" => "sheet",
				"nc" => "volume",
				"nr" => "object",
				"nz" => "other unmediated carrier",
				"vc" => "video cartridge",
				"vf" => "videocassette",
				"vd" => "videodisc",
				"vr" => "videotape reel",
				"vz" => "other video carrier",
				"zu" => "unspecified",
			}.freeze

		CARRIERS_CODE = {}
		CARRIERS.each do |key, value|
			CARRIERS_CODE[value] = key
		end
		CARRIERS_CODE.freeze

		CONTENT_TYPES = {
			"crd" => "cartographic dataset",
			"cri" => "cartographic image",
			"crm" => "cartographic moving image",
			"crt" => "cartographic tactile image",
			"crn" => "cartographic tactile three-dimensional form",
			"crf" => "cartographic three-dimensional form",
			"cod" => "computer dataset",
			"cop" => "computer program",
			"ntv" => "notated movement",
			"ntm" => "notated music",
			"prm" => "performed music",
			"snd" => "sounds",
			"spw" => "spoken word",
			"sti" => "still image",
			"tci" => "tactile image",
			"tcm" => "tactile notated music",
			"tcn" => "tactile notated movement",
			"tct" => "tactile text",
			"tcf" => "tactile three-dimensional form",
			"txt" => "text",
			"tdf" => "three-dimensional form",
			"tdm" => "three-dimensional moving image",
			"tdi" => "two-dimensional moving image",
			"xxx" => "other",
			"zzz" => "unspecified",
		}.freeze

		CONTENT_TYPES_CODE = {}
		CONTENT_TYPES.each do |key, value|
			CONTENT_TYPES_CODE[value] = key
		end
		CONTENT_TYPES_CODE.freeze

		# $related fields must have $t except 510 630,730,830, 767? 740 ($a is title)
		W2W_TARGET_TAGS = %w(400 410 411 430 440 490 510 533 534 630 700 710 711 720 730 740 760 762 765 767 770 772 773 774 775 777 780 785 787 800 810 811 830).freeze
		# Work to Work relationships
		# WorkA property WorkB : WorkB value WorkA
		W2W_RERATIONS = [
		 {tag: "700|710|711|720", ind2: "2", property: "hasPart", reverse: "isIncludedIn"},
		 {tag: "700|710|711|720", ind2: " |0|1", property: "relatedResource", reverse: "relatedWork"},
		 {tag: "740", ind2: " ", property: "relatedWork", reverse: "relatedWork"},
		 {tag: "740", property: "partOf", ind2: "2", reverse: "hasPart"},
		 {tag: "760", property: "subseriesOf", reverse: "hasParts"},
		 {tag: "762", property: "subseries", reverse: "hasParts"},
		 {tag: "765", property: "translationOf", reverse: "hasTranslation"},
		 {tag: "767", property: "translation", reverse: "translationOf"},
		 {tag: "770", property: "supplement", reverse: "supplement"},
		 {tag: "772", ind2: " ", property: "supplementTo", reverse: "isSupplemented"},
		 {tag: "773", property: "partOf", reverse: "hasConstituent"},
		 {tag: "774", property: "hasPart", reverse: "has Part"},
		 {tag: "775", property: "otherEdition" , reverse: "hasOtherEdition"},
		 {tag: "777", property: "issuedWith", reverse: "issuedWith"},
		 {tag: "780", ind2: "0", property: "continues", reverse: "continuationOf"},
		 {tag: "780", ind2: "1", property: "continuesInPart", reverse: "partiallyContinuedBy"},
		 {tag: "780", ind2: "2", property: "supersedes", reverse: "continuationOf"},
		 {tag: "780", ind2: "3", property: "supersedesInPartBy", reverse: "partiallyContinuedBy"},
		 {tag: "780", ind2: "4", property: "unionOf", reverse: "preceding"},
		 {tag: "780", ind2: "5", property: "absorbed", reverse: "isAbsorbedBy"},
		 {tag: "780", ind2: "6", property: "absorbedInPartBy", reverse: "isPartlyAbsorbedBy"},
		 {tag: "780", ind2: "7", property: "separatedFrom", reverse: "formerlyIncluded"},
		 {tag: "785", ind2: "0", property: "continuedBy", reverse: "continues"},
		 {tag: "785", ind2: "1", property: "continuedInPartBy", reverse: "partiallyContinues"},
		 {tag: "785", ind2: "2", property: "supersededBy", reverse: "continues"},
		 {tag: "785", ind2: "3", property: "supersededInPartBy", reverse: "partiallyContinues"},
		 {tag: "785", ind2: "4", property: "absorbedBy", reverse: "absorbs"},
		 {tag: "785", ind2: "5", property: "absorbedInPartBy", reverse: "partiallyAbsorbs"},
		 {tag: "785", ind2: "6", property: "splitInto", reverse: "splitFrom"},
		 {tag: "785", ind2: "7", property: "mergedToForm", reverse: "mergedFrom"},
		 {tag: "785", ind2: "8", property: "continuedBy", reverse: "formerlyNamed"},
		 {tag: "786", property: "dataSource", reverse: ""},
		 {tag: "533", property: "reproduction", reverse: ""},
		 {tag: "534", property: "originalVersion", reverse: ""},
		 {tag: "787", property: "relatedResource", reverse: "relatedItem"},
		 {tag: "630", property: "subject", reverse: "isSubjectOf"},
		 {tag: "400|410|411|430|440|490|800|810|811|830", property: "series", reverse: "hasParts"},
		 {tag: "730", property: "relatedWork", ind2: " ", reverse: "relatedItem"},
		 {tag: "730", property: "hasPart", ind2: "2" , reverse: "partOf"},
		].freeze

		# Instance to Work relationships (none!)
		I2I_TARGET_TAGS = %w(776 530).freeze
		I2I_RERATIONS = [
		 {tag: "776", property: "otherPhysicalFormat", reverse: "hasOtherPhysicalFormat"}
		].freeze

    attr_reader :graph

    def initialize(repository, record, baseuri=nil)
      @record = record
      record_id = @record['001'].value.strip
      record_id += '/' + @record['003'].value.strip.downcase.gsub(/[^a-z]/, '') if @record['003']
      @baseuri = baseuri ? baseuri : "http://id.loc.gov/resources/bibs/" + record_id
      @graph = RDF::Graph.new(RDF::URI.new(@baseuri), {data: repository})
      @num = 0
      parse
    end

		def parse
      #@baseuri += @record['001'].value
      work = RDF::URI.new(@baseuri)
			@graph << [work, RDF.type, BF.Work]
      generate_work_type(work)
      generate_alabel(work)
      # generate_alabels_work880(subject) 翻訳形のauthor+title 今のロジックでは難しい
      generate_dissertation(work)
      generate_uniform_title(work)
      generate_names(%w(100 110 111 700 710 711 720), work)
      generate_title(%w(243 245 247), 'work', work)
      generate_events(%w(033), work)
      @record.each do |field|
        generate_simple_property(field, "work", work)
      end
      generate_audience_521(work)
      generate_langs(work)
      generate_findaids(work)
      generate_abstract(work)
      generate_abstract_annotation(work)
      generate_audience(work)
      generate_genre(work)
      generate_cartography(work)
      generate_subjects(work)
      generate_gacs(work)
      generate_classes('work', work)    # generate_work_classes
      generate_identifiers('work', work)    # generate_work_identifiers
      generate_complex_notes(work)
      generate_related_works('work', work)   # generate_work_relates
      @graph << [work, BF.derivedFrom, RDF::URI.new(@baseuri)]
      generate_hashtable(work)
      generate_admin(work)
      generate_instances(work)
      @record.fields(%w(856 859)).each do |field|    # generate_instances_from856
        generate_bio_links(field, work)
      end
    end

		def generate_abstract(subject)
			@record.fields('520').each do |field|
				next if field['c'] || field['u']
				generate_simple_property(field, 'work', subject)
			end
		end

		def generate_abstract_annotation(subject)
			@record.fields('520').each do |field|
				next unless field['c'] || field['u']
				generate_abstract_annotation_graph(field, subject)
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

		def generate_audience(subject)
			audience = @record['008'].value[22]
			type008 = get_type_of_008
			if audience != ' ' && %w(BK CF MU VM).include?(type008) && TARGET_AUDIENCES[type008]
				@graph << [subject, BF.intendedAudience, RDF::URI.new("http://id.loc.gov/vocabulary/targetAudiences/#{TARGET_AUDIENCES[type008]}")]
			end
		end

		def get_type_of_008
			leader6 = @record.leader[6]
			leader7 = @record.leader[7]
			case leader6
			when 'a'
				case leader7
				when 'a', 'c', 'd', 'm'
					'BK'
				when 'b', 'i', 's'
				'	SE'
				else nil
				end
			when 't' then 'BK'
			when 'p' then 'MM'
			when 'm' then 'CF'
			when 'e', 'f', 's' then 'MP'
			when 'g', 'k', 'o', 'r' then 'VM'
			when 'c', 'd', 'i', 'j' then 'MU'
			else nil
			end
		end

		def generate_audience_521(subject)
			@record.fields('521') do |field|
				uri_audience = get_uri('audience')
				@graph << [subject, BF.intendedAudience, uri_audience]
				@graph << [uri_audience, RDF.type, BF.IntendedAudience]
				@graph << [uri_audience, BF.audience, field['a']]
				@graph << [uri_audience, BF.audienceAssigner, field['b']] if field['b']
			end
		end

		def generate_cartography(subject)
			@record.fields('255').each do |field|
				generate_simple_property(field, 'cartography', subject)
			end
		end

		def generate_classes(domain, subject)
			@record.fields(%w(060 061)).each do |field|
				field.each do |sf|
					next unless sf.code == 'a'
					classification = normalize_space(sf.value.split(' ')[0])
					@graph << [subject, BF.classificationNlm, RDF::URI.new("http://nlm.example.org/classification/#{classification}")]
				end
			end

			@record.fields('086').each do |field|
				next unless field['z']
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
			end

			@record.fields(%w(050 055 070 080 082 083 084 086)).each do |field|
				field.each do |sf|
					next unless sf.code == 'a'
					tag, ind1, ind2 = field.tag, field.indicator1, field.indicator2
					classification = sf.value
					if %w(050 055).include?(tag)
						classification = classification.sub(/(\s+|\.).+$/, '')
						classification = nil unless VALID_LCC.include?(classification.sub(/\d+/, ''))
					end
					if classification && (field.codes.size == 1 && field['a']) ||
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
					elsif classification
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
						 when '082' then 'ddc'
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
				CLASSES[domain].each do |h|
					next unless h[:level] == 'property' && h[:tag].include?(tag)
					return h[:name]
				end
			end
		end

		def generate_complex_notes(subject)
			@record.fields('505') do |field|
				next unless field.indicator2 == '0'
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
		end

		def generate_name_from_SOR(value, property, subject)
			value = normalize_space(value[3..-1]) if value.include?(' by')
			uri_agent = get_uri('agent')
			@graph << [subject, property, uri_agent]
		end

		def generate_dissertation(subject)
			@record.fields('502').each do |field|
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
		end

		# generate_events: event関連トリプルの作成
		#
		# params [Array] target_fields 作成対象のタグの配列
		# params [RDF::Resource] subject このトリプルのサブジェクト
		def generate_events(target_fields, subject)
			@record.fields(target_fields).each do |field|
				generate_event_graph(field, subject)
			end
		end

		def generate_event_graph(field, subject)
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

		def generate_findaids(subject)
			@record.fields('555').each do |field|
				if field['u']
					generate_find_aid_work(field, subject)
				else
					generate_simple_property(field, 'findingaid', subject)
				end
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

		def generate_gacs(subject)
			@record.fields('043').each do |field|
				if field['a']
					gac = normalize_space(field['a']).gsub(/[\-\+\$]/, '')
					@graph << [subject, BF.subject, RDF::URI.new("http://id.loc.gov/vocabulary/geographicAreas/#{gac}")]
				end
			end
		end

		def generate_genre(subject)
			genre = @record['008'].value[23]
			## おそらく BF.Categoryでトリプルを作成するようになる
			if FORMS_OF_ITEMS[genre]
				@graph << [subject, BF.genre, FORMS_OF_ITEMS[genre]]
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
			@record.each do |field|
				next unless %w(050 055 060 070 080 082 084).include?(field.tag)
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

			d852 = []
			@record.fields('852').each do |field|
				field.values_of('a').each do |value|
					d852 << [BF.heldBy, value]
				end
				field.values_of('b').each do |value|
					d852 << [BF.subLocation, value]
				end

				shelf = field.subfields.select{|s| %w(k h l i m t).include?(s.code)}.map{|s| s.value}.join(' ')
				d852 << [BF.shelfMark, shelf]
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
				d852 << [BF.copyNote, note]
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
			generate_title(%w(245 246 247 222 242 210), 'instance', uri_instance)
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
			cf007 = @record['007'] ? @record['007'][0] : nil
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
			@record.each do |field|
				if field.tag.start_with?('5') && !(%w(500 502 504 505 506 507 508 511 513 518 520 522 524 525 541 546 555).include?(field.tag))
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
				lang_41 << field.values_of('a')
			end
			lang_041 = lang_041.flatten.uniq

			lang_041.each do |lang|
				@graph << [subject, BF.language, RDF::URI.new("http://id.loc.gov/vocabulary/languages/#{lang}")]
			end
			if lang_008 != '   ' && lang_008 != '|||' && (lang_041.length == 0 || lang_008 != lang_041[0])
				@graph << [subject, BF.language, RDF::URI.new("http://id.loc.gov/vocabulary/languages/#{lang_008}")]
			end

			@record.fields('041').each do |field|
				%w(b d e f g h j k m n).each do |code|
					sbfields = field.subfield.select{|s| s.code == code}
					uri_lang = get_uri('language')
					@graph << [subject, BF.language, uri_lang]
					@graph << [uri_lang, RDF.type, BF.Language]
					@graph << [uri_lang, BF.languageOfPartUri, code]
					sbfields.each do |sbf|
						@graph << [uri_lang, BF.languageOfPartUri, RDF:URI.new("http://id.loc.gov/vocabulary/languages/#{sbf.value}")]
					end
					@graph << [uri_lang, BF.languageSource, field['2']] if field['2']
				end
			end
		end

		def generate_names(tags, subject)
	    @record.fields(tags).each do |field|
				generate_name_graph(field, subject)
			end
		end

		def generate_name_graph(field, subject)
			resource_role = get_resource_role(field)
			bf_class = get_bf_class(field)
			label = get_label(field)

			uri_name = get_uri(bf_class.to_s['http://bibframe.org/vocab/'.length..-1].downcase)
			@graph << [subject, resource_role, uri_name]
			@graph << [uri_name, RDF.type, bf_class]
			@graph << [uri_name, BF.label, label]
			@graph << [uri_name, BF.authorizedAccessPoint, label] unless field.tag == '534'

			generate_880_label(field, "name", uri_name) if field['6']
			## TODO これは必要か（mads vocabularyを使用）
			generate_element_list(label, uri_name) unless field.tag == '534'
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

		def generate_related_works(domain, subject)
			if @record.include_member?(%w(730 740 772))
				@record.fields(%w(730 740 772)).each do |f|
					RELATIONSHIPS[domain].select{|h| h[:tag].include?(f.tag) && h[:ind2].include?(f.indicator2)}.map{|h| h[:property]}.each do |property|
						generate_related_works_graph(f, property, subject)
					end
				end
			elsif @record.include_member?(%w(533))
				@record.fields('533').each do |f|
					RELATIONSHIPS[domain].select{|h| h[:tag].include?(f.tag)}.map{|h| h[:property]}.each do |property|
						generate_related_reporoduction(f, property, subject)
					end
				end
			elsif @record.include_member?(%w(700 710 711 720))
				@record.fields(%w(700 710 711 720)).each do |f|
					next unless f['t'] && f.indicator2 == '2'
					RELATIONSHIPS[domain].select{|h| h[:tag].include?(f.tag) && h[:ind2].include?(f.indicator2)}.map{|h| h[:property]}.each do |property|
						generate_related_works_graph(f, property, subject)
					end
				end
			elsif @record.include_member?(%w(780 785))
				@record.fields(%w(780 785)).each do |f|
					RELATIONSHIPS[domain].select{|h| h[:tag].include?(f.tag) && h[:ind2].include?(f.indicator2)}.map{|h| h[:property]}.each do |property|
						generate_related_works_graph(f, property, subject)
					end
				end
			elsif @record.include_member?(%w(490 630 830))
				@record.fields(%w(490 630 830)).each do |f|
					next unless f['a']
					RELATIONSHIPS[domain].select{|h| h[:tag].include?(f.tag)}.map{|h| h[:property]}.each do |property|
						generate_related_works_graph(f, property, subject)
					end
				end
			elsif @record.include_member?(%w(534))
				@record.fields(%w(534)).each do |f|
					next unless f['f']
					RELATIONSHIPS[domain].select{|h| h[:tag].include?(f.tag)}.map{|h| h[:property]}.each do |property|
						generate_related_works_graph(f, property, subject)
					end
				end
			else
				@record.each do |f|
					next if MARC::ControlField.control_tag?(f.tag)
					next unless f['t'] || f['s']
					RELATIONSHIPS[domain].select{|h| h[:tag].include?(f.tag)}.map{|h| h[:property]}.each do |property|
						generate_related_works_graph(f, property, subject)
					end
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

		def generate_subjects(subject)
			@record.each do |field|
				if SUBJECTS_TYPES[field.tag]
					generate_subject_graph(field, SUBJECTS_TYPES[field.tag], subject)
				end
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
		# params [Array] target_fields 作成対象のタグの配列
		# params [RDF::Resource] subject このトリプルのサブジェクト
		def generate_title(target_fields, domain, subject)
			@record.fields(target_fields).each do |field|
				generate_title_graph(field, domain, subject)
			end
		end

		def generate_title_graph(field, domain, subject)
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
			if %w(242 246 247).include?(field.tag)
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
			else
				nil
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

	  def get_types
	    types = []
	    leader6 = @record.leader[6]
	    types << RESOURCE_TYPES[:leader][leader6] if RESOURCE_TYPES[:leader].has_key?(leader6)
	    if @record['007']
	      @records.fields('007').each do |cf007|
	        code = cf007.value[0]
	        types << RESOURCE_TYPES[:cf007][code] if RESOURCE_TYPES[:cf007].has_key?(code)
	      end
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
	          types << RESOURCE_TYPES[:sf337a][value] if code == 'a' && RESOURCE_TYPES[:sf337a].has_key?(value)
	          types << RESOURCE_TYPES[:sf337b][value] if code == 'b' && RESOURCE_TYPES[:sf337b].has_key?(value)
	        end
	      end
	    end
	    types.flatten.uniq
	  end

	  def generate_work_type(subject)
	    get_types.each do |type|
	      @graph << [subject, RDF.type, BF[type]]
	    end
	  end


		def related_works(subject, type)
			relations   = type == 'work' ? W2W_RELATIONS   : I2I_RELATIONS
			#target_tags = type == 'work' ? W2W_TARGET_TAGS : I2I_TARGET_TAGS

			relation.each do |relation|
				fields = @record.fields(relation[:tag].split('|'))
				fields.each do |field|
					if relation[:ind2]
						ind2s = relation[:ind2].split('|')
						next unless ind2s.includs? field.ind2
					end
					tag = field.tag
					case tag
					when '730', '740', '772'
						generate_related_work(field, relation, subject)
					when '533'
						generate_related_reporoduction(field, relation, subject)
					when '700', '710', '711', '720'
						if field['t']
							targets = @record.fields("700|710|711|720|780|785".split('|'))
							targets.each do |target|
								next unless target.indicator2 == '2' && relations[:idn2] == '2'
								target.each do |sbfield|
									next unless sbfield.code == 't'
									generate_related_work(sbfield, relation, subject)
								end
							end
						end
					when '780', '785'
						targets = @record.fields("700|710|711|720|780|785".split('|'))
						targets.each do |target|
							next unless target.indicator2 == '2' && relations[:ind2] == '2'
							generate_related_work(field, relation, subject)
						end
					when '490', '630', '830'
						field.each do |sbfield|
							next unless sbfield.code == 'a'
							enerate_related_work(sbfield, relation, subject)
						end
					when '534'
						field.each do |sbfield|
							next unless sbfield.code == 'f'
							enerate_related_work(sbfield, relation, subject)
						end
					else
						field.each do |sbfield|
							next unless sbfield.code == 'f' || sbfield.code == 's'
							enerate_related_work(sbfield, relation, subject)
						end
					end
				end
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


		def normalize_space(value)
			value.gsub(/\s+/, ' ').strip
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
				uri_identifier = get_uri('identifier')
				@graph << [resource, RDF.BF.systemNumber, uri_identifier]
				@graph << [uri_identifier, RDF.type, BF.Identifier]
				@graph << [uri_identifier, BF.identifierValue, sysnum]
			end
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

		def clean_id(value)
			value = value.sub(/\(OCoLC\)/, '').sub(/^(ocm|ocn)/, '').sub(/\(DLC\)/, '')
			clean_string(value)
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
				@graph << [resource, BF.authorizedAccessPoint, RDF.Literal.new(clean_string(value), :language => xml_lang.to_sym)]
			when 'title'
				subfs = if %w(245 242 243 246 490 510 630 730 740 830).include?(field.tag)
					%w(a b f h k n p)
				else
					%w(t f k m n p s)
				end
				value = target_field.subfields.select{|f| subfs.include?(f.code)}.map{|f| f.value}.join(' ')
				if set_graph
					@graph << [resource, BF.titleValue, RDF.Literal.new(clean_title_string(value), :language => xml_lang.to_sym)]
				else
					return RDF.Literal.new(clean_title_string(value), :language => xml_lang.to_sym)
				end
			when 'subject'
				value = target_field.subfields.reject{|f| f.code == '6'}..map{|f| f.value}.join(' ')
				@graph << [resource, BF.authorizedAccessPoint, RDF.Literal.new(clean_title_string(value), :language => xml_lang.to_sym)]
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

	  def get_uri(type)
	  	@num += 1
	  	RDF::URI.new(@baseuri + type + @num.to_s)
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

	  def chop_puctuation(value, punc)
	  	value[-1] == punc ? value.chop : value
	  end

	end

end
