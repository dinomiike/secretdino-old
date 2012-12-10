class User < ActiveRecord::Base
  attr_accessible :active, :address, :email, :name
end
