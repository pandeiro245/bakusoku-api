class Datum < ApplicationRecord
  belongs_to :instance
  delegate :provider_name, to: :instance

  def requests
    return {} unless req.present?
    structure(JSON.parse(req))
  end

  def responses
    return {} unless res.present?
    structure(JSON.parse(res))
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
      res = node.class.to_s
      return 'Unknown' if ['NilClass'].include?(res)
      return 'Number'  if ['Fixnum'].include?(res)
      return 'Boolean' if ['TrueClass', 'FalseClass'].include?(res)
      return res
    end
  end
end

