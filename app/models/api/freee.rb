class Api::Freee
  def initialize(instance = nil)
    unless instance.present?
      instance = Instance.find_by(provider_name: 'freee')
    end
    @instance = instance
  end

  def login

  end
end
