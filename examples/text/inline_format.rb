# encoding: utf-8
#
# This example shows how to use inline formatting
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate("inline_format.pdf") do |pdf|
  
  pdf.text("hello <strikethrough><b>world\nhow <i>are</i></b> you?</strikethrough> world, <u>how are you</u> now?",
       :inline_format => true)
  pdf.text("<font size='14'>left: </font>" + "hello <b>world <font name='Times-Roman' size='28'>how</font> <i>are</i></b> you? <font size='14'><b>Goodbye.</b></font> " * 8,
       :inline_format => true)
  pdf.text("right: " + "hello <b>world how <i>are</i></b> you? " * 2,
       :inline_format => true,
       :align => :right)
  pdf.text("center: " + "hello <b>world how <i>are</i></b> you? " * 2,
       :inline_format => true,
       :align => :center)
  pdf.text("\njustify: " + "hello <b>world <i>goodbye</i></b> " * 12 + "the end ",
       :inline_format => true,
       :align => :justify)
  pdf.text("\njustify: " + "hello world goodbye " * 12 + "the end ",
       :inline_format => true,
       :align => :justify)
  pdf.text("\njustify: " + "hello world goodbye " * 12 + "the end ",
       :align => :justify)

  
  pdf.text("<color rgb='00ff00'>link: <font size='24' character_spacing='7.5'>please make</font> <color rgb='#0000ff'><u><link href='http://wiki.github.com/sandal/prawn/'>this</link></u></color> clickable.</color> Here we have A<color rgb='#0000ff'><sup><link href='http://wiki.github.com/sandal/prawn/'>superscript</link></sup></color> link and A<color rgb='#0000ff'><sub><link href='http://wiki.github.com/sandal/prawn/'> subscript</link></sub></color> link.",
       :inline_format => true)
       
  pdf.text("<color c='100' m='0' y='0' k='0'><font size='24'>CMYK</font></color>",
       :inline_format => true)

  file = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
  pdf.font_families["Action Man"] = {
    :normal      => { :file => file, :font => "ActionMan" },
    :italic      => { :file => file, :font => "ActionMan-Italic" },
    :bold        => { :file => file, :font => "ActionMan-Bold" },
    :bold_italic => { :file => file, :font => "ActionMan-BoldItalic" }
  }

  pdf.font("Action Man")
  pdf.text("\nhello <b>world\nhow <i>are</i></b> you?",
           :inline_format => true)


  pdf.font("Helvetica")  



  class Highlight
    def initialize(options)
      @color = options[:color]
      @document = options[:document]
    end

    def render_behind(fragment)
      original_color = @document.fill_color
      @document.fill_color = @color
      @document.fill_rectangle(fragment.top_left,
                               fragment.width,
                               fragment.height)
      @document.fill_color = original_color
    end
  end

  class FragmentBorder
    def initialize(options)
      @radius = options[:radius]
      @connect_corners = options[:connect_corners]
      @document = options[:document]
    end

    def render_in_front(fragment)
      box = fragment.bounding_box
      if @connect_corners
        @document.stroke_polygon(fragment.top_left, fragment.top_right,
                                 fragment.bottom_right, fragment.bottom_left)
      end
      @document.stroke_circle_at(fragment.top_left, :radius => @radius)
      @document.stroke_circle_at(fragment.top_right, :radius => @radius)
      @document.stroke_circle_at(fragment.bottom_right, :radius => @radius)
      @document.stroke_circle_at(fragment.bottom_left, :radius => @radius)
    end
  end

  highlight_callback = Highlight.new(:color => 'ffff00', :document => pdf)
  border_callback = FragmentBorder.new(:radius => 2.5,
                                       :connect_corners => true,
                                       :document => pdf)
  pdf.formatted_text([
                      { :text => "\n" },
                      { :text => "hello   ",
                        :callback => highlight_callback },
                      { :text => "world",
                        :size => 24,
                        :character_spacing => 0,
                        :callback => [highlight_callback, border_callback] },
                      { :text => "   hello" }
                     ], :indent_paragraphs => 40, :character_spacing => -2)
                     
                     
  pdf.start_new_page
  
  pdf.bounding_box [100,600], :width => 200 do
    pdf.move_down 10
    pdf.text "The rain in spain falls mainly on the plains " * 5
    pdf.move_down 20
    pdf.stroke do
      pdf.line pdf.bounds.top_left,    pdf.bounds.top_right
      pdf.line pdf.bounds.bottom_left, pdf.bounds.bottom_right
    end
  end
  
  pdf.start_new_page
  
  pdf.add_dest("fit", pdf.dest_fit(1))
    
  pdf.add_dest("xyzoom!", pdf.dest_xyz(300, 400, 2, 1))
  
  pdf.add_dest("fit_rectangle", pdf.dest_fit_rect(90, 300, 160, 280, 1))
  
  pdf.add_dest("fit_bounds", pdf.dest_fit_bounds(2))
  
  
  pdf.text(%Q{<link anchor="fit"><u>We can go to page 1!</u></link>}, :inline_format => true)
      
  pdf.text(%Q{<link anchor="xyzoom!"><u>We can zoom to middle of page 1!(at least in some viewers like Acrobat)</u></link>}, :inline_format => true)

  pdf.text(%Q{<link anchor="fit_rectangle"><u>We can go to a rectangle on page 1!</u></link>}, :inline_format => true)

  pdf.text(%Q{<link anchor="fit_bounds"><u>We can go to the bounding box on page 2!</u></link>}, :inline_format => true)
  
end



