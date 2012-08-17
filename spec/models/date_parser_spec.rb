# -*- encoding : utf-8 -*-
require 'spec_helper'
describe DateParser do
  context "results for" do
    it "1920" do
      DateParser.new('1920').results.should eq([1920, 1920])
    end

    it "1939-1950" do
      DateParser.new('1939-1950').results.should eq([1939, 1950])
    end

    it "2 ćw. XIV" do
      DateParser.new('2 ćw. XIV').results.should eq([1326, 1351])
    end

    it "2 poł XVIIw" do
      DateParser.new('2 poł XVIIw').results.should eq([1651, 1701])
    end

    it "XVIII - XIX" do
      DateParser.new('XVIII - XIX').results.should eq([1701, 1901])
    end

    it "XV/XVI" do
      DateParser.new('XV/XVI').results.should eq([1476, 1526])
    end

    it "od 2poł XIX w. do pocz. XX wieku" do
      DateParser.new('od 2poł XIX w. do pocz. XX wieku').results.should eq([1851, 1926])
    end

    example "retruns nil array for blank string" do
      DateParser.new('').results.should eq([nil, nil])
      DateParser.new(nil).results.should eq([nil, nil])
    end

  end

  context "round range for" do
    it "1939, 1950" do
      DateParser.round_range(1939, 1950).should eq([1926, 1951])
    end

    it "1900, 1901" do
      DateParser.round_range(1900, 1901).should eq([1876, 1926])
    end
  end

  example "check the roundness of the date" do
    DateParser.new('1987').rounded?.should be_false
    DateParser.new('1900-2000').rounded?.should be_false
    DateParser.new('').rounded?.should be_false
    DateParser.new('1 pol XXw').rounded?.should be_true
  end
end