require_relative '../spec_helper'
require_relative '../../lib/multipage-html5-converter'

describe 'multipage html5 converter' do
  let(:converter) { MultipageHtml5Converter.new('', {}) }

  before do
    @output = render_string input, converter: converter
  end

  context 'document with two sections' do
    let(:input)  do
      <<-EOS
= Document Title
Author Name


== Section One
Sample paragraph


== Section Two
Another paragraph
        EOS
    end

    it 'must create two sub documents for the sections' do
      converter.section_documents.size.must_equal 2
    end

    it 'must have two links in TOC' do
      assert_xpath '//p', @output, 2
    end

  end

  context 'section one references section two' do
    let(:input)  do
      <<-EOS
= Document Title
Author Name


== Section One
Please see <<two>>


[[two]]
== Section Two
Another paragraph
        EOS
    end

    it 'should replace the reference text with the section titel of the reference' do
      section_one_output = converter.section_documents.first.convert
      paragraph = retrieve_xpath '//*[@class="sect1"]/*[@class="sectionbody"]//p', section_one_output
      # this is really bad for the error message
      assert paragraph.first.text.include? "Section Two"
    end
  end
end
