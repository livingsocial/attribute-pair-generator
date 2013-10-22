# Attribute Pair Generator

* Easily generate form fields and object information fields with labels.
* Maintain consistent form structure without lots of html overhead:

Using APG, this...

    <% apg = AttributePairGenerator.new(foo) %>
    <%= form_tag foo_path(foo.id), method: :put do -%>
      <dl>
        <%= apg.text_field(attr: :title, help: "the title of your foo") %>
        <%= apg.date(attr: :starts_at) %>
        <%= apg.plain_text(attr: :status) %>
      </dl>
    <% end %>

generates...

    <form accept-charset="UTF-8" action="/foo" method="post">
      <dl>
        <div class="attribute-pair">
          <dt>title</dt>
          <dd>
            <input id="title" name="title" type="text" value="bar">
            <span class="help-inline">the title of your foo</span>
          </dd>
        </div>
        <div class="attribute-pair">
          <dt>starts at</dt>
          <dd>
            <input class="datepicker" id="starts_at" name="starts_at" type="text" value="2013-10-30 05:00:00 +0000">
            <span class="help-inline"></span>
          </dd>
        </div>
        <div class="attribute-pair">
          <dt>status</dt>
          <dd>
            approved
            <span class="help-inline"></span>
          </dd>
        </div>
      </dl>
    </form>

## Installation

Add this line to your application's Gemfile:

    gem 'attribute_pair_generator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attribute_pair_generator

## Common Usage

### Call any of the apg methods, and pass in a hash of options, common options include:

* *attr*: using this option alone, you get the label to be a humanized version of the attr, and the value to be the attr called on the initialized object (if it exists)
* *label*: override the label
* *value*: override the value
* *help*: help text shown after the value
* *field_options*: pass in options to the `content_tag` for the main desired element (e.g. <a> tag, input, textarea, checkbox)
* *dd_options*: pass in options to the `content_tag` for the dd (value)
* *prefix*: give a prefix to input elements' names and values
* *disabled*: disable the input element or link

## Examples

### link

    apg.link(title: "foo", url: "http://example.com")

### plain text

    apg.plain_text(label: 'contract dates', value: date_field_range('contract', 'contract'))

### date (can be used with jqueryui datepicker)

    apg.date(attr: :starts_at)

### select dropdown

    apg.select(attr: :lead_editor, value: editor_id, collection: [["Tom", 0], ["Dick", 1], ["Harry", 2]])

### checkbox

    apg.checkbox(attr: :ops_complete, disabled: !can_mark_ops_complete?)

### text field

    apg.text_field(attr: :long_title)
    apg.text_field(prefix: 'tax', attr: :id, value: '', disabled: true)

### text area

    apg.text_area(attr: :email_addresses, value: email_addresses.join("\n"), help: "Email addresses. One per line")

### radio buttons

    apg.radio(attr: :review_source, collection: [[nil, 'none'], 'Review Site'], dd_options: {class: 'horizontal-layout'})

## Authors

* Andrew Thal <andrew.thal@livingsocial.com>
* Jeff Whitmire <jeff.whitmire@livingsocial.com>

## License

Attribute Pair Generator is released under the [MIT License](http://www.opensource.org/licenses/MIT).
