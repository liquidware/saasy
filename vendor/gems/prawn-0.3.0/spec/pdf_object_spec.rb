# -*- encoding : utf-8 -*-

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

# See PDF Reference, Sixth Edition (1.7) pp51-60 for details 
describe "PDF Object Serialization" do     
              
  it "should convert Ruby's nil to PDF null" do
    Prawn::PdfObject(nil).should == "null"
  end
  
  it "should convert Ruby booleans to PDF booleans" do
    Prawn::PdfObject(true).should  == "true"
    Prawn::PdfObject(false).should == "false"
  end
                                          
  it "should convert a Ruby number to PDF number" do
    Prawn::PdfObject(1).should == "1"
    Prawn::PdfObject(1.214112421).should == "1.214112421" 
  end
  
  it "should convert a Ruby string to PDF string when inside a content stream" do       
    s = "I can has a string"
    PDF::Inspector.parse(Prawn::PdfObject(s, true)).should == s
  end                      

  it "should convert a Ruby string to a UTF-16 PDF string when outside a content stream" do       
    s = "I can has a string"
    s_utf16 = "\xFE\xFF" + s.unpack("U*").pack("n*")
    PDF::Inspector.parse(Prawn::PdfObject(s, false)).should == s_utf16
  end                      
  
  it "should escape parens when converting from Ruby string to PDF" do
    s =  'I )(can has a string'      
    PDF::Inspector.parse(Prawn::PdfObject(s, true)).should == s
  end               
  
  it "should handle ruby escaped parens when converting to PDF string" do
    s = 'I can \\)( has string'
    PDF::Inspector.parse(Prawn::PdfObject(s, true)).should == s  
  end      
  
  it "should convert a Ruby symbol to PDF name" do
    Prawn::PdfObject(:my_symbol).should == "/my_symbol"
    Prawn::PdfObject(:"A;Name_With−Various***Characters?").should ==
     "/A;Name_With−Various***Characters?"
  end
 
  it "should not convert a whitespace containing Ruby symbol to a PDF name" do
    lambda { Prawn::PdfObject(:"My Symbol With Spaces") }.
      should.raise(Prawn::Errors::FailedObjectConversion)
  end    
  
  it "should convert a Ruby array to PDF Array when inside a content stream" do
    Prawn::PdfObject([1,2,3]).should == "[1 2 3]"
    PDF::Inspector.parse(Prawn::PdfObject([[1,2],:foo,"Bar"], true)).should ==  
      [[1,2],:foo, "Bar"]
  end  

  it "should convert a Ruby array to PDF Array when outside a content stream" do
    bar = "\xFE\xFF" + "Bar".unpack("U*").pack("n*")
    Prawn::PdfObject([1,2,3]).should == "[1 2 3]"
    PDF::Inspector.parse(Prawn::PdfObject([[1,2],:foo,"Bar"], false)).should ==  
      [[1,2],:foo, bar]
  end  
 
  it "should convert a Ruby hash to a PDF Dictionary when inside a content stream" do
    dict = Prawn::PdfObject( {:foo  => :bar, 
                              "baz" => [1,2,3], 
                              :bang => {:a => "what", :b => [:you, :say] }}, true )     

    res = PDF::Inspector.parse(dict)           

    res[:foo].should == :bar
    res[:baz].should == [1,2,3]
    res[:bang].should == { :a => "what", :b => [:you, :say] }

  end      

  it "should convert a Ruby hash to a PDF Dictionary when outside a content stream" do
    what = "\xFE\xFF" + "what".unpack("U*").pack("n*")
    dict = Prawn::PdfObject( {:foo  => :bar, 
                              "baz" => [1,2,3], 
                              :bang => {:a => "what", :b => [:you, :say] }}, false )

    res = PDF::Inspector.parse(dict)           

    res[:foo].should == :bar
    res[:baz].should == [1,2,3]
    res[:bang].should == { :a => what, :b => [:you, :say] }

  end      
  
  it "should not allow keys other than strings or symbols for PDF dicts" do
    lambda { Prawn::PdfObject(:foo => :bar, :baz => :bang, 1 => 4) }.
      should.raise(Prawn::Errors::FailedObjectConversion) 
  end  
  
  it "should convert a Prawn::Reference to a PDF indirect object reference" do
    ref = Prawn::Reference(1,true)
    Prawn::PdfObject(ref).should == ref.to_s
  end

  it "should convert a NameTree::Node to a PDF hash" do
    node = Prawn::NameTree::Node.new(Prawn::Document.new, 10)
    node.add "hello", 1.0
    node.add "world", 2.0
    data = Prawn::PdfObject(node)
    res = PDF::Inspector.parse(data)
    res.should == {:Names => ["hello", 1.0, "world", 2.0]}
  end
end
