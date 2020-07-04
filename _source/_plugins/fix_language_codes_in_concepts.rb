# (c) Copyright 2020 Ribose Inc.
#

require "jekyll/geolexica"

def FIX_LANGUAGE_CODES(hash_with_lang_mapping)
  bad_to_good =
    { "chi" => "zho", "chn" => "zho", "dut" => "nld", "ger" => "deu" }

  hash_with_lang_mapping.transform_keys { |k| bad_to_good[k] || k }
end

# Fixes language codes in info.yaml
Jekyll::Hooks.register :site, :post_read do |site|
  FIX_LANGUAGE_CODES(site.data.dig("info", "languages"))
end

# Fixes language codes in concepts
module GeolexicaOverrides
  def preprocess_concept_hash(concept_hash)
    FIX_LANGUAGE_CODES(concept_hash)
  end
end

Jekyll::Geolexica::Glossary.prepend(GeolexicaOverrides)
