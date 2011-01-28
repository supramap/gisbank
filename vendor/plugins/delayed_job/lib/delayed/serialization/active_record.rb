class ActiveRecord::Base
  yaml_as "tag:ruby.yaml.org,2002:ActiveRecord"

  def self.yaml_new(klass, tag, val)
    klass.find(val['attributes']['id'])
  rescue ActiveRecord::RecordNotFound
    raise Delayed::DeserializationError
  end

  def to_yaml_properties
    ['@attributes']
  end
end
