class Provider
  def initialize
    @structures = JSON.parse(File.open('providers.json').read)
  end

  def structure(name)
    @structures[name]
  end

  def refresh
    Datum.all.each do |datum|
      @structures[datum.provider_name.to_sym] ||= {}
      @structures[datum.provider_name.to_sym][datum.method] ||= {}
      @structures[datum.provider_name.to_sym][datum.method][datum.path] = {
        requests: {}, 
        responses: datum.responses
      }
    end
    File.open("providers.json", 'w') { |file| file.write(@structures.to_json) }
  end
end

