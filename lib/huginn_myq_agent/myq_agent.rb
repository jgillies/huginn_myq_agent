require 'ruby_myq'

module Agents
  class MyqAgent < Agent
    include FormConfigurable
    cannot_receive_events!
    default_schedule '12h'

    description <<-MD
      Add a Agent description here
    MD

    def default_options
      {
        'email_address' => '',
        'password' => '',
      }
    end

    form_configurable :email_address
    form_configurable :password
    form_configurable :door_name, roles: :completable
    form_configurable :action, type: :array, values: ['status', 'open', 'close', 'toggle']

    def validate_options
      if options['email_address'].blank?
        errors.add(:base, 'email address is required')
      end
      if options['password'].blank?
        errors.add(:base, 'password is required')
      end
      if options['door_name'].blank?
        errors.add(:base, 'door_name is required')
      end
      if options['action'].blank?
        errors.add(:base, 'action is required')
      end
    end

    def working?
      # Implement me! Maybe one of these next two lines would be a good fit?
      received_event_without_error?
    end

    def check
      door = select_door(interpolated['door_name'])
      if interpolated['action'] == 'status'
        create_event :payload => status(door.name)
      elsif interpolated['action'] == 'open'
        open_door(door)
        create_event :payload => status(door.name)
      elsif interpolated['action'] == 'close'
        close(door)
        create_event :payload => status(door.name)
      end
    end

    def create_system
      system = RubyMyq::System.new(interpolated['email_address'],interpolated['password'])
    end

    def select_door(door_name)
      system = create_system()
      door = system.find_door_by_name(door_name)
    end

    def status(door_name)
      door = select_door(door_name)
      status = {
        'state' => door.status,
        'since' => door.status_since
      }
      return status
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

    def complete_door_name
      system = create_system
      system.garage_doors.map { |door| {id: door.name, text: door.name} }
    end



#    def receive(incoming_events)
#    end
  end
end
