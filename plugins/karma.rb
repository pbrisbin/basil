class Karma
  KEY = :karma_tracker

  def initialize(word)
    @word = word
  end

  def increment!
    with_values { |v| v[word] += 1 }
  end

  def decrement!
    with_values { |v| v[word] -= 1 }
  end

  def value
    @value ||= with_values { |v| v[word] }
  end

  def to_s
    if value == 0
      "nuetral karma"
    elsif value > 0
      "positive karma (+#{value})"
    else
      "negative karma (#{value})"
    end
  end

  private

  attr_reader :word

  def with_values(&block)
    Basil::Storage.with_storage do |store|
      yield(store[KEY] ||= {})
    end
  end
end

# when foo-- or foo++ is mentioned in conversation, foo's karma is
# decremented or incremented.
Basil.watch_for(/(\w+)(--|\+\+)($|[!?.,:; ])/) {

  karma = Karma.new(@match_data[1])

  case @match_data[2]
  when '++' then karma.increment!
  when '--' then karma.decrement!
  end

}

Basil.respond_to(/^karma (\w+)/) {

  word  = @match_data[1]
  karma = Karma.new(word)

  @msg.reply "#{word} currently has #{karma}"

}.description = "report a word's current karma"
