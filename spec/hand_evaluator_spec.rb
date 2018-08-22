require_relative "spec_helper"
require_relative "../lib/hand_evaluator"

describe HandEvaluator do
  describe "#return_stronger_hand" do
    it "scores pairs higher than flops" do
      expect_higher "2S 2D 3S 4S 5S", "AS QS JD TS 9S"
    end

    it "breaks ties with pairs by rank" do
      expect_higher "3S 3D 4S 5S 6S", "2S 2D 3S 4S 5S"
    end

    it "scores two pair higher than pairs" do
      expect_higher "2S 2D 3S 3D 4H", "AS AD 5S 6D 7H"
    end

    it "breaks ties with two pair by the highest pair" do
      expect_higher "2S 2D 5S 5D 4H", "4D 4S 3H 3C 6S"
      expect_higher "4D 4S 3D 3S KH", "4C 4H 2D 2S KC"
    end

    it "scores three of a kind higher than two pair" do
      expect_higher "2S 2D 2C 3S 4D", "AS AD KS KD QS"
    end

    it "breaks ties with three of a kind by using the highest rank" do
      expect_higher "3S 3D 3C 5S 4D", "2S 2D 2C 6S 7D"
    end

    it "scores a straight higher than a three of a kind" do
      expect_higher "3S 2D 6H 4C 5H", "AS AD AC KS QD"
    end

    it "breaks ties with straights by using the highest rank" do
      expect_higher "3S 7D 6H 4C 5H", "2C 3D 4D 5D 6C"
    end

    it "scores a flush higher than a straight" do
      expect_higher "2H 3H 4H 5H 6H", "TD JD QH KH AS"
    end

    it "breaks ties with a flush by using the highest rank" do
      expect_higher "2D 3D 4D 5D 8D", "2H 3H 4H 5H 7H"
    end

    it "scores a full house higher than a flush" do
      expect_higher "2C 2D 2H 3C 3D", "9D JD QD KD AD"
    end

    it "breaks ties in a full house using the three of a kind, then pair" do
      expect_higher "2D 2C 4D 4C 4H", "2H 2S 3D 3C 3H"
      expect_higher "2D 2C 2D 4C 4H", "2H 2S 2D 3C 3H"
    end

    it "scores a four of a kind higher than a full house" do
      expect_higher "2C 2D 2H 2S 3C", "AS AH AD KS KH"
    end

    it "breaks ties with four of a kind by using the highest rank" do
      expect_higher "3S 3D 3C 3H 4D", "2S 2D 2C 2H 5D"
    end

    it "scores a straight flush higher than a four of a kind" do
      expect_higher "2S 3S 4S 5S 6S", "AS AH AD AC KS"
    end

    it "breaks ties with a straight flush by looking at rank" do
      expect_higher "3S 7S 6S 4S 5S", "2C 3C 4C 5C 6C"
    end

    it "breaks ties using side cards" do
      expect_higher "2D 2H 3D 4D 6D", "2C 2S 3S 4S 5S"
    end
  end

  def expect_higher(higher_string, lower_string)
    higher = higher_string.split(" ")
    lower = lower_string.split(" ")
    expect(HandEvaluator.new.return_stronger_hand(higher, lower)).
      to eq(higher)
    expect(HandEvaluator.new.return_stronger_hand(lower, higher)).
      to eq(higher)
  end
end
