require 'ruby_myq'

module Agents
  class MyqAgent < Agent
    include FormConfigurable
    cannot_receive_events!
    default_schedule '12h'

    description <<-MD
      Allows for the control of a Chamberlain MyQ garage door.
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
      !recent_error_logs?
    end

    def complete_door_name
      system = create_system
      system.garage_doors.map { |door| {id: door.name, text: door.name} }
    end

    def check
      door = select_door(interpolated['door_name'])
      if interpolated['action'] == 'status'
        create_event :payload => status(door)
      elsif interpolated['action'] == 'open'
        open_door(door)
        create_event :payload => status(door)
      elsif interpolated['action'] == 'close'
        close_door(door)
        create_event :payload => status(door)
      elsif interpolated['action'] == 'toggle'
        toggle_door(door)
        create_event :payload => status(door)
      end
    end

    private

    def create_system
      system = RubyMyq::System.new(interpolated['email_address'],interpolated['password'])
    end

    def select_door(door_name)
      system = create_system()
      door = system.find_door_by_name(door_name)
    end

    def status(door)
      status = {
        'name' => door.name,
        'state' => door.status,
        'since' => door.status_since
      }
    end

    def close_door(door)
      door.close
    end

    def open_door(door)
      door.open
    end

    def toggle_door(door)
      if door.status == "open"
        door.close
      elsif door.status == "closed"
        door.open
      end
    end

  end
end
