require 'csv'

module Bank
  class Account
    attr_accessor :id, :initial_balance, :balance, :withdraw, :owner, :accounts, :open_date, :interest

  # Add an owner property to each Account to track information about who owns the account. The Account can be created with an owner.
    def initialize(id, initial_balance, open_date, owner="nil")
      @id = id
      @initial_balance = (initial_balance.to_f/100)
      @owner = owner
      @open_date = open_date
      @balance = assert_initial_balance(@initial_balance)
      @interest = interest

      puts "Account initialized."
      check_balance
    end#of initialize

    def assert_initial_balance (initial_balance, msg="You must start with a positive initial balance.", minimum_balance = 0)
      if initial_balance <  minimum_balance
        raise Exception.new(msg)
      else
         return balance = initial_balance
      end
    end

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

    def withdraw (money_withdraw, minimum_balance = 0, fee = 0)
      puts "WITHDRAWAL"
      if fee != 0
        puts "FYI: There is a $#{fee} fee if this transaction processes."
      end
        check_balance
        withdraw_tot = (money_withdraw + fee)
      if (balance - withdraw_tot) < minimum_balance
        puts "Sorry, you do not have enough money to withdraw $#{sprintf "%.2f",money_withdraw}."
        check_balance
        return balance
      else
        puts "You withdrew $#{sprintf "%.2f", money_withdraw}"
        @balance = (balance - withdraw_tot)
        check_balance
        return(balance - withdraw_tot)
      end
    end#of withdraw

    def deposit (money_deposit)
      puts "DEPOSIT"
      puts "You deposited $#{sprintf "%.2f", money_deposit}"
      @balance = (balance + money_deposit)
      check_balance
      return(balance + money_deposit)
    end#of deposit

    def check_balance
      puts "Your balance is: $#{sprintf "%.2f", @balance} "
      return @balance
    end#of check_balance

  #add_interest(rate): Calculate the interest on the balance and add the interest to the balance. Return the interest that was calculated and added to the balance (not the updated balance). Input rate is assumed to be a percentage (i.e. 0.25). The formula for calculating interest is balance * rate/100. Example: If the interest rate is 0.25% and the balance is $10,000, then the interest that is returned is $25 and the new balance becomes $10,025.

  #I moved this into the parent class, so that I could call it on both the Savings Account and the Money MarketAccount child classes because those accounts have the same way of calculating interest.
      def add_interest(rate = 0.25)
        interest = balance * rate/100
        @balance = balance + interest
        puts "You earned $#{sprintf "%.2f", interest} in interest."
        check_balance
        return interest
      end#of add_interest method
  end#of class

#Create a SavingsAccount class which should inherit behavior from the Account class.
  class SavingsAccount < Account

  #The initial balance cannot be less than $10. If it is, this will raise an ArgumentError
    def assert_initial_balance (initial_balance, msg="You must start with at least a $10 balance.", minimum_balance = 10)
      super
    end#assert_initial_balance

  #Updated withdrawal functionality: Each withdrawal 'transaction' incurs a fee of $2 that is taken out of the balance. Does not allow the account to go below the $10 minimum balance - Will output a warning message and return the original un-modified balance
    def withdraw (money_withdraw, minimum_balance = 10, fee = 2)
      super
    end#of withdraw

  end#of SavingsAccount class

#Create a CheckingAccount class which should inherit behavior from the Account class.
  class CheckingAccount < Account
    attr_accessor :check_count

    def initialize(id, initial_balance, open_date, owner="nil")
      super
      @check_count = 0
    end

#Each withdrawal 'transaction' incurs a fee of $1 that is taken out of the balance. Returns the updated account balance. Does not allow the account to go negative. Will output a warning message and return the original un-modified balance.
    def withdraw (money_withdraw, minimum_balance = 0, fee = 1)
      super
    end#of withdraw

#withdraw_using_check(amount): The input amount gets taken out of the account as a result of a check withdrawal. Returns the updated account balance. Allows the account to go into overdraft up to -$10 but not any lower. The user is allowed three free check uses in one month, but any subsequent use adds a $2 transaction fee
    def withdraw_using_check(amount)
      puts "WITHDRAWAL USING CHECK"
      puts "You have withdrawn using checks #{check_count} time(s) this month."
      if check_count < 3
        puts "You still have #{3-check_count} free withdrawal(s) using checks."
        withdraw(amount, -10, 0)
      else
         puts "You have exceeded 3 free withdrawals using checks. If the transaction processes, you will be charged a $2 fee."
         withdraw(amount, -10, 2)
      end#of conditional to see how many checks they've used so far
      @check_count += 1
    end#of withdraw_using_check method

#reset_checks: Resets the number of checks used to zero
    def reset_checks
      @check_count = 0
    end

#To protect the CheckingAccount child class from having the functionality of adding interest, I overrode that method from the parent class here just in case someone tried to call it.
    def add_interest(rate = 0)
      puts "ERROR: This type of checking account does not earn interest."
      return
    end#of add_interest method

  end#of CheckingAccount Class

#Create a MoneyMarketAccount class which should inherit behavior from the Account class.
  class MoneyMarketAccount < Account
    attr_accessor :transaction_count, :account_frozen
    def initialize(id, initial_balance, open_date, owner="nil")
      super
      @transaction_count = 0
      @account_frozen = false
    end

