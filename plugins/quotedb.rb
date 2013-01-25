class QuoteDb
  KEY ||= :quotedb_grabs

  def initialize(plugin)
    @plugin = plugin
  end

  def grab(name)
    if msg = @plugin.chat_history(:from => name).first
      with_quotes do |quotes|
        quotes << { :who => msg.from_name, :what => msg.text }
      end
    end
  end

  def quote(name)
    Quote.new(quotes_for(name).last)
  end

  def random_quote(name)
    Quote.new(quotes_for(name).sample)
  end

  private

  def quotes_for(name)
    with_quotes do |quotes|
      quotes.select do
        |msg| msg[:who] =~ /#{name}/i
      end
    end
  end

  def with_quotes(&block)
    Basil::Storage.with_storage do |store|
      yield(store[KEY] ||= [])
    end
  end

  class Quote
    def initialize(options)
      @who  = options[:who]
      @what = options[:what]
    end

    def to_s
      "<#@who> #@what"
    end
  end
end

Basil.respond_to(/^grab (.+)/) do

  @msg.say 'Ta-da!' if QuoteDb.new(self).grab(@match_data[1])

end

Basil.respond_to(/^q(uote)? (.+)/) do

  @msg.say QuoteDb.new(self).quote(@match_data[2])

end

Basil.respond_to(/^rq(uote)? (.+)/) do

  @msg.say QuoteDb.new(self).random_quote(@match_data[2])

end
