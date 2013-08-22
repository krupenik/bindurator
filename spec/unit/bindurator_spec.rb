require 'bindurator'

describe Bindurator do
  describe "#load_string" do
    it "rejects non-hashes" do
      expect { Bindurator.send(:load_string, "") }.to raise_error
    end

    it "accepts hashes" do
      expect(Bindurator.send(:load_string, "---\n{}")).to be_true
    end
  end

  describe "#load_config" do
    let(:tmp_conf) { "spec/tmp/tmp.conf" }

    context "with valid file" do
      before { File.open(tmp_conf, 'w') { |f| f.write "---\n{}" } }
      after { File.unlink(tmp_conf) }

      it "reads config if config directory exists" do
        expect(Bindurator.load_config(File.dirname(tmp_conf))).to be_true
      end

      it "reads config if config file exists" do
        expect(Bindurator.load_config(tmp_conf)).to be_true
      end
    end

    context "without file" do
      it "raises meaningful error if config file does not exist" do
        expect { Bindurator.load_config(tmp_conf) }.to raise_error
      end
    end
  end

  describe "#master" do

  end

  describe "#slave" do

  end

  describe "#generate_view" do
    before { Bindurator.load_string "master" }
  end
end
