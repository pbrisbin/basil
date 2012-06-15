module Basil
  class Server
    def dispatch_message(msg)
      ChatHistory.store_message(msg)

      if Config.dispatcher_type == :extended
        Dispatch.extended(msg)
      else
        Dispatch.simple(msg)
      end

    rescue Exception => ex
      # TODO: how to handle, send the error to channel? log and return
      # nil (letting other plugins have a chance)?
      $stderr.puts "Error dispatching #{msg.text}: #{ex}"

      nil
    end
  end
end
