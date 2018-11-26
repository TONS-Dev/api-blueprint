class ApiBlueprint::Collect::Renderer
  def parameter_table(params, param_definitions, level = 0)
    text = ''

    if level == 0
      text += "#### Parameters:\n\n"
      text += "Name | Type | Description\n"
      text += "-----|------|---------|------------\n"
    end

    params.deep_merge(param_definitions&.select{ |k,v| v.is_a?(Hash) && v.has_key?(:description)} || {}).each do |name, info|
      comment = ''
      if info[:type] == 'array'
        comment = "Params for each #{name.singularize}:"
      else
        comment = info[:description] || ''
      end


      text += "#{'[]' * level} #{name} | *#{info[:type]}*#{info[:example].present? ? " `Example: #{info[:example]}`" : ''} | #{comment}\n"

      if info[:type] == 'nested' || info[:type] == 'array'
        text += parameter_table(info[:params], param_definitions&.dig(name), level + 1)
      end
    end
    text += "\n" if level == 0

    # text += "#### Parameters:\n\n" if level == 0
    # text += params.collect do |name, info|
    #   if info[:type] == 'nested'
    #     "#{' ' * (level * 2)}- **#{name}**\n" +
    #       parameter_table(info[:params], level + 1)
    #   else
    #     "#{' ' * (level * 2)}- **#{name}** (#{info[:type]}, `#{info[:example]}`)"
    #   end
    # end.join("\n")
    # text += "\n\n" if level == 0

    text
  end

  def resource_header(content)
    "# Resource: #{content}\n\n"
  end

  def action_header(content)
    "## Action: #{content}\n\n"
  end

  def description_header(content=nil)
    desc = content ? content['description'] : nil
    o = "### Description:\n\n"
    if desc
      o << "\t#{desc}\n\n"
    end
    o
  end

  def signature(url, method)
    "#### Signature:\n\n**#{method}** `#{url}`\n\n"
  end

  def examples_header
    "### Examples:\n\n"
  end

  def example_header(content)
    "#### Example: #{content}\n\n"
  end

  def example_subheader(content)
    content = content.to_s.humanize + ':' if content.is_a?(Symbol)

    "##### #{content}\n\n"
  end

  def code_block(content)
    content = JSON.pretty_generate(content) if content.kind_of?(Array)

    content.split("\n").collect { |line| " " * 4 + line }.join("\n") + "\n\n"
  end
end
