# HasMagicFields
[![Gem Version](https://badge.fury.io/rb/has_magic_fields.png)](http://badge.fury.io/rb/has_magic_fields)
[![CI Status](https://travis-ci.org/ikeqiao/has_magic_fields.svg)](https://travis-ci.org/ikeqiao/has_magic_fields)

Allows the addition of custom "magic" fields and attributes on a per-model
or per-parent-model basis. This is useful for situations where custom fields are
required for a specific model or for multi-user, multi-account environments where
accounts can customize attributes for subordinate models.

## Installation

Add this line to your application's Gemfile:

    gem 'has_magic_fields'

And then execute:

    $ bundle


Create the migrations for MagicFileds and migrate:

    rails g has_magic_fields:install
    rake db:migrate

## Usage



### Model

Sprinkle a little magic into an existing model:

```ruby
class Person < ActiveRecord::Base
  include HasMagicFields::Extend
  has_magic_fields
end
```

Add magic fields to your model:

```ruby
@charlie = Person.create(:email => "charlie@example.com")
@charlie.create_magic_field(:name => "first_name")
```

Supply additional options if you have more specific requirements for your fields:

```ruby
@charlie.create_magic_field(:name => "last_name", :is_required => true)
@charlie.create_magic_field(:name => "birthday", :datatype => :date)
@charlie.create_magic_field(:name => "salary", :default => "40000", :pretty_name => "Yearly Salary")
```

The `:datatype` option supports: `:check_box_boolean`, `:date`, `:datetime`, `:integer`

Use your new fields just like you would with any other ActiveRecord attribute:

```ruby
@charlie.first_name = "Charlie"
@charlie.last_name = "Magic!"
@charlie.birthday = Date.today
@charlie.save
```

Find @charlie and inspect him:

```ruby
@charlie = User.find(@charlie.id)
@charlie.first_name #=> "Charlie"
@charlie.last_name  #=> "Magic!"
@charlie.birthday #=> #<Date: 4908497/2,0,2299161>
@charlie.salary     #=> "40000", this is from :salary having a :default
```

## Inherited Model

A child can inherit magic fields from a parent. To do this, declare the parent
as having magic fields:

```ruby
class Account < ActiveRecord::Base
  include HasMagicFields::Extend
  has_many :users
  has_magic_fields
end
@account = Account.create(:name => "BobCorp",:type_scoped => "User")
```

And declare the child as having magic fields :through the parent.

```ruby
class User < ActiveRecord::Base
  include HasMagicFields::Extend
  belongs_to :account
  has_magic_fields :through => :account
end
@alice = User.create(:name => "alice", :account => @account)
```

To see all the magic fields available for a type_scoped(User) child from its parent:

```ruby
@alice.magic_fields #=> [#<MagicColumn>,...]
```

To add magic fields, go through the parent or child:

```ruby
@alice.create_magic_field(...)
@account.create_magic_field(…,:type_scoped => "User")
```

All User children for a given parent will have access to the same magic fields:

```ruby
@alice.create_magic_field(:name => "salary")
@alice.salary = "40000"

@bob = User.create(:name => "bob", :account => @account)
# Magic! No need to add the column again!
@bob.salary = "50000"
```



###Different Model Inherited from The Samle Model
the other modle Inherited from Account

```ruby
class Product < ActiveRecord::Base
  include HasMagicFields::Extend
  belongs_to :account
  has_magic_fields :through => :account
end

@product = Product.create(:name => "car", :account => @account)
```
@product haven't salary magic field, @product.salary should raise NoMethodError

parent @account also haven't salary magic field

## Get All Magic Fields 
```ruby
@account.magic_fields #get all meagic_fields both self and children
@account.magic_fields_with_scoped #get all meagic_fields self
@account.magic_fields_with_scoped("User") #get all meagic_fields User model
```

##To Do

Here's a short list of things that need to be done to polish up this gem:

* more data_type sppuort
* Benchmark and optimize

Maintainers
===========

*  Davy Zhou([ikeqiao](http://github.com/ikeqiao))


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


Credits
=======

* Thank you to Brandon Keene for his original work making this plugin.
* Thank you to latortuga for his original work making this plugin. [has_magic_fields](https://github.com/latortuga/has_magic_columns.git)
