require 'ruby_myq'

module Agents
  class MyqAgent < Agent
    include FormConfigurable
    default_schedule '12h'

    description <<-MD
      Add a Agent description here
    MD

    def default_options
      {
        'email_address' => '',
        'password' => ''
      }
    end

    form_configurable :email_address, type: :text
    form_configurable :password, type: :text
    form_configurable :door_name, type: :text
    form_configurable :action, type: :array, values: ['status', 'open', 'close', 'toggle']

    def validate_options
    end


    def 

    def working?
      # Implement me! Maybe one of these next two lines would be a good fit?
      # checked_without_error?
      # received_event_without_error?
    end

    private

    def create_system
      system = RubyMyq::System.new(:email_address,:password)
    end

    def select_door(door_name)
      system = create_system()
      door = system.find_door_by_name(door_name)
    end

    def status_since(door_name)
      door = select_door(door_name)
      status_since = door.status_since
    end

    def close_door(door_name)
      door = select_door(door_name)
      door.close
    end

    def open_door(door_name)
      door = select_door(door_name)
      door.open
    end

    def toggle_door(door_name)
      door = select_door(door_name)
      if door.status == "open"
        door.close
      elsif door.status == "closed"
        door.open
      end
    end


#    def check
#    end

#    def receive(incoming_events)
#    end
  end
end
