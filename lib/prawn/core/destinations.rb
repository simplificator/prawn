# encoding: utf-8

# prawn/core/destinations.rb : Implements destination support for PDF
#
# Copyright November 2008, Jamis Buck. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Core
    module Destinations #:nodoc:
      
      # The maximum number of children to fit into a single node in the Dests tree.
      NAME_TREE_CHILDREN_LIMIT = 20 #:nodoc:
      
      # The Dests name tree in the Name dictionary (see Prawn::Document::Internal#names).
      # This name tree is used to store named destinations (PDF spec 8.2.1).
      # (For more on name trees, see section 3.8.4 in the PDF spec.)
      #
      def dests
        names.data[:Dests] ||= ref!(Prawn::Core::NameTree::Node.new(self, NAME_TREE_CHILDREN_LIMIT))
      end

      # Adds a new destination to the dests name tree (see #dests). The
      # +reference+ parameter will be converted into a Prawn::Reference if
      # it is not already one.
      #
      def add_dest(name, reference)
        reference = ref!(reference) unless reference.is_a?(Prawn::Core::Reference)
        dests.data.add(name, reference)
      end

      # Return a Dest specification for a specific location (and optional zoom
      # level).
      #
      def dest_xyz(x, y, zoom=nil, page=state.page)
        dictionary = page_dictionary(page)
        top = y.nil? ? y : state.page.dimensions[3] - y
        [dictionary, :XYZ, x, top, zoom]
      end

      # Return a Dest specification that will fit the given page into the
      # viewport.
      #
      def dest_fit(page=state.page)
        dictionary = page_dictionary(page)
        [dictionary, :Fit]
      end

      # Return a Dest specification that will fit the given page horizontally
      # into the viewport, aligned vertically at the given top coordinate.
      #
      def dest_fit_horizontally(y, page=state.page)
        dictionary = page_dictionary(page)
        top = y.nil? ? y : state.page.dimensions[3] - y
        [dictionary, :FitH, top]
      end

      # Return a Dest specification that will fit the given page vertically
      # into the viewport, aligned horizontally at the given left coordinate.
      #
      def dest_fit_vertically(left, page=state.page)
        dictionary = page_dictionary(page)
        [dictionary, :FitV, left]
      end

      # Return a Dest specification that will fit the given rectangle into the
      # viewport, for the given page.
      #
      def dest_fit_rect(left, bottom, right, top, page=state.page)
        dictionary = page_dictionary(page)
        [dictionary, :FitR, left, bottom, right, top]
      end

      # Return a Dest specfication that will fit the given page's bounding box
      # into the viewport.
      #
      def dest_fit_bounds(page=state.page)
        dictionary = page_dictionary(page)
        [dictionary, :FitB]
      end

      # Same as #dest_fit_horizontally, but works on the page's bounding box
      # instead of the entire page.
      #
      def dest_fit_bounds_horizontally(top, page=state.page)
        dictionary = page_dictionary(page)
        [dictionary, :FitBH, top]
      end

      # Same as #dest_fit_vertically, but works on the page's bounding box
      # instead of the entire page.
      #
      def dest_fit_bounds_vertically(left, page=state.page)
        dictionary = page_dictionary(page)
        [dictionary, :FitBV, left]
      end
      
      private
      
      def page_dictionary(page)
        if page.is_a?(Integer)
          raise Prawn::Errors::DestinationPageNumberOutOfRange if page > state.pages.size
          page = state.pages[page - 1]
        end
        page.dictionary
      end
    end
  end
end
