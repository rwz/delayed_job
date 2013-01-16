class ActiveRecord::Base
  yaml_as 'tag:ruby.yaml.org,2002:ActiveRecord'

  def self.yaml_new(klass, tag, val)
    if val['pure']
      klass.new.tap do |model|
        val.each do |key, value|
          model.instance_variable_set "@#{key}", value
        end
      end
    else
      begin
        klass.unscoped.find(val['attributes'][klass.primary_key])
      rescue ActiveRecord::RecordNotFound
        raise Delayed::DeserializationError
      end
    end
  end

  def to_yaml(opts={})
    coder = {
      'new_record' => @new_record,
      'destroyed' => @destroyed,
      'pure' => @_use_pure_yaml_serialization
    }

    encode_with(coder)
    YAML.quick_emit(self, opts) do |out|
      out.map(taguri, to_yaml_style) do |map|
        coder.each { |k, v| map.add(k, v) }
      end
    end
  end

  def use_pure_yaml_serialization!
    @_use_pure_yaml_serialization = true
  end
end
