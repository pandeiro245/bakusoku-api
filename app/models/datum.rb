class Datum < ApplicationRecord
  belongs_to :instance

  def responses
    structure(JSON.parse(res))
  end

  def provider_name
    instance.provider_name
  end

  def structure(node)
    if node.class == Hash
      res = {}
      node.each do |key, val|
        res[key] = structure(val)
      end
      return res
    elsif node.class == Array
      return [structure(node.first)]
    else
      return node.class
    end
  end
end

