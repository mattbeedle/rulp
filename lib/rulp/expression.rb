##
# An LP Expression. A mathematical expression.
# Can be a constraint or can be the objective function of a LP or MIP problem.
##
class Expressions
  attr_accessor :expressions
  def initialize(expressions)
    @expressions = expressions
  end

  def to_s
    as_str = @expressions[0].to_s
    as_str = as_str[1] == '+' ? as_str[3..-1] : as_str.dup
    (@expressions.length - 1).times do |i|
      as_str << @expressions[i + 1].to_s
    end
    as_str
  end

  def variables
    @expressions.map(&:variable)
  end

  [:==, :<, :<=, :>, :>=].each do |constraint_type|
    define_method(constraint_type){|value|
      Constraint.new(self, constraint_type, value)
    }
  end

  def -@
    -self.expressions[0]
    self
  end

  def -(other)
    other = -other
    self + other
  end

  def +(other)
    Expressions.new(self.expressions + Expressions[other].expressions)
  end

  def self.[](value)
    case value
    when LV then Expressions.new([Fragment.new(value, 1)])
    when Fragment then Expressions.new([value])
    when Expressions then value
    end
  end

  def evaluate
    self.expressions.map(&:evaluate).inject(:+)
  end
end

##
# An expression fragment. An expression can consist of many fragments.
##
class Fragment
  attr_accessor :lv, :operand

  def initialize(lv, operand)
    @lv = lv
    @operand = operand
  end

  def +(other)
    return Expressions.new([self] + Expressions[other].expressions)
  end

  def -(other)
    self.+(-other)
  end

  def *(value)
    Fragment.new(@lv, @operand * value)
  end

  def /(value)
    Fragment.new(@lv, @opterand / value)
  end

  def evaluate
    if [TrueClass,FalseClass].include? @lv.value.class
      @operand * (@lv.value ? 1 : 0)
    else
      @operand * @lv.value
    end
  end

  def -@
    @operand = -@operand
    self
  end

  def variable
    @lv
  end

  [:==, :<, :<=, :>, :>=].each do |constraint_type|
    define_method(constraint_type){|value|
      Constraint.new(Expressions.new(self), constraint_type, value)
    }
  end

  def to_s
    @as_str ||= begin
      case @operand
      when -1 then " - #{@lv}"
      when 1 then " + #{@lv}"
      when ->(op){ op < 0} then " - #{@operand.abs} #{@lv}"
      else " + #{@operand} #{@lv}"
      end
    end
  end
end