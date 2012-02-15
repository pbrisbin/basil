module Basil
  class QuoteDb
    KMSG = :quotedb_messages
    KGRB = :quotedb_grabs

    class << self
      def log_message(msg)
        Storage.with_storage do |store|
          store[KMSG] ||= []
          store[KMSG] << { :who => msg.from_name, :what => msg.text }

          # semi-efficiently maintain a cap on this log
          while store[KMSG].length > 50
            store[KMSG].shift(15)
          end
        end
      end

      def grab(name)
        ret = false

        Storage.with_storage do |store|
          store[KMSG] ||= []
          store[KGRB] ||= []

          store[KMSG].reverse.each do |msg|
            if msg[:who] =~ /#{name}/i
              store[KGRB] << msg
              ret = true
              break
            end
          end
        end

        ret
      end

      def quote(name, random = false)
        ret = nil

        Storage.with_storage do |store|
          store[KGRB] ||= []

          grabs = store[KGRB].select { |msg| msg[:who] =~ /#{name}/i }

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
end

# keeps a log of the last 35-50 messages spoken in chat
Basil.log { Basil::QuoteDb.log_message(@msg) }

# grabs the last thing the named person said and stores it
Basil.respond_to(/^grab (.+)/) do
  Basil::QuoteDb.grab(@match_data[1]) ? says("got it!") : nil
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
