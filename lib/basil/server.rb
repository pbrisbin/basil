module Basil
  class Server
    # called when the server has received an incoming message. returns
    # a reply (which the server should send) or nil.
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

    # called when the server is about to send any message for any
    # reason. return value doesn't matter.
    def sending_message(msg)

    end
  end
end
