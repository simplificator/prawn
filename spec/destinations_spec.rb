# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

describe "working with destinations" do
  
  before(:each) { create_pdf }

  describe "#add_dest" do 
  
    it "should add entry to Dests name tree" do 
      @pdf.dests.data.empty?.should == true
      @pdf.add_dest "candy", "chocolate"
      @pdf.dests.data.size.should == 1
    end
  
    context "with #dest_fit" do
      it "should add a fitted Destination to the name tree" do
        @pdf.add_dest("dest_fit", @pdf.dest_fit(@pdf.page))
        @pdf.render.include?("[#{@pdf.page.dictionary.to_s} /Fit]").should == true
        @pdf.dests.data.to_hash[:Names].map(&:name).should.include("dest_fit")
      end
    end
    
    context "with #dest_xyz" do
      it "should add a fitted xyz Destination to the name tree" do
        @pdf.add_dest("dest_xyz", @pdf.dest_xyz(5, 10, 2))
        @pdf.render.include?("[#{@pdf.page.dictionary.to_s} /XYZ 5 782.0 2]").should == true
        @pdf.dests.data.to_hash[:Names].map(&:name).should.include("dest_xyz")
      end
    end
    
    context "with #dest_fit_bounds" do
      it "should add a fitted rectangle Destination to the name tree" do
        @pdf.add_dest("dest_fit_bounds", @pdf.dest_fit_bounds)
        @pdf.render.include?("[#{@pdf.page.dictionary.to_s} /FitB]").should == true
        @pdf.dests.data.to_hash[:Names].map(&:name).should.include("dest_fit_bounds")
      end
    end
    
    context "with #dest_fit_rect" do
      it "should add a fitted rectangle Destination to the name tree" do
        @pdf.add_dest("dest_rect", @pdf.dest_fit_rect(5, 10, 15, 20, @pdf.page))
        @pdf.render.include?("[#{@pdf.page.dictionary.to_s} /FitR 5 10 15 20]").should == true
        @pdf.dests.data.to_hash[:Names].map(&:name).should.include("dest_rect")
      end
    end

  end
  
  describe "page_dictionary" do
    
    it "should return the dictionary of the given page" do
      @pdf.send(:page_dictionary, @pdf.state.page).should == @pdf.state.page.dictionary
    end
    
    it "should find the page dictionary for a page number" do
      @pdf.send(:page_dictionary, 1).should == @pdf.state.pages[0].dictionary
    end
    
    it "should complain when passed a non existant page number" do
      assert_raise Prawn::Errors::DestinationPageNumberOutOfRange do
        @pdf.send(:page_dictionary, 2)
      end
    end
            
  end

  describe "#dest_fit" do
    
    it "should call page_dictionary with current page when no page is requested" do
      @pdf.expects(:page_dictionary).with(@pdf.state.page).returns(:dictionary)
      @pdf.dest_fit
    end
    
    it "should call page_dictionary with requested page number" do
      @pdf.expects(:page_dictionary).with(1).returns(:dictionary)
      @pdf.dest_fit(1)
    end
    
    it "should build dictionary with returned dictionary" do
      @pdf.stubs(:page_dictionary).returns(:dictionary)
      @pdf.dest_fit.should == [:dictionary, :Fit]
    end
    
  end
  
  describe "#dest_xyz" do
    
    it "should call page_dictionary with current page when no page is requested" do
      @pdf.expects(:page_dictionary).with(@pdf.state.page).returns(:dictionary)
      @pdf.dest_xyz(nil, nil, nil)
    end
    
    it "should call page_dictionary with requested page number" do
      @pdf.expects(:page_dictionary).with(1).returns(:dictionary)
      @pdf.dest_xyz(nil, nil, nil, 1)
    end

    it "should create a destination with top and left and zoom positioning" do
      @pdf.stubs(:page_dictionary).returns(:dictionary)
      @pdf.dest_xyz(nil, nil, nil).should == [:dictionary, :XYZ, nil, nil, nil]
    end
    
    it "should subtract from height dimension to position from top of page" do
      @pdf.stubs(:page_dictionary).returns(:dictionary)
      @pdf.dest_xyz(0, 0, 2).should == [:dictionary, :XYZ, 0, 792.0, 2]
    end
    
  end
  
  describe "#dest_fit_rect" do
    
    it "should call page_dictionary with current page when no page is requested" do
      @pdf.expects(:page_dictionary).with(@pdf.state.page).returns(:dictionary)
      @pdf.dest_fit_rect(nil, nil, nil, nil)
    end
    
    it "should call page_dictionary with requested page number" do
      @pdf.expects(:page_dictionary).with(1).returns(:dictionary)
      @pdf.dest_fit_rect(nil, nil, nil, nil, 1)
    end

    it "should create a destination with rectangle bound by coordinates" do
      @pdf.stubs(:page_dictionary).returns(:dictionary)
      @pdf.dest_fit_rect(5, 10, 15, 20).should == [:dictionary, :FitR, 5, 10, 15, 20]
    end

  end
  
  describe "#dest_fit_bounds" do
    
    it "should call page_dictionary with current page when no page is requested" do
      @pdf.expects(:page_dictionary).with(@pdf.state.page).returns(:dictionary)
      @pdf.dest_fit_bounds
    end
    
    it "should call page_dictionary with requested page number" do
      @pdf.expects(:page_dictionary).with(1).returns(:dictionary)
      @pdf.dest_fit_bounds(1)
    end

    it "should create a destination with rectangle bound by coordinates" do
      @pdf.stubs(:page_dictionary).returns(:dictionary)
      @pdf.dest_fit_bounds(1).should == [:dictionary, :FitB]
    end

  end
  
end
