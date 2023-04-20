#!/usr/bin/env ruby

require "yaml"
require "date"

terms = []
Dir["isotc211-glossary/geolexica/concept/*.yaml"].map do |yaml_file|
  terms << YAML.safe_load(IO.read(yaml_file), permitted_classes: [Date, Time])
  puts "Processing #{yaml_file}"
end

term_count = terms.map do |t|
  t["data"]["localizedConcepts"].count
end.sum

meta = {
  "concept_count" => terms.length,
  "term_count" => term_count,
  "version" => "20230420",
}

File.open("metadata.yaml", "w") do |file|
  file.write(meta.to_yaml)
end

puts "Done."
