require 'spec_helper'

describe "Rails Extensions" do

  before(:each) do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3',
                                            database: ':memory:')

    ActiveRecord::Schema.define do
      create_table :csv_models do | t |
        t.column :name, :string
        t.column :multivalue_csv, :string
      end

    end
  end

  context 'CsvModel' do

    it "should allow the csv column to be saved with a null, but the field should show as an empty array" do
      CsvModel.create! name: 'Joe'
      csv_model = CsvModel.first
      expect(csv_model).not_to be_nil
      expect(csv_model.multivalue).to eq([])
      expect(csv_model.name).to eq('Joe')
      expect(csv_model.multivalue_csv).to be_nil
    end

    it "should allow the csv column to be initialized in the constructor" do
      m = CsvModel.new name: 'Harry', multivalue: [ 'val1', 'val2' ]

      expect(m.multivalue).to eq([ 'val1', 'val2' ])
      expect(m.multivalue_csv).to eq('val1,val2')

      m.save!
      csv_model = CsvModel.first

      expect(csv_model).not_to be_nil
      expect(csv_model.name).to eq('Harry')
      expect(csv_model.multivalue_csv).to eq('val1,val2')
      expect(csv_model.multivalue).to eq([ 'val1', 'val2' ])
    end

    it "should allow the csv column to be initialized as an attribute" do
      m = CsvModel.new name: 'Harry'
      m.multivalue = [ 'val1', 'val2' ]

      expect(m.multivalue).to eq([ 'val1', 'val2' ])
      expect(m.multivalue_csv).to eq('val1,val2')

      m.save!
      csv_model = CsvModel.first

      expect(csv_model).not_to be_nil
      expect(csv_model.name).to eq('Harry')
      expect(csv_model.multivalue_csv).to eq('val1,val2')
      expect(csv_model.multivalue).to eq([ 'val1', 'val2' ])
    end

    it "should allow the csv column to be initialized with an empty array" do
      m = CsvModel.new name: 'Harry', multivalue: [ ]

      expect(m.multivalue).to eq([ ])
      expect(m.multivalue_csv).to be_nil

      m.save!
      csv_model = CsvModel.first

      expect(csv_model).not_to be_nil
      expect(csv_model.name).to eq('Harry')
      expect(csv_model.multivalue_csv).to be_nil
      expect(csv_model.multivalue).to eq([])
    end

    it "should allow the csv column to be incremented with +=" do
      m = CsvModel.new name: 'Harry', multivalue: [ 'c' ]

      expect(m.multivalue).to eq([ 'c' ])
      expect(m.multivalue_csv).to eq('c')

      m.save!
      csv_model = CsvModel.first

      expect(csv_model).not_to be_nil
      expect(csv_model.name).to eq('Harry')
      expect(csv_model.multivalue_csv).to eq('c')
      expect(csv_model.multivalue).to eq([ 'c' ])

      csv_model.multivalue += [ 'a', 'b' ]
      csv_model.save!
      csv_model = CsvModel.first

      expect(csv_model.multivalue).to eq([ 'c', 'a', 'b' ])
    end

    it "should allow a single value to be appended to the column with <<" do
      m = CsvModel.new name: 'Harry', multivalue: [ 'c' ]

      expect(m.multivalue).to eq([ 'c' ])
      expect(m.multivalue_csv).to eq('c')

      m.save!
      csv_model = CsvModel.first

      expect(csv_model).not_to be_nil
      expect(csv_model.name).to eq('Harry')
      expect(csv_model.multivalue_csv).to eq('c')
      expect(csv_model.multivalue).to eq([ 'c' ])

      csv_model.multivalue << 'a'
      csv_model.save!
      csv_model = CsvModel.first

      expect(csv_model.multivalue).to eq([ 'c', 'a' ])
    end

  end

end
