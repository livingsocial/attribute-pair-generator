class AttributePairGenerator
  require 'action_view'
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper

  attr_accessor :output_buffer
  attr_reader :obj

  def initialize(init_obj = nil)
    @obj = init_obj
  end

  def link(options)
    content = link_to options[:title], options[:url], options[:field_options]
    render(content, options)
  end

  def plain_text(options)
    render(value(options), options)
  end

  def date(options)
    text_field_options = field_options(options)
    ((text_field_options[:class] ||= '') << ' datepicker').strip!

    content = text_field_tag attribute(options), value(options), text_field_options
    render(content, options)
  end

  def select(options)
    content = select_tag attribute(options), options_for_select(options[:collection], value(options)), field_options(options, prompt: options[:prompt], include_blank: options[:include_blank])
    render(content, options)
  end

  def checkbox(options)
    hidden_tag = hidden_field_tag attribute(options), options[:unchecked_value].nil? ? false : options[:unchecked_value]
    checked_value = options[:checked_value] || true
    is_checked = value(options).to_s == checked_value.to_s
    content = hidden_tag + check_box_tag(attribute(options), checked_value, is_checked, field_options(options))
    render(content, options)
  end

  def text_field(options)
    content = text_field_tag attribute(options), value(options), field_options(options)
    render(content, options)
  end

  def text_area(options)
    content = text_area_tag attribute(options), value(options), field_options(options)
    render(content, options)
  end

  def radio(options)
    content = content_tag :ol, class: 'unstyled' do
      options[:collection].map do |element|
        if element.is_a?(Array)
          value = element[0]
          label = element[1]
        else
          value = label = element
        end
        content_tag :li do
          label_tag("#{attribute(options)}_#{value}", radio_button_tag(attribute(options), value || '', value == value(options), field_options(options)) + label, class: 'radio')
        end
      end.flatten.join("").html_safe
    end

    render(content, options)
  end

  private

  def field_options(options, overrides={})
    {disabled: options[:disabled], name: name(options)}.merge(overrides).merge(options.fetch(:field_options, {}))
  end

  def render(content, options)
    dt_content = options[:label] ? options[:label].to_s : options[:attr].to_s.humanize.downcase
    dd_content = content.to_s
    dd_content += content_tag(:span, class: "help-inline") { options[:help].to_s } if options[:help]
    content_tag(:dt) { dt_content } +
      content_tag(:dd, options[:dd_options]) { dd_content.html_safe }
  end

  def value(options)
    if options[:value]
      options[:value]
    elsif obj.respond_to?(options[:attr])
      obj.send(options[:attr])
    end
  end

  def name(options)
    if options[:prefix]
      "#{options[:prefix]}[#{options[:attr]}]"
    else
      options[:attr]
    end
  end

  def attribute(options)
    if options[:prefix]
      "#{options[:prefix]}_#{options[:attr]}"
    else
      options[:attr]
    end
  end
end
