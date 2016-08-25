require 'csv'

module Bank
  class Account
    attr_accessor :id, :initial_balance, :balance, :withdraw, :owner, :accounts, :open_date

  # Add an owner property to each Account to track information about who owns the account. The Account can be created with an owner.
    def initialize(id, initial_balance, open_date, owner="nil")
      @id = id
      @initial_balance = (initial_balance.to_f/100)
      @owner = owner
      @open_date = open_date

      assert_pos_initial_balance(@initial_balance)
      puts "Account initialized."
    end#of initialize

    def self.create_accounts_from_csv #<---- class method
      @@accounts = []
      csv_accounts = CSV.read("support/accounts.csv", 'r').each do |line|
      @@accounts << self.new(line[0], line[1], line[2])
      end#of do in create_accounts method
      return @@accounts
    end#of create_accounts_from_csv method

#self.all - returns a collection of Account instances, representing all of the Accounts described in the CSV. S
    def self.all #<---- class method
      puts "\nACCOUNTS"
      @@accounts.each do |account|
        puts "------------------------------"
        puts "acount id:#{account.id}
         \nstarting_balance: $#{account.initial_balance}
         \nopening date: #{account.open_date}"
         if account.owner != "nil"
           puts "\nowner id: #{account.owner}"
         end#of conditional
       end#of do
    end#of self.all

  #self.find(id) - returns an instance of Account where the value of the id field in the CSV matches the passed parameter
    def self.find(id)
           @@accounts.each do |account|
             if account.id == id
               puts "------------------------------"
               puts "The account associated with id #{id} is: #{account}"
               return account
             end #of do
           end#of conditional
    end#of self.find method

    def self.add_owner_ids
      csv_accounts_owners = CSV.read("support/account_owners.csv", 'r').each do |line|
          @@accounts.each do |account|
            if account.id == line[0]
               account.owner = line[1]
            end#conditional
          end#do accounts.each
        end#do csv read
    end#add owner method

    def assert_pos_initial_balance (initial_balance, msg="You must start with a positive initial balance.")
      if initial_balance <  0
        raise Exception.new(msg)
      else
         return balance = @initial_balance
      end
    end

    def withdraw (money_withdraw)
      if (balance - money_withdraw) < 0
        puts "Sorry, you do not have enough money to withdraw $#{sprintf "%.2f",money_withdraw}."
        check_balance
        return balance
      else
        puts "You withdrew $#{sprintf "%.2f", money_withdraw}"
        @balance = (balance - money_withdraw)
        check_balance
        return(balance - money_withdraw)
      end
    end#of withdraw

    def deposit (money_deposit)
      puts "You deposited $#{sprintf "%.2f", money_deposit}"
      @balance = (balance + money_deposit)
      check_balance
      return(balance + money_deposit)
    end#of deposit

    def check_balance
      puts "Your balance is: $#{sprintf "%.2f", @balance} "
      return @balance
    end#of check_balance
  end#of class

#Create an Owner class which will store information about those who own the Accounts.This should have info like name and address and any other identifying information that an account owner would have.
  class Owner
    attr :owners, :id, :last_name, :first_name, :street_address, :city, :state

    def initialize(id, last_name, first_name, street_address, city, state)
      @id = id
      @first_name = first_name
      @last_name = last_name
      @street_address = street_address
      @city = city
      @state = state

      #puts "Welcome to the bank, #{first_name}."
    end#of initialize method

    def self.create_owners_from_csv #<---- class method
      @@owners = []
      csv = CSV.read("support/owners.csv", 'r').each do |line|
            @@owners << self.new(line[0], line[1], line[2], line[3], line[4], line[5])
      end#of do in CSV
      return @@owners
    end#of self.create_owners_from_csv method

#self.all - returns a collection of Owner instances, representing all of the Owners described in the CSV.
    def self.all
      puts "\nOWNERS"
      @@owners.each do |owner|
        puts "------------------------------"
         puts "id: #{owner.id}
         \nname: #{owner.first_name} #{owner.last_name}
         \naddress: #{owner.street_address} #{owner.city},#{owner.state}"
       end#of do
    end#of self.all

#self.find(id) - returns an instance of Owner where the value of the id field in the CSV matches the passed parameter
    def self.find(id)
      @@owners.each do |owner|
        if owner.id == id
          puts "------------------------------"
          puts "The owner associated with id #{id} is: #{owner}"
          return owner
        end#of do
      end#of conditional to see if the id matches the owner id
    end#of self.find method
  end#of owner class
end#of module

Bank::Account.create_accounts_from_csv
Bank::Account.all
Bank::Account.find("1212")

Bank::Owner.create_owners_from_csv
Bank::Owner.all
Bank::Owner.find("24")

Bank::Account.add_owner_ids #<--- this loops through the account_owners.csv file and the accounts and if the account id matches, the corresponding owner id is added into the account information
Bank::Account.all #<----- owner ids now display with the rest of the account information



# ------practice runs from wave 1 ------------------
# owner1 = Bank::Owner.new("Sally", "1234 Mystery St. Seattle, WA", "sally@email.com")
# account1 = Bank::Account.new(432422, 100, owner1)
# account1.withdraw(20)
#
# puts "---------------------------------------------------"
# owner2 = Bank::Owner.new("Walter", "1600 Pennsylvania Ave Washington D.C", "walter@whitehouse.com")
# account2 = Bank::Account.new(737688, 500.98, owner2)
# account2.withdraw(1000)
# account2.deposit(60.76)

#to randomize id numbers
#(rand (111111..999999)
