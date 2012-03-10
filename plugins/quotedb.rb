module Basil
  class QuoteDb
    KEY ||= :quotedb_grabs

    def self.quote(name, random = false)
      ret = nil

      Storage.with_storage do |store|
        store[KEY] ||= []

        grabs = store[KEY].select { |msg| msg[:who] =~ /#{name}/i }

        unless grabs.empty?
          msg = if random && grabs.length > 1
                  grabs.shuffle.first
                else
                  grabs.last
                end

          ret = "<#{msg[:who]}> #{msg[:what]}"
        end
      end

      ret
    end
  end
end

# grabs the last thing the named person said and stores it
Basil.respond_to(/^grab (.+)/) do

  if msg = chat_history(:from => @match_data[1]).first
    Basil::Storage.with_storage do |store|
      quote = { :who => msg.from_name, :what => msg.text }

      store[Basil::QuoteDb::KEY] ||= []
      store[Basil::QuoteDb::KEY] << quote
    end

    says 'Ta-da!'
  end

end

# replies with the last quote grabbed for the named person
Basil.respond_to(/^q(uote)? (.+)/) do
  quote = Basil::QuoteDb.quote(@match_data[2])
  quote ? says(quote) : nil
end

# replies with a random quote grabbed for the named person
Basil.respond_to(/^rq(uote)? (.+)/) do
  quote = Basil::QuoteDb.quote(@match_data[2], true)
  quote ? says(quote) : nil
end
