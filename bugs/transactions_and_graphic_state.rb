$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'prawn'
class PrawnAndTransaction < Prawn::Document

  def to_pdf
    fill_color "777777"
    save_graphics_state
    fill_color "999999"
    
    transaction do
      fill_color "888888"
      text "inside a transaction"
      start_new_page
      fill_color "888888"
      text "still inside a transaction"
      start_new_page
      start_new_page
      rollback
    end

    text "Page 1"
    start_new_page
    
    transaction do
      fill_color "888888"
      text "inside a transaction without a new page created"
      rollback
    end
    
    text "Page 2"
    start_new_page
    text "Page 3"

    File.open("with_transaction_rolled_back.pdf", 'wb') do |f|
      f.write render
    end
  end
end

PrawnAndTransaction.new(:optimize_objects => true).to_pdf 