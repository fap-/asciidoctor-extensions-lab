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

  context 'top level section one references top level section two' do
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

    it 'should point to the html file created for the referenced section' do
      section_one_output = converter.section_documents.first.convert
      paragraph = retrieve_xpath '//*[@class="sect1"]/*[@class="sectionbody"]//p', section_one_output

      paragraph.children[1].attributes['href'].value.must_equal 'two.html#two'
    end
  end

  context 'sub section reference to different chunk' do
    let(:input)  do
      <<-EOS
= Document Title
Author Name


== Section One
Please see <<twosub>>


[[two]]
== Section Two
Another paragraph

[[twosub]]
=== Subsection of Two
        EOS
    end

    it 'should replace the reference text with the section titel of the reference' do
      section_one_output = converter.section_documents.first.convert
      paragraph = retrieve_xpath '//*[@class="sect1"]/*[@class="sectionbody"]//p', section_one_output

      assert paragraph.first.text.include? "Subsection of Two"
    end

    it 'should point to the html file created for the referenced section' do
      section_one_output = converter.section_documents.first.convert
      paragraph = retrieve_xpath '//*[@class="sect1"]/*[@class="sectionbody"]//p', section_one_output

      paragraph.children[1].attributes['href'].value.must_equal 'two.html#twosub'
    end
  end

  context 'reference to different chunk with reftext' do
    let(:input)  do
      <<-EOS
= Document Title
Author Name


== Section One
Please see <<twosub, Other reftext>>


[[two]]
== Section Two
Another paragraph

[[twosub]]
=== Subsection of Two
        EOS
    end

    it 'should replace the reference text with the section titel of the reference' do
      section_one_output = converter.section_documents.first.convert
      paragraph = retrieve_xpath '//*[@class="sect1"]/*[@class="sectionbody"]//p', section_one_output

      assert paragraph.first.text.include? "Other reftext"
    end

    it 'should point to the html file created for the referenced section' do
      section_one_output = converter.section_documents.first.convert
      paragraph = retrieve_xpath '//*[@class="sect1"]/*[@class="sectionbody"]//p', section_one_output

      paragraph.children[1].attributes['href'].value.must_equal 'two.html#twosub'
    end
  end
end
