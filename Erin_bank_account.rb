puts "---------------------------------------------------------------------"

module Bank
  class Account
    attr :id, :initial_balance, :balance, :withdraw, :owner

  # Add an owner property to each Account to track information about who owns the account. The Account can be created with an owner.
    def initialize(id, initial_balance, owner)
      @id = id
      @initial_balance = initial_balance
      assert_pos_initial_balance(initial_balance)
      @balance = initial_balance
      @owner = owner

      puts "Account initialized."
      puts "Your id is: #{@id}.\nYour starting balance is $#{@initial_balance}."
    end#of initialize

    def assert_pos_initial_balance (initial_balance, msg="You must start with a positive initial balance.")
      if initial_balance <  0
        raise Exception.new(msg)
      else
         return balance = @initial_balance
      end
    end

    def withdraw (money_withdraw)
      if (balance - money_withdraw) < 0
        puts "Sorry, you do not have enough money to withdraw $#{money_withdraw}."
        check_balance
        return balance
      else
        puts "You withdrew $#{money_withdraw}"
        @balance = (balance - money_withdraw)
        check_balance
        return(balance - money_withdraw)
      end
    end#of withdraw

    def deposit (money_deposit)
      puts "You deposited $#{money_deposit}"
      @balance = (balance + money_deposit)
      check_balance
      return(balance + money_deposit)
    end#of deposit

    def check_balance
      puts "Your balance is: $#{@balance} "
      return @balance
    end#of check_balance
  end#of class

#Create an Owner class which will store information about those who own the Accounts.This should have info like name and address and any other identifying information that an account owner would have.
  class Owner
    attr :name, :address, :email

    def initialize(name, address, email)
      @name = name
      @address = address
      @email = email
      puts "Welcome to the bank, #{name}."
    end#of initialize method
  end#of owner class

end#of module

owner1 = Bank::Owner.new("Sally", "1234 Mystery St. Seattle, WA", "sally@email.com")
account1 = Bank::Account.new(432422, 100, owner1.name)
account1.withdraw(20)

puts "---------------------------------------------------------------------"
owner2 = Bank::Owner.new("Walter", "1600 Pennsylvania Ave Washington D.C", "walter@whitehouse.com")
account2 = Bank::Account.new(737688, 500, owner2.name)
account2.withdraw(200)
account2.deposit(1000)

#to randomize id numbers
#(rand (111111..999999)
