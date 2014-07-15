# -*- encoding: utf-8 -*-
# This file generated automatically using vocab-fetch from http://www.loc.gov/mads/rdf/v1.rdf
require 'rdf'
module RDF
  class MADS < StrictVocabulary("http://www.loc.gov/mads/rdf/v1#")

    # Class definitions
    term :Address,
      label: "Address".freeze,
      type: "owl:Class".freeze
    term :Affiliation,
      comment: %(A resource that describes an individual's affiliation with an organization or group, such as the nature of the affiliation and the active dates.).freeze,
      label: "Affiliation".freeze,
      type: "owl:Class".freeze
    term :Area,
      comment: %(Describes a resource whose label is a non-jurisdictional geographic entity.).freeze,
      label: "Area Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Geographic".freeze,
      type: "owl:Class".freeze
    term :Authority,
      comment: %(A concept with a controlled label.).freeze,
      label: "Authority".freeze,
      "owl:disjointWith" => [%(http://www.loc.gov/mads/rdf/v1#DeprecatedAuthority).freeze, %(http://www.loc.gov/mads/rdf/v1#MADSCollection).freeze, %(http://www.loc.gov/mads/rdf/v1#MADSScheme).freeze, %(http://www.loc.gov/mads/rdf/v1#Variant).freeze],
      subClassOf: ["owl:Thing".freeze, "skos:Concept".freeze],
      type: "owl:Class".freeze
    term :City,
      comment: %(Describes a resource whose label is an inhabited place incorporated as a city, town, etc.).freeze,
      label: "City Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Geographic".freeze,
      type: "owl:Class".freeze
    term :CitySection,
      comment: %(Describes a resource whose label is a smaller unit within a populated place, e.g., a neighborhood, park, or
      street.).freeze,
      label: "City Section Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Geographic".freeze,
      type: "owl:Class".freeze
    term :ComplexSubject,
      comment: %(The label of a madsrdf:ComplexSubject is the concatenation of labels from two or more madsrdf:SimpleType descriptions, except that the combination of madsrdf:SimpleType
      labels for the madsrdf:ComplexSubject does not meet the conditions to be the label of a madsrdf:NameTitle resource or madsrdf:HierarchicalGeographic resource.).freeze,
      label: "Complex Subject Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#ComplexType".freeze,
      type: "owl:Class".freeze
    term :ComplexType,
      comment: %(madsrdf:ComplexType is a resource whose label is the concatenation of labels from two or more Authority descriptions or two or more Variant descriptions or some
      combination of Authority and Variant descriptions, each of a madsrdf:SimpleType.).freeze,
      label: "Complex Type".freeze,
      "owl:disjointWith" => %(http://www.loc.gov/mads/rdf/v1#SimpleType).freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#MADSType".freeze,
      type: "owl:Class".freeze
    term :ConferenceName,
      comment: %(Describes a resource whose label represents a conference name.).freeze,
      label: "Conference Name Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Name".freeze,
      type: "owl:Class".freeze
    term :Continent,
      comment: %(Describes a resource whose label is one of seven large landmasses on Earth. These are: Asia, Africa, Europe,
      North America, South America, Australia, and Antarctica.).freeze,
      label: "Continent Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Geographic".freeze,
      type: "owl:Class".freeze
    term :CorporateName,
      comment: %(Describes a resource whose label is the name of a corporate entity, which may include political or ecclesiastical
      entities.).freeze,
      label: "Corporate Name Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Name".freeze,
      type: "owl:Class".freeze
    term :Country,
      comment: %(Describes a resource whose label is a country, i.e. a political entity considered a country. ).freeze,
      label: "Country Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Geographic".freeze,
      type: "owl:Class".freeze
    term :County,
      comment: %(Describes a resource whose label is the largest local administrative unit, e.g. Warwickshire, in a country, e.g.
      England.).freeze,
      label: "County Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Geographic".freeze,
      type: "owl:Class".freeze
    term :DateNameElement,
      label: "Date Name Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#NameElement".freeze,
      type: "owl:Class".freeze
    term :DeprecatedAuthority,
      comment: %(A former Authority.).freeze,
      label: "Deprecated Authority".freeze,
      "owl:disjointWith" => [%(http://www.loc.gov/mads/rdf/v1#Authority).freeze, %(http://www.loc.gov/mads/rdf/v1#MADSCollection).freeze, %(http://www.loc.gov/mads/rdf/v1#MADSScheme).freeze],
      subClassOf: "owl:Thing".freeze,
      type: "owl:Class".freeze
    term :Element,
      comment: %(madsrdf:Element types describe the various parts of labels.).freeze,
      label: "Element".freeze,
      type: "owl:Class".freeze
    term :ExtraterrestrialArea,
      comment: %(Describes a resource whose label is any extraterrestrial entity or space, including a solar system, a galaxy, a
      star system, and a planet, including a geographic feature of an individual planet.).freeze,
      label: "Extraterrestrial Area Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Geographic".freeze,
      type: "owl:Class".freeze
    term :FamilyName,
      comment: %(Describes a resource whose label represents a family name.).freeze,
      label: "Family Name Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Name".freeze,
      type: "owl:Class".freeze
    term :FamilyNameElement,
      label: "Family Name Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#NameElement".freeze,
      type: "owl:Class".freeze
    term :FullNameElement,
      label: "Fullname Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#NameElement".freeze,
      type: "owl:Class".freeze
    term :GenreForm,
      comment: %(Describes a resource whose label is a genre or form term. Genre terms for textual materials designate specific kinds of materials distinguished by the style or
      technique of their intellectual contents; for example, biographies, catechisms, essays, hymns, or reviews. Form terms designate historically and functionally specific kinds of materials as
      distinguished by an examination of their physical character, characteristics of their intellectual content, or the order of information within them; for example, daybooks, diaries, directories,
      journals, memoranda, questionnaires, syllabi, or time sheets. In the context of graphic materials, genre headings denote categories of material distinguished by vantage point, intended purpose,
      characteristics of the creator, publication status, or method of representation.).freeze,
      label: "Genre/Form Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#SimpleType".freeze,
      type: "owl:Class".freeze
    term :GenreFormElement,
      label: "Genre/Form Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Element".freeze,
      type: "owl:Class".freeze
    term :Geographic,
      comment: %(Describes a resource whose label represents a geographic place or feature, especially when a more precise geographic determination \(City, Country, Region, etc.\) cannot
      be made.).freeze,
      label: "Geographic Authority".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#SimpleType".freeze,
      type: "owl:Class".freeze
    term :GeographicElement,
      label: "Geographic Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Element".freeze,
      type: "owl:Class".freeze
    term :GivenNameElement,
      label: "Given Name Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#NameElement".freeze,
      type: "owl:Class".freeze
    term :HierarchicalGeographic,
      comment: %(A madsrdf:HierarchicalGeographic indicates that its label is the concatenation of labels from a sequence of madsrdf:Geographic types taken from one of the
      madsrdf:Geographic sub-classes such as madsrdf:City, madsrdf:Country, madsrdf:State, madsrdf:Region, madsrdf:Area, etc. The madsrdf:Geographic resources that constitute the
      madsrdf:HierarchicalGeographic should have a broader to narrower hierarchical relationship between them.).freeze,
      label: "Hierarchical Geographic Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#ComplexType".freeze,
      type: "owl:Class".freeze
    term :Identifier,
      comment: %(A madsrdf:Identifier resource describes an identifier by associating the identifier value with its type. To be
      used to record identifiers for a resource in the absence of URIs.).freeze,
      label: "Other Identifier".freeze,
      type: "owl:Class".freeze
    term :Island,
      comment: %(Describes a resource whose label is a tract of land surrounded by water and smaller than a continent but is not
      itself a separate country. ).freeze,
      label: "Island Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Geographic".freeze,
      type: "owl:Class".freeze
    term :Language,
      comment: %(Describes a resource whose label represents a language.).freeze,
      label: "Language Type".freeze,
      "owl:equivalentClass" => %(dc:LinguisticSystem).freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#SimpleType".freeze,
      type: "owl:Class".freeze
    term :LanguageElement,
      label: "Language Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Element".freeze,
      type: "owl:Class".freeze
    term :MADSCollection,
      comment: %(A madsrdf:Collection is an organizational unit, members of which will have some form of intellectually unifying
      theme but not to the extent that it defines an independent knowledge organization system. It aggregates madsrdf:Authority descriptions or other madsrdf:MADSCollection resources.).freeze,
      label: "MADS Collection".freeze,
      "owl:disjointWith" => [%(http://www.loc.gov/mads/rdf/v1#Authority).freeze, %(http://www.loc.gov/mads/rdf/v1#MADSScheme).freeze, %(http://www.loc.gov/mads/rdf/v1#Variant).freeze],
      subClassOf: "skos:Collection".freeze,
      type: "owl:Class".freeze
    term :MADSScheme,
      comment: %(MADS Scheme is an organizational unit that describes a knowledge organization system. It aggregates madsrdf:Authority descriptions and/or madsrdf:MADSCollection
      resources included in the knowledge organization system. Including a madsrdf:MADSCollection within a madsrdf:MADSScheme should be done with care; when a madsrdf:MADSCollection is part of a
      madsrdf:MADSScheme, then any madsrdf:Authority within that madsrdf:MADSCollection is effectively also in the madsrdf:MADSScheme.).freeze,
      label: "MADS Scheme".freeze,
      "owl:disjointWith" => [%(http://www.loc.gov/mads/rdf/v1#Authority).freeze, %(http://www.loc.gov/mads/rdf/v1#MADSCollection).freeze, %(http://www.loc.gov/mads/rdf/v1#Variant).freeze],
      subClassOf: "skos:ConceptScheme".freeze,
      type: "owl:Class".freeze
    term :MADSType,
      label: "MADS Type".freeze,
      "owl:disjointWith" => [%(http://www.loc.gov/mads/rdf/v1#MADSCollection).freeze, %(http://www.loc.gov/mads/rdf/v1#MADSScheme).freeze],
      type: "owl:Class".freeze
    term :MainTitleElement,
      label: "Main Title Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#TitleElement".freeze,
      type: "owl:Class".freeze
    term :Name,
      comment: %(Describes a resource whose label represents a name, especially when a more precise Name type \(madsrdf:ConferenceName, masdrdf:FamilyName, etc.\) cannot be
      identified.).freeze,
      label: "Name Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#SimpleType".freeze,
      type: "owl:Class".freeze
    term :NameElement,
      label: "Name Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Element".freeze,
      type: "owl:Class".freeze
    term :NameTitle,
      comment: %(The label of a madsrdf:NameTitle resource is the concatenation of a label of a madsrdf:Name description and the label of a madsrdf:Title description. Both description
      types \(madsrdf:Name and madsrdf:Title\) are of madsrdf:SimpleType types.).freeze,
      label: "Name/Title Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#ComplexType".freeze,
      type: "owl:Class".freeze
    term :NonSortElement,
      label: "Non-sort Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#TitleElement".freeze,
      type: "owl:Class".freeze
    term :Occupation,
      comment: %(Describes a resource whose label represents an occcupation.).freeze,
      label: "Occupation Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#SimpleType".freeze,
      type: "owl:Class".freeze
    term :PartNameElement,
      label: "Part Name Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#TitleElement".freeze,
      type: "owl:Class".freeze
    term :PartNumberElement,
      label: "Part Number Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#TitleElement".freeze,
      type: "owl:Class".freeze
    term :PersonalName,
      comment: %(Describes a resource whose label represents a personal name.).freeze,
      label: "Personal Name Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Name".freeze,
      type: "owl:Class".freeze
    term :Province,
      comment: %(Describes a resource whose label is a first order political division, e.g. Ontario, within a country, e.g.
      Canada. ).freeze,
      label: "Province Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Geographic".freeze,
      type: "owl:Class".freeze
    term :RWO,
      comment: %(A madsrdf:RWO is an abstract entity and identifies a Real World Object \(RWO\) identified by the label of a
      madsrdf:Authority or madsrdf:DeprecatedAuthority.).freeze,
      label: "Real World Object".freeze,
      subClassOf: "owl:Thing".freeze,
      type: "owl:Class".freeze
    term :Region,
      comment: %(Describes a resource whose label is an area that has the status of a jurisdiction, usually incorporating more
      than one first level jurisdiction. ).freeze,
      label: "Region Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Geographic".freeze,
      type: "owl:Class".freeze
    term :SimpleType,
      comment: %(madsrdf:SimpleType is a resource with a label constituting a single word or phrase.).freeze,
      label: "Simple Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#MADSType".freeze,
      type: "owl:Class".freeze
    term :Source,
      comment: %(A resource that represents the source of information about another resource. madsrdf:Source is a type of
      citation.).freeze,
      label: "Source".freeze,
      type: "owl:Class".freeze
    term :State,
      comment: %(Describes a resource whose label is a first order political division, e.g. Montana, within a country, e.g.
      U.S.).freeze,
      label: "State Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Geographic".freeze,
      type: "owl:Class".freeze
    term :SubTitleElement,
      label: "Subtitle Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#TitleElement".freeze,
      type: "owl:Class".freeze
    term :Temporal,
      comment: %(Describes a resource whose label represents a time-based notion.).freeze,
      label: "Temporal Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#SimpleType".freeze,
      type: "owl:Class".freeze
    term :TemporalElement,
      label: "Temporal Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Element".freeze,
      type: "owl:Class".freeze
    term :TermsOfAddressNameElement,
      label: "Terms of Address Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#NameElement".freeze,
      type: "owl:Class".freeze
    term :Territory,
      comment: %(Describes a resource whose label is a geographical area belonging to or under the jurisdiction of a governmental
      authority. ).freeze,
      label: "Territory Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Geographic".freeze,
      type: "owl:Class".freeze
    term :Title,
      comment: %(Describes a resource whose label represents a title.).freeze,
      label: "Title Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#SimpleType".freeze,
      type: "owl:Class".freeze
    term :TitleElement,
      label: "Title Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Element".freeze,
      type: "owl:Class".freeze
    term :Topic,
      comment: %(Describes a resource whose label represents a topic.).freeze,
      label: "Topic Type".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#SimpleType".freeze,
      type: "owl:Class".freeze
    term :TopicElement,
      label: "Topic Element".freeze,
      subClassOf: "http://www.loc.gov/mads/rdf/v1#Element".freeze,
      type: "owl:Class".freeze
    term :Variant,
      comment: %(A resource whose label is the alternate form of an Authority or Deprecated Authority.).freeze,
      label: "Variant".freeze,
      "owl:disjointWith" => [%(http://www.loc.gov/mads/rdf/v1#Authority).freeze, %(http://www.loc.gov/mads/rdf/v1#MADSCollection).freeze, %(http://www.loc.gov/mads/rdf/v1#MADSScheme).freeze],
      subClassOf: ["owl:Thing".freeze, "skosxl:Label".freeze],
      type: "owl:Class".freeze

    # Property definitions
    property :adminMetadata,
      comment: %(This relates an Authority or Variant to its administrative metadata, which is, minimimally, a Class defined outside of the MADS/RDF namespace. The RecordInfo Class from
      the RecordInfo ontology is recommended.).freeze,
      label: "Administrative Metadata".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :affiliationEnd,
      comment: %(The date an individual ceased to be affiliated with an organization.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Affiliation".freeze,
      label: "Affiliation Ended".freeze,
      range: "xsd:date".freeze,
      type: ["rdf:Property".freeze, "owl:DatatypeProperty".freeze]
    property :affiliationStart,
      comment: %(The date an individual established an affiliation with an organization.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Affiliation".freeze,
      label: "Affiliation Started".freeze,
      range: "xsd:date".freeze,
      type: ["rdf:Property".freeze, "owl:DatatypeProperty".freeze]
    property :authoritativeLabel,
      comment: %(A lexical string representing a controlled, curated label for the Authority.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Authority".freeze,
      label: "Authoritative Label".freeze,
      subPropertyOf: ["rdfs:label".freeze, "skos:prefLabel".freeze],
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :changeNote,
      comment: %(A note detailing a modification to an Authority or Variant.).freeze,
      label: "Change Note".freeze,
      "owl:equivalentProperty" => %(skos:changeNote).freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#note".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :citationNote,
      comment: %(A note about how the madsrdf:Source relates to the resource about which the madsrdf:Source is the information source.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Source".freeze,
      label: "Citation Note".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :citationSource,
      comment: %(The cited resource.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Source".freeze,
      label: "Citation Source".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :citationStatus,
      comment: %(Should use a standard term - such as 'found' or 'not found' - to indicate whether the cited resource yielded information about the resource related to the
      madsrdf:Source.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Source".freeze,
      label: "Citation Status".freeze,
      range: "xsd:string".freeze,
      type: ["owl:DatatypeProperty".freeze, "rdf:Property".freeze]
    property :city,
      comment: %(The city component of an address.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Address".freeze,
      label: "City".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :classification,
      comment: %(The classification code associated with a madsrdf:Authority.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Authority".freeze,
      label: "Classification".freeze,
      subPropertyOf: "skos:semanticRelation".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :code,
      comment: %(A code is a string of characters associated with a the authoritative or deprecated label. It may record an
      historical notation once used to uniquely identify a concept.).freeze,
      label: "Code".freeze,
      subPropertyOf: "skos:notation".freeze,
      type: ["owl:DatatypeProperty".freeze, "rdf:Property".freeze]
    property :componentList,
      comment: %(madsrdf:componentList organizes the madsrdf:SimpleType resources whose labels are represented in the label of the
      associated madsrdf:ComplexType resource.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#ComplexType".freeze,
      label: "Component List".freeze,
      type: ["rdf:Property".freeze, "owl:ObjectProperty".freeze]
    property :country,
      comment: %(Country associated with an address.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Address".freeze,
      label: "Country".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :definitionNote,
      comment: %(An explanation of the meaning of an Authority, DeprecatedAuthority, or Variant description.).freeze,
      label: "Definition Note".freeze,
      "owl:equivalentProperty" => %(skos:definition).freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#note".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :deletionNote,
      comment: %(A note pertaining to the deletion of a resource.).freeze,
      label: "Deletion Note".freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#changeNote".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :deprecatedLabel,
      comment: %(A label once considered authoritative \(controlled and curated\) but which is no longer.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#DeprecatedAuthority".freeze,
      label: "Deprecated Label".freeze,
      subPropertyOf: ["rdfs:label".freeze, "skos:hiddenLabel".freeze],
      type: ["rdf:Property".freeze, "owl:AnnotationProperty".freeze]
    property :editorialNote,
      comment: %(A note pertaining to the management of the label associated with the resource.).freeze,
      label: "Editorial Note".freeze,
      "owl:equivalentProperty" => %(skos:editorialNote).freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#note".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :elementList,
      comment: %(The madsrdf:elementList property is used to organize the various parts of labels.).freeze,
      label: "Element List".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :elementValue,
      domain: "http://www.loc.gov/mads/rdf/v1#Element".freeze,
      label: "Element Value".freeze,
      range: "xsd:string".freeze,
      type: ["owl:DatatypeProperty".freeze, "rdf:Property".freeze]
    property :email,
      domain: "http://www.loc.gov/mads/rdf/v1#Affiliation".freeze,
      label: "Email".freeze,
      type: ["owl:DatatypeProperty".freeze, "rdf:Property".freeze]
    property :exampleNote,
      comment: %(A example of how the resource might be used.).freeze,
      label: "Example Note".freeze,
      "owl:equivalentProperty" => %(skos:example).freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#note".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :extendedAddress,
      comment: %(The second address line, if needed.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Address".freeze,
      label: "Extended Address".freeze,
      type: ["owl:DatatypeProperty".freeze, "rdf:Property".freeze]
    property :extension,
      label: "Extension".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :fax,
      comment: %(Fax number).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Affiliation".freeze,
      label: "Fax".freeze,
      type: ["owl:DatatypeProperty".freeze, "rdf:Property".freeze]
    property :fieldOfActivity,
      comment: %(The field of activity associated with an individual.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#RWO".freeze,
      label: "Field of Activity".freeze,
      type: ["rdf:Property".freeze, "owl:ObjectProperty".freeze]
    property :hasAbbreviationVariant,
      label: "Has Abbreviation Variant".freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#hasVariant".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasAcronymVariant,
      label: "Has Acronym Variant".freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#hasVariant".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasAffiliation,
      comment: %(Property to associate an individual, such as a foaf:Agent, to a group or organization with which an individual is
      or has been affiliated.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#RWO".freeze,
      label: "Has Affiliation".freeze,
      range: "http://www.loc.gov/mads/rdf/v1#Affiliation".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasAffiliationAddress,
      comment: %(The address of the group or organization with which an individual is associated.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Affiliation".freeze,
      label: "Has Affiliation Address".freeze,
      range: "http://www.loc.gov/mads/rdf/v1#Address".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasBroaderAuthority,
      label: "Has Broader Authority".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#hasNarrowerAuthority).freeze,
      subPropertyOf: ["http://www.loc.gov/mads/rdf/v1#hasRelatedAuthority".freeze, "skos:broader".freeze],
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasBroaderExternalAuthority,
      comment: %(Creates a direct relationship between an Authority and a more broadly defined Authority from a different MADS
      Scheme.).freeze,
      label: "Has Broader External Authority".freeze,
      subPropertyOf: ["http://www.loc.gov/mads/rdf/v1#hasBroaderAuthority".freeze, "skos:broadMatch".freeze],
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasCloseExternalAuthority,
      comment: %(Records a relationship between an Authority and one that is closely related from a different MADS
      Scheme.).freeze,
      label: "Has Close External Authority".freeze,
      subPropertyOf: ["http://www.loc.gov/mads/rdf/v1#hasRelatedAuthority".freeze, "skos:closeMatch".freeze],
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze, "owl:SymmetricProperty".freeze]
    property :hasCorporateParentAuthority,
      comment: %(Establishes a relationship between a CorporateName Authority and one of the same that is more broadly
      defined.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#CorporateName".freeze,
      label: "Has Parent Organization".freeze,
      range: "http://www.loc.gov/mads/rdf/v1#CorporateName".freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#hasRelatedAuthority".freeze,
      type: ["rdf:Property".freeze, "owl:ObjectProperty".freeze]
    property :hasCorporateSubsidiaryAuthority,
      comment: %(Establishes a relationship between a CorporateName Authority and one of the same that is more narrowly
      defined.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#CorporateName".freeze,
      label: "Is Parent Organization Of".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#hasCorporateParentAuthority).freeze,
      range: "http://www.loc.gov/mads/rdf/v1#CorporateName".freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#hasRelatedAuthority".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasEarlierEstablishedForm,
      comment: %(Used to reference a resource that was an earlier form. This is Related type='earlier' in MADS XML.).freeze,
      label: "Has Earlier Established Form".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#hasLaterEstablishedForm).freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#see".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasExactExternalAuthority,
      comment: %(Records a relationship between an Authority and one to which it matches exactly but from a different MADS
      Scheme.).freeze,
      label: "Has Exact External Authority".freeze,
      subPropertyOf: ["http://www.loc.gov/mads/rdf/v1#hasCloseExternalAuthority".freeze, "skos:exactMatch".freeze],
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze, "owl:SymmetricProperty".freeze, "owl:TransitiveProperty".freeze]
    property :hasExpansionVariant,
      label: "Has Expansion Variant".freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#hasVariant".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasHiddenVariant,
      comment: %(Use for variants that are searchable, but not necessarily for display.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Authority".freeze,
      label: "Has Hidden Variant".freeze,
      range: "http://www.loc.gov/mads/rdf/v1#Variant".freeze,
      subPropertyOf: "skosxl:hiddenLabel".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasIdentifier,
      comment: %(Associates a resource with a madsrdf:Identifier.).freeze,
      label: "Has Identifier".freeze,
      range: "http://www.loc.gov/mads/rdf/v1#Identifier".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasLaterEstablishedForm,
      comment: %(Use to reference the later form of a resource. This is Related type='later' in MADS XML.).freeze,
      label: "Has Later Established Form".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#hasEarlierEstablishedForm).freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#see".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasMADSCollectionMember,
      comment: %(Associates an Authority or other Collection with a madsrdf:MADSCollection.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#MADSCollection".freeze,
      label: "Has MADSCollection Member".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#isMemberOfMADSCollection).freeze,
      subPropertyOf: "skos:member".freeze,
      type: ["rdf:Property".freeze, "owl:ObjectProperty".freeze]
    property :hasMADSSchemeMember,
      comment: %(Associates an Authority or Collection with a madsrdf:MADSScheme.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#MADSScheme".freeze,
      label: "Has MADS Scheme Member".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#isMemberOfMADSScheme).freeze,
      type: ["rdf:Property".freeze, "owl:ObjectProperty".freeze]
    property :hasNarrowerAuthority,
      comment: %(Creates a direct relationship between an Authority and one that is more narrowly defined.).freeze,
      label: "Has Narrower Authority".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#hasBroaderAuthority).freeze,
      subPropertyOf: ["http://www.loc.gov/mads/rdf/v1#hasRelatedAuthority".freeze, "skos:narrower".freeze],
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasNarrowerExternalAuthority,
      comment: %(Creates a direct relationship between an Authority and a more narrowly defined Authority from a different MADS
      Scheme.).freeze,
      label: "Has Narrower External Authority".freeze,
      subPropertyOf: ["http://www.loc.gov/mads/rdf/v1#hasNarrowerAuthority".freeze, "skos:narrowMatch".freeze],
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasReciprocalAuthority,
      comment: %(Establishes a relationship between two Authority resources. It is reciprocal, so the relationship must be shared. This is Related type='equivalent' in MADS
      XML.).freeze,
      label: "Has Reciprocal Authority".freeze,
      subPropertyOf: ["http://www.loc.gov/mads/rdf/v1#hasRelatedAuthority".freeze, "skos:related".freeze],
      type: ["owl:SymmetricProperty".freeze, "rdf:Property".freeze, "owl:ObjectProperty".freeze]
    property :hasReciprocalExternalAuthority,
      comment: %(Establishes a relationship between an Authority and one from a different MADS Scheme. It is reciprocal, so the
      relationship must be shared.).freeze,
      label: "Has Reciprocal External Authority".freeze,
      subPropertyOf: ["http://www.loc.gov/mads/rdf/v1#hasReciprocalAuthority".freeze, "skos:relatedMatch".freeze],
      type: ["owl:SymmetricProperty".freeze, "rdf:Property".freeze, "owl:ObjectProperty".freeze]
    property :hasRelatedAuthority,
      comment: %(Unless the relationship can be more specifically identified, use 'hasRelatedAuthority.').freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Authority".freeze,
      label: "Has Related Authority".freeze,
      range: "http://www.loc.gov/mads/rdf/v1#Authority".freeze,
      subPropertyOf: "skos:semanticRelation".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasSource,
      comment: %(Associates a resource description with its Source.).freeze,
      label: "Has Source".freeze,
      range: "http://www.loc.gov/mads/rdf/v1#Source".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasTopMemberOfMADSScheme,
      comment: %(Identifies an Authority that is at the top of the hierarchy of authorities within the MADS Scheme.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#MADSScheme".freeze,
      label: "Has Top Member of MADS Scheme".freeze,
      range: "http://www.loc.gov/mads/rdf/v1#Authority".freeze,
      subPropertyOf: ["http://www.loc.gov/mads/rdf/v1#hasMADSSchemeMember".freeze, "skos:hasTopConcept".freeze],
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasTranslationVariant,
      comment: %(A Variant whose label represents a translation of that of the authoritative label.).freeze,
      label: "Has Translation Variant".freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#hasVariant".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hasVariant,
      comment: %(Associates a Variant with an Authority or Deprecrated Authority. Unless the variant type can be more specifically identified, use 'hasVariant.').freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Authority".freeze,
      label: "Has Variant".freeze,
      range: "http://www.loc.gov/mads/rdf/v1#Variant".freeze,
      subPropertyOf: "skosxl:altLabel".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :hiddenLabel,
      comment: %(A label entered for discovery purposes but not shown.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Variant".freeze,
      label: "Hidden Label".freeze,
      subPropertyOf: "skosxl:literalForm".freeze,
      type: ["rdf:Property".freeze, "owl:DatatypeProperty".freeze]
    property :historyNote,
      comment: %(A note pertaining to the history of the resource.).freeze,
      label: "History Note".freeze,
      "owl:equivalentProperty" => %(skos:historyNote).freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#note".freeze,
      type: "owl:AnnotationProperty".freeze
    property :hours,
      domain: "http://www.loc.gov/mads/rdf/v1#Affiliation".freeze,
      label: "Hours".freeze,
      type: ["owl:DatatypeProperty".freeze, "rdf:Property".freeze]
    property :idScheme,
      comment: %(The scheme associated with the identifier. For example, "LCCN" would be used when the Identifier Value
      \(madsrdf:idValue\) is a LC Control Number.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Identifier".freeze,
      label: "Identifier Scheme".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :idValue,
      comment: %(The value of the identifier conforming to the Identifier Scheme syntax.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Identifier".freeze,
      label: "Identifier Value".freeze,
      range: "xsd:string".freeze,
      type: ["owl:DatatypeProperty".freeze, "rdf:Property".freeze]
    property :identifiesRWO,
      comment: %(Associates a madsrdf:Authority with the Real World Object that is the subject of the authority's label.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Authority".freeze,
      label: "Identifies RWO".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#isIdentifiedByAuthority).freeze,
      range: "http://www.loc.gov/mads/rdf/v1#RWO".freeze,
      subPropertyOf: "foaf:focus".freeze,
      type: ["rdf:Property".freeze, "owl:ObjectProperty".freeze]
    property :isIdentifiedByAuthority,
      comment: %(Associates a Real World Object with its Authority description.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#RWO".freeze,
      label: "Is Identified By Authority".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#identifiesRWO).freeze,
      range: "http://www.loc.gov/mads/rdf/v1#Authority".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :isMemberOfMADSCollection,
      comment: %(Associates a Collection with a madsrdf:Authority or another madsrdf:MADSCollection.).freeze,
      label: "Is Member Of MADSCollection".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#hasMADSCollectionMember).freeze,
      range: "http://www.loc.gov/mads/rdf/v1#MADSCollection".freeze,
      type: ["rdf:Property".freeze, "owl:ObjectProperty".freeze]
    property :isMemberOfMADSScheme,
      label: "Is Member of MADS Scheme".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#hasMADSSchemeMember).freeze,
      range: "http://www.loc.gov/mads/rdf/v1#MADSScheme".freeze,
      subPropertyOf: "skos:inScheme".freeze,
      type: ["rdf:Property".freeze, "owl:ObjectProperty".freeze]
    property :isTopMemberOfMADSScheme,
      comment: %(Identifies a MADS Scheme in which the Authority is at the top of the hierarchy.).freeze,
      label: "Is Top Member of MADS Scheme".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#hasTopMemberOfMADSScheme).freeze,
      range: "http://www.loc.gov/mads/rdf/v1#MADSScheme".freeze,
      subPropertyOf: ["http://www.loc.gov/mads/rdf/v1#isMemberOfMADSScheme".freeze, "skos:topConceptOf".freeze],
      type: ["rdf:Property".freeze, "owl:ObjectProperty".freeze]
    property :natureOfAffiliation,
      comment: %(Records the individual's role or position in the organization with which the individual is affiliated. A "job
      title" might be appropriate.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Affiliation".freeze,
      label: "Nature of Affiliation".freeze,
      type: ["rdf:Property".freeze, "owl:AnnotationProperty".freeze]
    property :note,
      comment: %(A note about the resource.).freeze,
      label: "Note".freeze,
      "owl:equivalentProperty" => %(skos:note).freeze,
      type: ["rdf:Property".freeze, "owl:AnnotationProperty".freeze]
    property :organization,
      comment: %(The group or organization with which an individual is associated.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Affiliation".freeze,
      label: "Organization or Group".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :phone,
      domain: "http://www.loc.gov/mads/rdf/v1#Affiliation".freeze,
      label: "Phone".freeze,
      type: ["owl:DatatypeProperty".freeze, "rdf:Property".freeze]
    property :postcode,
      domain: "http://www.loc.gov/mads/rdf/v1#Address".freeze,
      label: "Post Code / Zip Code".freeze,
      type: ["owl:DatatypeProperty".freeze, "rdf:Property".freeze]
    property :scopeNote,
      label: "Scope Note".freeze,
      "owl:equivalentProperty" => %(skos:scopeNote).freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#note".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :see,
      comment: %(Denotes a relationship between an Authority and/or DeprecatedAuthority. The relationship may or may or may not be
      reciprocated and there is no certainty that the related resource will further illuminate the original resource.).freeze,
      label: "See Also".freeze,
      subPropertyOf: "rdfs:seeAlso".freeze,
      type: "owl:ObjectProperty".freeze
    property :state,
      comment: %(The state associated with an address.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Address".freeze,
      label: "State".freeze,
      type: ["owl:AnnotationProperty".freeze, "rdf:Property".freeze]
    property :streetAddress,
      comment: %(First line of address. For second line, use madsrdf:extendedAddress.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Address".freeze,
      label: "Street Address".freeze,
      type: ["owl:DatatypeProperty".freeze, "rdf:Property".freeze]
    property :useFor,
      comment: %("Use [This Resource] For." Traditional "USE FOR" reference.).freeze,
      label: "Use For".freeze,
      "owl:inverseOf" => %(http://www.loc.gov/mads/rdf/v1#useInstead).freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#see".freeze,
      type: ["rdf:Property".freeze, "owl:ObjectProperty".freeze]
    property :useInstead,
      comment: %("Use [This Other Resource] Instead." Traditional "USE" reference.).freeze,
      label: "Use Instead".freeze,
      subPropertyOf: "http://www.loc.gov/mads/rdf/v1#see".freeze,
      type: ["owl:ObjectProperty".freeze, "rdf:Property".freeze]
    property :variantLabel,
      comment: %(The lexical, variant form of an authoritative label.).freeze,
      domain: "http://www.loc.gov/mads/rdf/v1#Variant".freeze,
      label: "Variant Label".freeze,
      subPropertyOf: "skosxl:literalForm".freeze,
      type: ["owl:DatatypeProperty".freeze, "rdf:Property".freeze]
  end
end
