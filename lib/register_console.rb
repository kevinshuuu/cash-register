require_relative './register'

class RegisterConsole
  attr_reader :register
  def initialize
    @register = Register.new
  end

  def start
    puts 'ready'
    while true do
      print '> '
      input = gets.chomp
      input_arr = input.split(' ')
      case input_arr.first
      when 'show'
        show
      when 'put'
        put(input_arr[1..-1].map(&:to_i))
        show
      when 'take'
        take(input_arr[1..-1].map(&:to_i))
        show
      when 'change'
        change(input_arr[1].to_i)
      when 'quit'
        puts 'bye'
        exit
      end
    end
  end

  def show
    puts "$#{@register.total} #{@register.bills.join(' ')}"
  end

  def put(bills)
    begin
      @register.put(bills)
    rescue Register::ArgumentError => e
      puts e.message
    end
  end

  def take(bills)
    begin
      @register.take(bills)
    rescue Register::ArgumentError => e
      puts e.message
    end
  end

  def change(amount)
    begin
      change = @register.change(amount)
      puts change.join(' ')
    rescue Register::InsufficientBillsError
      puts 'sorry'
    end
  end
end
