# encoding: utf-8
#
# stamp.rb : Implements a repeatable stamp
#
# Copyright October 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

require 'forwardable'

module Prawn

  class Stamp

    attr_accessor :document, :dictionary, :content
    
    extend Forwardable
    def_delegator :@document, :stamp_dictionary_registry

    def initialize(document, name)
      @document = document
      @dictionary = create_stamp_dictionary(name)
      @content = ""
    end

    def stamp_stream
      document.state.stamp = self

      document.open_graphics_state
      document.freeze_stamp_graphics
      yield if block_given?
      document.close_graphics_state

      dictionary.data[:Length] = content.length + 1
      dictionary << content

      document.state.stamp = nil
    end
    
    private

    def next_stamp_dictionary_id
      stamp_dictionary_registry.length + 1
    end

    def create_stamp_dictionary(name)
      raise Prawn::Errors::InvalidName if name.empty?
      raise Prawn::Errors::NameTaken unless stamp_dictionary_registry[name].nil?
      # BBox origin is the lower left margin of the page, so we need
      # it to be the full dimension of the page, or else things that
      # should appear near the top or right margin are invisible
      dictionary = document.ref!(:Type    => :XObject,
                                 :Subtype => :Form,
                                 :BBox    => [0, 0, document.state.page.dimensions[2], 
                                              document.state.page.dimensions[3]])

      dictionary_name = "Stamp#{next_stamp_dictionary_id}"

      stamp_dictionary_registry[name] = { :stamp_dictionary_name => dictionary_name,
                                          :stamp_dictionary      => dictionary }
      dictionary
    end

  end


  # The Prawn::Stamp module is used to create content that will be
  # included multiple times in a document. Using a stamp has three
  # advantages over creating content anew each time it is placed on
  # the page:
  #   i.   faster document creation
  #   ii.  smaller final document
  #   iii. faster display on subsequent displays of the repeated
  #   element because the viewer application can cache the rendered
  #   results
  #
  # Example:
  #   pdf.create_stamp("my_stamp") {
  #     pdf.fill_circle([10, 15], 5)
  #     pdf.draw_text("hello world", :at => [20, 10])
  #   }
  #   pdf.stamp("my_stamp")
  #
  class Document

    module Stamp
      
      def stamp_dictionary_registry
        @stamp_dictionary_registry ||= {}
      end
      
      def stamp_dictionary(name)
        raise Prawn::Errors::InvalidName if name.empty?
        if stamp_dictionary_registry[name].nil?
          raise Prawn::Errors::UndefinedObjectName
        end

        dict = stamp_dictionary_registry[name]

        dictionary_name = dict[:stamp_dictionary_name]
        dictionary = dict[:stamp_dictionary]
        [dictionary_name, dictionary]
      end

      # Creates a re-usable stamp named <tt>name</tt>
      #
      # raises <tt>Prawn::Errors::NameTaken</tt> if a stamp already
      # exists in this document with this name
      # raises <tt>Prawn::Errors::InvalidName</tt> if name.empty?
      #
      # Example:
      #   pdf.create_stamp("my_stamp") {
      #     pdf.fill_circle([10, 15], 5)
      #     pdf.draw_text("hello world", :at => [20, 10])
      #   }
      #
      def create_stamp(name, &block)
        Prawn::Stamp.new(self, name).stamp_stream(&block)
      end

      # Renders the stamp named <tt>name</tt> to the page
      # raises <tt>Prawn::Errors::InvalidName</tt> if name.empty?
      # raises <tt>Prawn::Errors::UndefinedObjectName</tt> if no stamp
      # has been created with this name
      #
      # Example:
      #   pdf.create_stamp("my_stamp") {
      #     pdf.fill_circle([10, 15], 5)
      #     pdf.text("hello world", :at => [20, 10])
      #   }
      #   pdf.stamp("my_stamp")
      #
      def stamp(name)
        dictionary_name, dictionary = stamp_dictionary(name)
        add_content "/#{dictionary_name} Do"
        state.page.xobjects.merge!(dictionary_name => dictionary)
      end

      # Renders the stamp named <tt>name</tt> at a position offset from
      # the initial coords at which the elements of the stamp was
      # created
      #
      # Example:
      #   pdf.create_stamp("circle") do
      #     pdf.fill_circle([0, 0], 25)
      #   end
      #   # draws a circle at 100, 100
      #   pdf.stamp_at("circle", [100, 100])
      #
      # See stamp() for exceptions that might be raised
      #
      def stamp_at(name, point)
        translate(point[0], point[1]) { stamp(name) }
      end
      
      def freeze_stamp_graphics
        update_colors
        write_line_width
        write_stroke_cap_style
        write_stroke_join_style
        write_stroke_dash
      end

    end
  end
end
