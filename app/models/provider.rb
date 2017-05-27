class Provider
  def initialize
    @structures = JSON.parse(File.open('providers.json').read)
  end

  def structures
    @structures
  end

  def structure(name)
    @structures[name]
  end

  def refresh
    Datum.all.each do |datum|
      pname = datum.provider_name.to_sym
      @structures[pname] ||= {}
      @structures[pname][datum.method] ||= {}
      @structures[pname][datum.method][datum.path] = {
        requests: datum.requests, 
        responses: datum.responses
      }
    end
    File.open("providers.json", 'w') { |file| file.write(@structures.to_json) }
  end
end

