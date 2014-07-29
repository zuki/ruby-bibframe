# -*- encoding: utf-8 -*-

require 'marc'
require 'rdf'
require 'bibframe/version'
require 'bibframe/marc-custom'
require 'bibframe/vocab-bf'
require 'bibframe/vocab-mads'
require 'bibframe/constants'
require 'bibframe/utils'
require 'bibframe/bfrdf'
include RDF

module Bibframe

##
  # Alias for `BibFrame::BFRDF.new`.
  #
  # @param (see BibFrame::BFRDF#initialize)
  # @return [BibFrame::BFRDF]
  def self.BFRDF(*args)
    Bibframe::BFRDF.new(*args)
  end
end
