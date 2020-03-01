module ConceptRepresentations
  def concept_to_json(input)
    output = input.to_h.slice("term", "termid", *term_languages)
    jsonify(output)
  end

  def concept_to_turtle(input)
    RDFBuilder.new(input, site).to_turtle
  end

  def concept_to_jsonld(input)
    RDFBuilder.new(input, site).to_jsonld
  end

  private

  def site
    @context.registers[:site]
  end

  def term_languages
    site.config["term_languages"]
  end
end

Liquid::Template.register_filter(ConceptRepresentations)
