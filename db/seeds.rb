# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#

puts 'EMPTY THE MONGODB DATABASE'
Mongoid.master.collections.reject { |c| c.name =~ /^system/}.each(&:drop)

puts 'SETTING UP DEFAULT USER LOGIN'
user = Fabricate(:admin)
puts 'You can log in as ' << user.email << "/" << "testtest"
program = user.programs.first
Fabricate(:user, :first_name => "Test1", :password => "testtest", :programs => [program])
Fabricate(:user, :first_name => "Test2", :password => "testtest", :programs => [program])
Fabricate(:user, :first_name => "Test3", :password => "testtest", :programs => [program])

puts "You can log in as user0-user2@scoutforce.local/testtest"

program2 = Fabricate(:program, :name => "Other Program")

Fabricate(:user, :first_name => "Other",
  :last_name => "Coach", :email => "program2@scoutforce.local",
  :password => "testtest", :programs => [program2])

puts "You can log in to a different program as program2@scoutforce.local/testtest"
