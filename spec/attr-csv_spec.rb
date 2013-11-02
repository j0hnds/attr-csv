require 'spec_helper'

describe "AttrCsv" do

  context 'CsvPoro' do
    let(:csv_poro) { CsvPoro.new }

    it "should have a legit multivalue accessor" do
      csv_poro.multivalue = [ 'a', 'b' ]
      expect(csv_poro.multivalue).to eq([ 'a', 'b' ])
    end

    it "should set the csv attribute when the attribute is set" do
      csv_poro.multivalue = [ 'a', 'b' ]
      expect(csv_poro.multivalue_csv).to eq('a,b')
      csv_poro.multivalue = [ 'a', 'b', 'c' ]
      expect(csv_poro.multivalue_csv).to eq('a,b,c')
      csv_poro.multivalue = [ ]
      expect(csv_poro.multivalue_csv).to be_nil
    end

    it "should reflect the csv value if the multivalue field is nil" do
      csv_poro.multivalue_csv = 'a,b,c'
      expect(csv_poro.multivalue).to eq([ 'a', 'b', 'c' ])
    end

  end
end