#The initial balance cannot be less than $10,000 - this will raise an ArgumentError
    def assert_initial_balance (initial_balance, msg="You must start with at least a $10,000 balance.", minimum_balance = 10000)
        super
    end#assert_initial_balance

#A maximum of 6 transactions (deposits or withdrawals) are allowed per month on this account type
    def transaction_count
      puts "You have made #{@transaction_count} transaction(s) this month. You have #{6-@transaction_count} transaction(s) remaining."
    end
#reset_transactions: Resets the number of transactions to zero
    def reset_transactions
      @transaction_count = 0
      puts "*****It's a new month. You have 6 transactions remaining this month.*****"
    end

#Updated withdrawal logic: If a withdrawal causes the balance to go below $10,000, a fee of $100 is imposed and no more transactions are allowed until the balance is increased using a deposit transaction. Each transaction will be counted against the maximum number of transactions
    def withdraw (money_withdraw, minimum_balance = 0, fee = 100)
      if @transaction_count < 6
        if @account_frozen == true
          puts "WITHDRAWAL"
          puts "Sorry, your account is frozen."
        else
          super
            @transaction_count += 1
            transaction_count

           if @balance < 10000
             account_freeze
           end
        end #of conditional to see if the account is frozen
      else
        puts "WITHDRAWAL"
        puts "This transaction did not process because you can not exceed your 6 transaction limit for the month."
      end#of conditional to see if transaction limit is met
    end#of withdraw

    def account_freeze
        @account_frozen = true
        puts "Your account has been frozen until you deposit money such that your account contains at least $10,000."
    end
#Updated deposit logic: Each transaction will be counted against the maximum number of transactions. Exception to the above: A deposit performed to reach or exceed the minimum balance of $10,000 is not counted as part of the 6 transactions.
      def deposit(money_deposit)
        if @transaction_count < 6
          super
          if (@balance - money_deposit) >= 10000 #If the balance before the deposit was more than or equal $10,000; if your account wasn't frozen.
            @transaction_count += 1
          end#of conditional

          if @balance > 10000
            @account_frozen = false
          end#of conditional
        transaction_count
        else
          puts "DEPOSIT"
          puts "This transaction did not process because you can not exceed your 6 transaction limit for the month."
        end
      end#of deposit method

#add_interest(rate): Calculate the interest on the balance and add the interest to the balance. Return the interest that was calculated and added to the balance (not the updated balance). Note** This is the same as the SavingsAccount interest.


  end#of MoneyMarketAccount class


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

# ------practice runs from wave 3 ------------------

savings1 = Bank::SavingsAccount.new(4168, 30000, "March 8, 2015")
reg1 = Bank::Account.new(1234, 50000, "Dec. 25, 2000")

#Let's try one with an intial value less than 10... it worked!
#savings2 = Bank::SavingsAccount.new(8679, 300, "February 4, 1990")

#Withdraw tests with amounts that will leave the account with more than the minimum balance
reg1.withdraw(200)
savings1.withdraw(100)

#Withdraw tests with amounts that will throw errors
reg1.withdraw(1000000)
savings1.withdraw(100000)

#Add interest in the savings account
savings2 = Bank::SavingsAccount.new(3456, 20000, "March 17, 2014")
savings2.add_interest

#Make a new checking account and withdraw a valid amount
checking1 = Bank::CheckingAccount.new(9867, 10000, "October 31, 1988")
checking1.withdraw(20)
#Withdraw too much from the checking account
checking1.withdraw(80)

#Withdraw using checks
checking1.withdraw_using_check(10)
checking1.withdraw_using_check(20)
checking1.withdraw_using_check(30)
checking1.withdraw_using_check(10)
checking1.withdraw_using_check(50)

#reset check count, deposit so we can take more out
checking1.reset_checks
checking1.deposit(1000)
checking1.withdraw_using_check(10)
checking1.withdraw_using_check(20)
checking1.withdraw_using_check(30)
checking1.withdraw_using_check(10)
checking1.withdraw_using_check(50)

#MoneyMarketAccount tests
moneymarket1 = Bank::MoneyMarketAccount.new(3456, 9000000, "August 8, 1967")
moneymarket1.withdraw(5000)
moneymarket1.withdraw(84000)
moneymarket1.withdraw(700)
moneymarket1.deposit(10000)
moneymarket1.withdraw(500)
moneymarket1.withdraw(400)
moneymarket1.deposit(800)
moneymarket1.deposit(900)
moneymarket1.deposit(700)
#Try to deposit after reaching the transaction limit
moneymarket1.deposit(1000)
#Try to withdraw after reaching the transaction limit
moneymarket1.withdraw(500)
#Reset the transaction_count
moneymarket1.reset_transactions
#Deposit after the reset
moneymarket1.deposit(800)
#Withdraw after the reset
moneymarket1.withdraw(400)
#Calculate interest for the MoneyMarketAccount
moneymarket1.add_interest

checking1.add_interest

# ------practice runs from wave 2 ------------------
# Bank::Account.create_accounts_from_csv
# Bank::Account.all
# Bank::Account.find("1212")
#
# Bank::Owner.create_owners_from_csv
# Bank::Owner.all
# Bank::Owner.find("24")
#
# Bank::Account.add_owner_ids #<--- this loops through the account_owners.csv file and the accounts and if the account id matches, the corresponding owner id is added into the account information
# Bank::Account.all #<----- owner ids now display with the rest of the account information

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
