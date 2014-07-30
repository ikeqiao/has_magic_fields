require 'spec_helper'


describe HasMagicFields do

  context "on a single model" do
    before(:each) do
      @charlie = Person.create(name: "charlie")
    end

    after(:each) do
      @charlie.destroy!
    end

    it "initializes magic fields correctly" do
      expect(@charlie).not_to be(nil)
      expect(@charlie.class).to be(Person)
      expect(@charlie.magic_fields).not_to be(nil)
    end

    it "allows adding a magic field" do
      @charlie.create_magic_filed(:name => 'salary')
      expect(@charlie.magic_fields.length).to eq(1)
    end

    it "validates_uniqueness_of name in a object" do
      @charlie.create_magic_filed(:name => 'salary')
      before_fields_count = MagicField.count
      expect(@charlie.magic_fields.length).to eq(1)
      expect(lambda{@charlie.create_magic_filed(:name => 'salary')}).to raise_error
      expect(@charlie.magic_fields.length).to eq(1)
      after_fields_count = MagicField.count
      expect(before_fields_count).to eq(after_fields_count)
    end

    it "allows setting and saving of magic attributes" do
      @charlie.create_magic_filed(:name => 'salary')
      @charlie.salary = 50000
      @charlie.save
      @charlie = Person.find(@charlie.id)
      expect(@charlie.salary).not_to be(nil)
    end

    it "forces required if is_required is true" do
     @charlie.create_magic_filed(:name => "last_name", :is_required => true)
     expect(@charlie.save).to be(false)
     @charlie.last_name = "zongsi"
     expect(@charlie.save).to be(true)
    end
      
    it "allows datatype to be :date" do
      @charlie.create_magic_filed(:name => "birthday", :datatype => :date)
      @charlie.birthday = Date.today
      expect(@charlie.save).to be(true)
    end

    it "allows datatype to be :datetime" do
      @charlie.create_magic_filed(:name => "signed_up_at", :datatype => :datetime)
      @charlie.signed_up_at = DateTime.now
      expect(@charlie.save).to be(true)
    end

    it "allows datatype to be :integer" do
      @charlie.create_magic_filed(:name => "age", :datatype => :integer)
      @charlie.age = 5
      expect(@charlie.save).to be(true)
    end

    it "allows datatype to be :check_box_boolean" do
      @charlie.create_magic_filed(:name => "retired", :datatype => :check_box_boolean)
      @charlie.retired = false
      expect(@charlie.save).to be(true)
    end

    it "allows default to be set" do
      @charlie.create_magic_filed(:name => "bonus", :default => "40000")
      expect(@charlie.bonus).to eq("40000")
    end

    it "allows a pretty display name to be set" do
      @charlie.create_magic_filed(:name => "zip", :pretty_name => "Zip Code")
      expect(@charlie.magic_fields.last.pretty_name).to eq("Zip Code")
    end
  end

  context "in a parent-child relationship" do
    before(:each) do
      @account = Account.create(name:"important")
      @alice = User.create(name:"alice", account: @account )
      @sample = Sample.create(name:"TR", account: @account )
    end

    after(:each) do
      @sample.destroy!
      @alice.destroy!
      @account.destroy!
    end

    it "initializes magic fields correctly" do
      expect(@alice).not_to be(nil)
      expect(@alice.class).to be(User)
      expect(@alice.magic_fields).not_to be(nil)

      expect(@account).not_to be(nil)
      expect(@account.class).to be(Account)
      expect(@alice.magic_fields).not_to be(nil)
    end

    it "allows adding a magic field to the child" do
      @alice.create_magic_filed(:name => 'salary')
      expect(@alice.magic_fields.length).to eq(1)
      expect(lambda{@alice.salary}).not_to raise_error

      expect(lambda{@account.salary}).not_to raise_error
    end

    it "allows adding a magic field to the parent" do
      @account.create_magic_filed(:name => 'age')
      expect(lambda{@alice.age}).not_to raise_error
    end

    it "sets magic fields for all child models" do
      @bob = User.create(name:"bob", account: @account )
      @bob.create_magic_filed(:name => 'birthday')
      expect(lambda{@alice.birthday}).not_to raise_error
      @bob.birthday = "2014-07-29"
      expect(@bob.save).to be(true)
      expect(@account.birthday).to  be(nil)
      expect(@alice.birthday).to  be(nil)
      @alice.birthday = "2013-07-29"
      expect(@alice.save).to be(true)
      expect(@alice.birthday).not_to eq(@bob.birthday)
    end


    it "validates_uniqueness_of name in all models object" do
      @alice.create_magic_filed(:name => 'salary')
      before_fields_count = MagicField.count
      expect(@alice.magic_fields.length).to eq(1)
      expect(lambda{@alice.create_magic_filed(:name => 'salary')}).to raise_error
      expect(@alice.magic_fields.length).to eq(1)
      expect(before_fields_count).to eq(MagicField.count)
      
      @bob = User.create(name:"bob", account: @account )
      expect(lambda{@bob.create_magic_filed(:name => 'salary')}).to raise_error
      expect(lambda{@sample.create_magic_filed(:name => 'salary')}).not_to raise_error
      expect(lambda{@account.create_magic_filed(:name => 'salary')}).not_to raise_error

    end
  end
end
