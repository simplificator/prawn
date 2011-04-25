require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Transaction" do


  it "must remove a page created during a tx when tx is rolled back" do
    doc = PDF::Inspector::Page.analyze(TransactionSampleDocument.new.to_pdf)
    doc.pages.size.should == 2
  end

  it 'must properly number the pages' do
    doc = PDF::Inspector::Text.analyze(TransactionSampleDocument.new.to_pdf)
    doc.strings.include?("Page 1 of 2").should == true
    doc.strings.include?("Page 2 of 2").should == true
  end


end

class TransactionSampleDocument < Prawn::Document
  def to_pdf
    transaction do
      start_new_page
      rollback
    end


    repeat(:all, :dynamic => true) do
      text "Page #{page_number} of #{page_count}"
    end

    text "content of first page"
    start_new_page
    text "content of second page"

    render
  end
end
