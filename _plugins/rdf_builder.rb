require "rdf"
require "rdf/turtle"
require "rdf/vocab"

class RDFBuilder
  # Shortcut access to vocabularies (no need to prefix with RDF)
  DC = RDF::Vocab::DC
  OWL = RDF::OWL
  RDFS = RDF::RDFS
  SKOS = RDF::Vocab::SKOS
  XSD = RDF::XSD

  Profile = RDF::Vocabulary.new("/api/rdf-profile#")

  # This is concept data, which is different than site.data
  attr_reader :data

  # Supported languages defined for this concept
  attr_reader :languages

  # Jekyll::Site instance
  attr_reader :site

  def initialize(concept_hash, site)
    @data = concept_hash
    @site = site
    @languages = site.config["term_languages"] & data.keys
  end

  def graph
    @graph or build_graph
  end

  def to_turtle
    graph.dump(:ttl, {
      # No, currently there is no base URI set (TODO maybe)
      # base_uri: concept,
      prefixes: {
        nil => concept,
        :dcterms => DC.to_uri,
        :owl => OWL.to_uri,
        :rdf => RDF.to_uri,
        :"rdf-profile" => Profile.to_uri,
        :rdfs => RDFS.to_uri,
        :skos => SKOS.to_uri,
        :xsd => XSD.to_uri,
      },
    })
  end

  private

  # Graph subjects

  def concept
    @concept ||= RDF::URI.new("/concepts/#{term_id}/")
  end

  def concept_closure
    concept.join("closure")
  end

  def concept_linked_data_api
    concept.join("linked-data-api")
  end

  # Graph predicates

  def concept_classification
    concept.join("classification")
  end

  def concept_status
    concept.join("status")
  end

  # Easy data accessors

  def term_id
    data["termid"]&.to_i
  end

  def en_data
    data["eng"]
  end

  def page_url
    "/api/concepts/#{term_id}.ttl"
  end

  # Graph building

  def build_graph
    @graph = RDF::Graph.new

    add_statement(concept, RDF.type, OWL.Ontology)

    # concept itself

    # is trailing '#' okay?
    add_statement(concept, OWL.imports, DC.to_uri)
    add_statement(concept, OWL.imports, Profile.to_uri)
    add_statement(concept, OWL.imports, SKOS.to_uri)

    # concept:closure

    add_statement(concept_closure, RDF.type, SKOS.Concept)
    add_statement(concept_closure, DC.source, en_data.dig("authoritative_source", "link"))

    add_statement(concept_closure, Profile.termID, RDF::URI(page_url))

    add_statement(concept_closure, SKOS.inScheme, Profile.GeolexicaConceptScheme)
    add_statement(concept_closure, RDFS.label, en_data["term"]) # TODO escape filter
    add_statement(concept_closure, SKOS.notation, term_id)

    add_statement(concept_closure, DC.dateAccepted, en_data["date_accepted"]) # TODO format "%F"
    add_statement(concept_closure, DC.modified, en_data["date_amended"]) # TODO format "%F"
    add_statement(concept_closure, concept_status, en_data["entry_status"]) # TODO escape
    add_statement(concept_closure, concept_classification, en_data["classification"]) # TODO escape

    # concept:closure translatable part

    each_language do |lang, l_data|
      add_statement(concept_closure, Profile["#{lang}Origin"], Profile[language_data(lang)["lang_en"]])
      add_statement(concept_closure, SKOS.definition, l_data.dig("definition"), language: lang)
      add_statement(concept_closure, SKOS.prefLabel, l_data.dig("term"), language: lang) # TODO escape filter
      add_statement(concept_closure, SKOS.altLabel, l_data.dig("alt"), language: lang) # TODO escape filter
    end

    # concept:linked-data-api

    add_statement(concept_linked_data_api, RDF.type, DC.MediaTypeOrExtent)
    add_statement(concept_linked_data_api, SKOS.prefLabel, "linked-data-api")

    graph
  end

  def each_language
    languages.each do |lang|
      yield lang, data[lang]
    end
  end

  def add_statement(subject, predicate, object, **options)
    return if object.nil?
    add_statement!(subject, predicate, object, **options)
  end

  def add_statement!(subject, predicate, object, language: nil)
    if language
      short_code = language_data(language)["iso-639-1"]
      object = RDF::Literal.new(object, language: short_code)
    end

    s = RDF::Statement.new(subject, predicate, object)
    @graph << s
  end

  def language_data(long_code)
    site.data["lang"][long_code]
  end
end
