require_relative "../../_plugins/concept_representations"
require_relative "../../_plugins/rdf_builder"

RSpec.describe ConceptRepresentations do
  let(:wrapper) do
    Object.new.instance_exec(fake_site) do |site|
      extend ConceptRepresentations

      # This one is normally provided by Jekyll
      def self.jsonify arg
        JSON.dump(arg)
      end

      self
    end
  end

  let(:concept_data) { load_concept_fixture("concept-10.yaml") }
  let(:fake_site) { double config: {"term_languages" => %w[eng]} }

  before do
    allow(wrapper).to receive(:site).and_return(fake_site)
  end

  describe "#concept_to_json" do
    subject { wrapper.method(:concept_to_json) }

    it "returns a JSON string" do
      retval = subject.(concept_data)
      expect(retval).to be_a(String)
      expect(retval).to start_with("{") & end_with("}")
    end

    it "returns a JSON representation of given concept" do
      retval = subject.(concept_data)
      json = JSON.parse(retval)
      expect(json["term"]).to eq("admitted term")
      expect(json["termid"]).to eq(10)
    end

    it "includes only languages specified in site config" do
      retval = subject.(concept_data)
      json = JSON.parse(retval)
      expect(json.keys).not_to include("ger")
    end
  end

  describe "#concept_to_jsonld" do
    subject { wrapper.method(:concept_to_jsonld) }

    it "returns a Turtle string" do
      allow_any_instance_of(RDFBuilder).
        to receive(:to_jsonld).and_return("representation")
      retval = subject.(concept_data)
      expect(retval).to eq("representation")
    end
  end

  describe "#concept_to_turtle" do
    subject { wrapper.method(:concept_to_turtle) }

    it "returns a Turtle string" do
      allow_any_instance_of(RDFBuilder).
        to receive(:to_turtle).and_return("representation")
      retval = subject.(concept_data)
      expect(retval).to eq("representation")
    end
  end

  def load_concept_fixture(fixture_name)
    YAML.load(fixture(fixture_name))
  end
end
