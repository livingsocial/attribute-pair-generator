require 'spec_helper'

describe AttributePairGenerator do
  let(:test_object) { double(id: 1, full_name: "foo bar", date: "2013-05-13", featured: true, scheduler: 2) }
  let(:subject) { AttributePairGenerator.new(test_object) }
  let(:generated) { Nokogiri::XML(subject.send(generator_method, generator_arguments)) }

  shared_examples 'a generated pair structure' do
    it { generated.css('div').should be_present }
    it { generated.css('div dt').should be_present }
    it { generated.css('div dd').should be_present }
  end

  shared_examples 'accepts standard options' do
    context 'if given a help option' do
      it 'creates a span with the help text' do
        generator_arguments[:help] = Faker::Lorem.sentence
        generated.css("div span.help-inline").text.should eq(generator_arguments[:help])
      end
    end

    context 'if no help text given' do
      it 'creates an empty help text area' do
        generator_arguments.keys.should_not include(:help)
        generated.css("div span.help-inline").text.should be_empty
      end
    end

    context 'if given a label option' do
      it 'uses the given label in the dt' do
        generator_arguments[:label] = Faker::Lorem.word
        generated.css("dt").text.should eq(generator_arguments[:label])
      end
    end

    context 'if no label option given' do
      it 'uses the attribute name for the label' do
        generator_arguments.keys.should_not include(:label)
        generated.css("dt").text.should eq(generator_arguments[:attr].to_s.humanize.downcase)
      end
    end

    context "if given dd_options" do
      let(:dd_options) { {class: 'special-fluffy-dd'} }
      it "uses those options on the dd element" do
        generator_arguments[:dd_options] = dd_options
        generated.css("dd").first.attributes["class"].value.should match /#{dd_options[:class]}/
      end
    end
  end

  shared_examples 'form field prefix generator' do
    context 'if a prefix option is given' do
      before do
        generator_arguments[:prefix] = 'foo'
      end

      it 'creates the id as prefix_attribute' do
        generated.css('dd').children.last['id'].should == "#{generator_arguments[:prefix]}_#{generator_arguments[:attr]}"
      end

      it 'creates the name as prefix[attribute]' do
        generated.css('dd').children.last['name'].should == "#{generator_arguments[:prefix]}[#{generator_arguments[:attr]}]"
      end

      it 'does not use the prefix in the label' do
        generated.css("dt").text.should eq(generator_arguments[:attr].to_s.humanize.downcase)
      end
    end

    context 'if not given a prefix option' do
      before do
        generator_arguments.keys.should_not include(:prefix)
      end

      it 'uses the attribute as the id' do
        generated.css('dd').children.last['id'].should == generator_arguments[:attr].to_s
      end

      it 'uses the attribute as the name' do
        generated.css('dd').children.last['id'].should == generator_arguments[:attr].to_s
      end
    end
  end

  shared_examples 'form field value generator' do
    context 'if a value option is given' do
      before do
        generator_arguments[:value] = '7337'
      end

      it 'uses the value given in the params' do
        node = generated.css('dd').children.first

        if node.has_attribute?('value')
          node['value'].should == generator_arguments[:value]
        else
          node.text.should match /#{generator_arguments[:value]}/
        end
      end
    end
  end

  describe '#obj' do
    its(:obj) { should eq(test_object) }
  end

  context 'information field generators' do
    describe '#plain_text' do
      let(:generator_method) { 'plain_text' }

      context 'with basic options' do
        let(:generator_arguments) { {attr: :id} }

        it_should_behave_like 'a generated pair structure'
        it_should_behave_like 'accepts standard options'

        it 'renders plain text in the dd' do
          generated.css("dd").text.should eq(test_object.id.to_s)
        end
      end
    end

    describe '#link' do
      let(:generator_method) { 'link' }
      let(:generator_arguments) { {title: "foo", url: "http://example.com"} }

      context 'with basic options' do
        it_should_behave_like 'a generated pair structure'
        it_should_behave_like 'accepts standard options'

        it 'renders a link in the dd' do
          generated.css("dd").children.first.node_name.should == 'a'
        end

        it 'uses the title as the text of the link' do
          generated.css("dd a").text.should eq("foo")
        end

        it 'uses the url as the target of the link' do
          generated.css("dd a").first.attributes["href"].value.should eq("http://example.com")
        end
      end

      context 'if given an extra field_options parameter' do
        before do
          generator_arguments[:field_options] = {class: 'findable_link'}
        end

        it 'sticks the extra options on the link element' do
          generated.css("dd a").first.attributes["class"].value.should match /#{generator_arguments[:field_options][:class]}/
        end
      end
    end
  end

  context 'form input generators' do
    describe '#date' do
      let(:generator_method) { 'date' }
      let(:generator_arguments) { {attr: :date} }

      context 'with basic options' do
        it_should_behave_like 'a generated pair structure'
        it_should_behave_like 'accepts standard options'
        it_should_behave_like 'form field prefix generator'
        it_should_behave_like 'form field value generator'

        it 'renders an input element in the dd' do
          generated.css("dd").children.first.node_name.should == 'input'
        end

        it 'rendered input element should have a text type' do
          generated.css("dd input").first['type'].should match /text/
        end

        it 'adds the datepicker class to work with jquery-ui datepicker' do
          generated.css("dd input").first['class'].should match /datepicker/
        end
      end

      context 'with extra classes pass in field_options' do
        before do
          generator_arguments[:field_options] = {class: 'flibberty'}
        end

        it 'should have both expected classes instead of overwriting' do
          generated.css("dd input").first['class'].should match /datepicker/
          generated.css("dd input").first['class'].should match /#{generator_arguments[:field_options][:class]}/
        end
      end
    end

    describe '#select' do
      let(:generator_method) { 'select' }
      let(:generator_arguments) { {attr: :scheduler, collection: [[1, "Tom"], [2, "Dick"], [3, "Harry"]]} }

      context 'with basic options' do
        it_should_behave_like 'a generated pair structure'
        it_should_behave_like 'accepts standard options'
        #it_should_behave_like 'form field generator'

        it 'renders a select element in the dd' do
          generated.css("dd").children.first.node_name.should == 'select'
        end

        context 'without the include_blank or prompt options' do
          it 'should not have a blank option element' do
            generated.css("dd select option").any? { |option| option.text.blank? }.should be_false
          end
        end

        context 'with the include_blank option' do
          before do
            generator_arguments[:include_blank] = true
          end

          it "includes a blank option first in the selector" do
            generated.css("dd select option")[0].text.should be_blank
            generated.css("dd select option")[0].attributes["value"].to_s.should be_blank
            generated.css("dd select option")[0].attributes["selected"].should be_blank
          end
        end

        context 'with the prompt option' do
          let(:prompt) { 'Pick Me' }
          before do
            generator_arguments[:prompt] = prompt
          end

          it "includes a blank option first in the selector" do
            generated.css("dd select option")[0].text.should == prompt
            generated.css("dd select option")[0].attributes["value"].to_s.should be_blank
            generated.css("dd select option")[0].attributes["selected"].should be_blank
          end
        end

        context 'with just an array of strings as the collection' do
          before do
            generator_arguments[:collection] = %w(Tom Dick Harry)
          end

          it "generates the expected selector" do
            generated.css("dd select option")[0].text.should eq("Tom")
            generated.css("dd select option")[1].text.should eq("Dick")
            generated.css("dd select option")[2].text.should eq("Harry")
          end
        end
      end
    end

    describe '#text_field' do
      let(:generator_method) { 'text_field' }

      context 'with basic options' do
        let(:generator_arguments) { {attr: :full_name} }

        it_should_behave_like 'a generated pair structure'
        it_should_behave_like 'accepts standard options'
        it_should_behave_like 'form field prefix generator'
        it_should_behave_like 'form field value generator'

        it 'renders an input element in the dd' do
          generated.css("dd").children.first.node_name.should == 'input'
        end

        it 'rendered input element should have a text type' do
          generated.css("dd input").first['type'].should match /text/
        end
      end
    end

    describe '#text_area' do
      let(:generator_method) { 'text_area' }

      context 'with basic options' do
        let(:generator_arguments) { {attr: :full_name} }

        it_should_behave_like 'a generated pair structure'
        it_should_behave_like 'accepts standard options'
        it_should_behave_like 'form field prefix generator'
        it_should_behave_like 'form field value generator'

        it 'renders a textarea element in the dd' do
          generated.css("dd").children.first.node_name.should == 'textarea'
        end

        it 'sets the value of the textarea to the attribute value' do
          generated.css("dd textarea").text.should match /#{test_object.send(generator_arguments[:attr])}/
        end
      end
    end

    describe '#radio' do
      let(:generator_method) { 'radio' }
      context 'with basic options' do
        let(:generator_arguments) { {attr: :scheduler, collection: [[1, "Tom"], [2, "Dick"], [3, "Harry"]]} }

        it_should_behave_like 'a generated pair structure'
        it_should_behave_like 'accepts standard options'
        # can't use the shared example here, this generates a collection of form elements
        #it_should_behave_like 'form field generator'

        context 'if a prefix option is given' do
          before do
            generator_arguments[:prefix] = 'foo'
          end

          it 'creates the id as prefix_attribute' do
            generated.css('dd input').each do |radio_element|
              radio_element['id'].should match /^#{generator_arguments[:prefix]}_#{generator_arguments[:attr]}_\d$/
            end
          end

          it 'creates the name as prefix[attribute]' do
            generated.css('dd input').each do |radio_element|
              radio_element['name'].should == "#{generator_arguments[:prefix]}[#{generator_arguments[:attr]}]"
            end
          end
        end

        context 'if given a one dimensional array for a collection' do
          before do
            generator_arguments[:collection] = %w(foo bar baz)
          end

          it 'should generate the same number of labels as the members of the collection' do
            generated.css("dd label").size.should == generator_arguments[:collection].size
          end

          it 'should generate a label for each member of the collection' do
            generated.css("dd label").collect(&:text).should == generator_arguments[:collection]
          end

          it 'should generate the same number of input elements as the members of the collection' do
            generated.css("dd input").size.should == generator_arguments[:collection].size
          end

          it 'should set the input value for each member of the collection' do
            generated.css("dd input").collect{|e| e.attr('value')}.should == generator_arguments[:collection]
          end
        end

        context 'if not given a prefix option' do
          before do
            generator_arguments.keys.should_not include(:prefix)
          end

          it 'uses the attribute as the id' do
            generated.css('dd input').each do |radio_element|
              radio_element['id'].should match /^#{generator_arguments[:attr]}_\d$/
            end
          end

          it 'uses the attribute as the name' do
            generated.css('dd input').each do |radio_element|
              radio_element['name'].should == generator_arguments[:attr].to_s
            end
          end
        end

        it 'should generate the same number of labels as the members of the collection' do
          generated.css("dd label").size.should == generator_arguments[:collection].size
        end

        it 'should generate a label for each member of the collection' do
          generated.css("dd label").collect(&:text).should == generator_arguments[:collection].collect { |m| m[1] }
        end

        it 'should generate the same number of input elements as the members of the collection' do
          generated.css("dd input").size.should == generator_arguments[:collection].size
        end

        it 'builds a proper label' do
          generator_arguments[:collection].each_with_index do |member, index|
            generated.css("dd label")[index].attributes["for"].value.should eq("#{generator_arguments[:attr]}_#{member[0]}")
            generated.css("dd label")[index].text.should eq(member[1])
          end
        end

        it 'builds a proper radio button' do
          generator_arguments[:collection].each_with_index do |member, index|
            generated.css("dd input")[index].attributes["name"].value.should eq(generator_arguments[:attr].to_s)
            generated.css("dd input")[index].attributes["value"].value.should eq(member[0].to_s)
          end
        end

        it 'correctly sets the checked attribute and value based on the right value' do
          generator_arguments[:collection].each_with_index do |member, index|
            if test_object.send(generator_arguments[:attr]) == member[0]
              generated.css("dd input")[index].attributes["checked"].value.should eq("checked")
            else
              generated.css("dd input")[index].should_not have_attribute("checked")
            end
          end
        end
      end
    end

    describe '#checkbox' do
      let(:generator_method) { 'checkbox' }
      let(:generator_arguments) { { attr: :featured } }

      context 'with basic options' do
        it_should_behave_like 'a generated pair structure'
        it_should_behave_like 'accepts standard options'
        it_should_behave_like 'form field prefix generator'

        it 'renders a hidden input element in the dd' do
          generated.css("dd").children.first.node_name.should == 'input'
          generated.css("dd").children.first['type'].should match /hidden/
        end

        it 'renders a checkbox input element in the dd' do
          generated.css("dd").children[1].node_name.should == 'input'
          generated.css("dd").children[1]['type'].should match /checkbox/
        end

        it 'has a false hiden value' do
          generated.css("dd input[type='hidden']").first['value'].should eq("false")
        end

        it 'can override a hidden value' do
          generator_arguments[:unchecked_value] = "foo"
          generated.css("dd input[type='hidden']").first['value'].should eq("foo")
        end

        context 'there is no explicitly set checked value' do
          let(:generator_arguments) { { attr: :featured } }
          it 'has a value of true' do
            generated.css("dd input").last['value'].should eq("true")
          end

          context 'when the value is true' do
            it 'sets the checked attribute' do
              generated.css("dd input").last.should have_attribute("checked")
            end
          end

          context 'when the value is not true' do
            before { test_object.stub(:featured).and_return(false) }
            it 'does not set the checked attribute' do
              generated.css("dd input").last.should_not have_attribute("checked")
            end
          end
        end

        context 'a checked value is specified' do
          let(:generator_arguments) { { attr: :featured, checked_value: 5 } }
          it 'has a value of the checked value' do
            generated.css("dd input").last['value'].should eq("5")
          end

          context 'when the value matches the checked_value' do
            before { test_object.stub(:featured).and_return(generator_arguments[:checked_value]) }
            it 'sets the checked attribute' do
              generated.css("dd input").last.should have_attribute("checked")
            end
          end

          context 'when the value does not matches the checked_value' do
            before { test_object.stub(:featured).and_return(nil) }
            it 'does not set the checked attribute' do
              generated.css("dd input").last.should_not have_attribute("checked")
            end
          end
        end
      end
    end
  end
end
