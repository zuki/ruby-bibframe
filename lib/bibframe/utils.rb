require 'marc'
require 'rdf'
require 'bibframe/marc-custom'
require 'bibframe/constants'
include RDF

module Bibframe

	module Utils

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

	  def get_uri(type)
	  	@num += 1
	  	RDF::URI.new(@baseuri + type + @num.to_s)
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
				uri_identifier = get_uri('identifier')
				@graph << [resource, RDF.BF.systemNumber, uri_identifier]
				@graph << [uri_identifier, RDF.type, BF.Identifier]
				@graph << [uri_identifier, BF.identifierValue, sysnum]
			end
		end

		def normalize_space(value)
			value.gsub(/\s+/, ' ').strip
		end

	end # Utils

end # Bibframe