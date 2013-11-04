require 'bindurator'
require 'tempfile'

describe Bindurator do
  describe ".load_string" do
    it "rejects non-hashes" do
      expect { described_class.send(:load_string, "") }.to raise_error
      expect { described_class.send(:load_string, "a") }.to raise_error
      expect { described_class.send(:load_string, "[]") }.to raise_error
    end

    it "accepts hashes" do
      expect(described_class.send(:load_string, "{}")).to be_true
    end
  end

  describe ".load_config" do
    let(:tmp_conf) { Tempfile.new(described_class.to_s) }

    context "with valid file" do
      before { tmp_conf.write("{}"); tmp_conf.close }
      after { tmp_conf.unlink }

      it "reads config if config file exists" do
        expect(described_class.load_config(tmp_conf.path)).to be_true
      end
    end

    context "without file" do
      it "raises meaningful error if config file does not exist" do
        expect { described_class.load_config(tmp_conf.path) }.to raise_error
      end
    end
  end
end
