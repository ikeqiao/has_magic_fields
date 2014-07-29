require 'spec_helper'


describe HasMagicFields do

  context "on a single model" do
    before(:each) do
      @charlie = Person.create(name: "charlie")
    end

    it "initializes magic fields correctly" do
      expect(@charlie).not_to be(nil)
      expect(@charlie.class).to be(Person)
      expect(@charlie.magic_fields).not_to be(nil)
    end

    it "allows adding a magic field" do
      @charlie.magic_fields.create(:name => 'salary')
      expect(@charlie.magic_fields.length).to be(1)
    end

    it "allows setting and saving of magic attributes" do
      @charlie.magic_fields.create(:name => 'salary')
      @charlie.name = "zhouzongsi"
      @charlie.salary = 50000
      @charlie.save
      @charlie = Person.find(@charlie.id)
      expect(@charlie.salary).not_to be(nil)
    end

    # it "forces required if is_required is true" do
    #  # TODO figure out why this fails
    #  @charlie.magic_fields.create(:name => "last_name", :is_required => true)
    #  expect(@charlie.save).to be(false)
    # end
      
    it "allows datatype to be :date" do
      @charlie.magic_fields.create(:name => "birthday", :datatype => :date)
      @charlie.birthday = Date.today
      expect(@charlie.save).to be(true)
    end

    it "allows datatype to be :datetime" do
      @charlie.magic_fields.create(:name => "signed_up_at", :datatype => :datetime)
      @charlie.signed_up_at = DateTime.now
      expect(@charlie.save).to be(true)
    end

    it "allows datatype to be :integer" do
      @charlie.magic_fields.create(:name => "age", :datatype => :integer)
      @charlie.age = 5
      expect(@charlie.save).to be(true)
    end

    it "allows datatype to be :check_box_boolean" do
      @charlie.magic_fields.create(:name => "retired", :datatype => :check_box_boolean)
      @charlie.retired = false
      expect(@charlie.save).to be(true)
    end

    it "allows default to be set" do
      @charlie.magic_fields.create(:name => "bonus", :default => "40000")
      expect(@charlie.bonus).to eq("40000")
    end

    it "allows a pretty display name to be set" do
      @charlie.magic_fields.create(:name => "zip", :pretty_name => "Zip Code")
      expect(@charlie.magic_fields.last.pretty_name).to eq("Zip Code")
    end
  end

  context "in a parent-child relationship" do
    before(:each) do
      @account = Account.create(name:"important")
      @alice = User.create(name:"alice", account: @account )
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
      @alice.magic_fields.create(:name => 'salary')
      expect(lambda{@alice.salary}).not_to raise_error
      expect(lambda{@account.salary}).not_to raise_error
    end

    it "allows adding a magic field to the parent" do
      @account.magic_fields.create(:name => 'age')
      expect(lambda{@alice.age}).not_to raise_error
    end

    it "sets magic fields for all child models" do
      @bob = User.create(name:"bob", account: @account )
      @bob.magic_fields.create(:name => 'birthday')
      expect(lambda{@alice.birthday}).not_to raise_error
    end
  end
end
