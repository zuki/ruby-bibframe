require 'marc'
require 'rdf'
require 'bibframe/vocab-bf'
require 'bibframe/vocab-mads'
require 'linkeddata'
include RDF

module Bibframe

  class Repository

    PREFIXES = {
      rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
      bf: 'http://bibframe.org/vocab/',
      rdfs: 'http://www.w3.org/2000/01/rdf-schema#',
      madsrdf: 'http://www.loc.gov/mads/rdf/v1#',
      relators: 'http://id.loc.gov/vocabulary/relators/',
      dcterms: 'http://purl.org/dc/terms/',
      lcsh: 'http://id.loc.gov/authorities/subjects/',
      names: 'http://id.loc.gov/authorities/names/',
      id: 'http://id.loc.gov/resources/bibs/',
      language: 'http://id.loc.gov/vocabulary/languages/',
      lcc: 'http://id.loc.gov/authorities/classification/'
    }.freeze

    attr_reader :repository

    def initialize(reader)
      @repository = RDF::Repository.new
      for record in reader
        bfrdf = Bibframe::BFRDF.new(@repository, record)
        @repository.insert bfrdf.graph
      end
    end

    def to_ttl(file='bibframe.ttl')
      RDF::Turtle::Writer.open(file, {:prefixes => PREFIXES}) do |writer|
        @repository.each_statement do |st|
          writer << st
        end
      end
    end

    def to_nt(file='bibframe.nt')
      RDF::NTriples::Writer.open(file, {:prefixes => PREFIXES}) do |writer|
        @repository.each_statement do |st|
          writer << st
        end
      end
    end

    def to_nq(file='bibframe.nq')
      RDF::NQuads::Writer.open(file, {:prefixes => PREFIXES}) do |writer|
        @repository.each_statement do |st|
          writer << st
        end
      end
    end

    def to_xmlrdf(file='bibframe.rdf')
      RDF::RDFXML::Writer.open(file, {:prefixes => PREFIXES}) do |writer|
        @repository.each_statement do |st|
          writer << st
        end
      end
    end

    def to_json(file='bibframe.json')
      RDF::JSON::Writer.open(file) do |writer|
        @repository.each_statement do |st|
          writer << st
        end
      end
    end

    def to_jsonld(file='bibframe.jsonld')
      JSON::LD::Writer.open(file,) do |writer|
        @repository.each_statement do |st|
          writer << st
        end
      end
    end

  	if __FILE__ == $0
  		reader = MARC::XMLReader.new("/Users/dspace/Sites/marc2bibframe/marc-14290156.xml")
    	bf = Bibframe::Repository.new(reader)
    	bf.to_ttl
  	end

  end

end