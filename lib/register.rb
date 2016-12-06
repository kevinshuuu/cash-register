class Register
  class InsufficientBillsError < StandardError; end

  DENOMINATIONS = [20, 10, 5, 2, 1]

  attr_accessor :bills

  def initialize
    @bills = [0, 0, 0, 0, 0]
  end

  def put(bills)
    raise ArgumentError, "Cannot put or take a negative amount of bills" if bills.any? { |b| b < 0 }

    bills.each_with_index { |bill, idx| @bills[idx] += bill }
  end

  def take(bills)
    raise ArgumentError, "Cannot put or take a negative amount of bills" if bills.any? { |b| b < 0 }

    #make deep copy of @bills in case we need to restore the state
    old_bills = @bills.dup

    bills.each_with_index do |bill, idx|
      @bills[idx] -= bill

      if @bills[idx] < 0
        #restore state if a certain denomination's count is less than 0
        @bills = old_bills
        raise InsufficientBillsError, "Tried to take more $#{DENOMINATIONS[idx]} bills than available"
      end
    end
  end

  def change(amount)
    change_bills = change_helper(amount, @bills)
    raise InsufficientBillsError, "Invalid combination of denominations for the request amount of change" unless change_bills

    #take the bills that were used to make change out of the register
    take(change_bills)
    change_bills
  end

  def total
    total = 0

    @bills.each_with_index do |bill, idx|
      total += bill * DENOMINATIONS[idx]
    end

    total
  end

  #mostly used for more readable tests (ie, expect(register).to be_empty)
  def empty?
    total == 0
  end

  private

  def change_helper(amount, available_bills, taken_bills = [0, 0, 0, 0, 0])
    #amount = 0 is the base case of the recursion and if we reach this, we know the
    #bills we have taken should be valid
    if amount == 0
      return taken_bills
    else
      possible_change = []
      #iterate through the available bills and take the first largest bill that we can use
      available_bills.each_with_index do |available_bill, idx|
        if available_bill > 0 && amount >= DENOMINATIONS[idx]
          new_taken_bills = taken_bills.dup
          #take a bill
          new_taken_bills[idx] += 1

          new_available_bills = available_bills.dup
          #reduce the amount of that denomination available
          new_available_bills[idx] -= 1

          new_amount = amount - DENOMINATIONS[idx]
          #make a recursive call to the change_helper function to solve our new subproblem
          new_change = change_helper(new_amount, new_available_bills, new_taken_bills)

          possible_change << new_change if new_change
        end
      end

      #return the combination of denominations that requires the least number of bills
      return possible_change.min { |a, b| a.inject(:+) <=> b.inject(:+) }
    end
  end
end
