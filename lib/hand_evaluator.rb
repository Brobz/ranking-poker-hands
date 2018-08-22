class HandEvaluator

  @@card_value_table = {"T" => 10, "J" => 11, "Q" => 12, "K" => 13, "A" => 14}

  def has_single_suit(hand)
    suit = hand[0][1]
    hand[1..4].each do |card|
      if suit != card[1]
        return false
      end
    end
    return true
  end

  def get_kicker(hand, reps, card_string = false)
    kicker = 0
    kicker_string = ""
    hand[1..4].each do |card|
      value = get_card_value(card)
      if value > kicker && !reps.include?(value)
        kicker = value
        kicker_string = card
      end
    end
    if(card_string)
      return kicker, kicker_string
    end
    return kicker
  end

  def get_higher_rep(reps)
    high = reps.keys[0]
    for i in 1..reps.length - 1
      if reps.keys[i] > high
        high = reps.keys[i]
      end
    end
    return high
  end

  def get_lower_rep(reps)
    low = reps.keys[0]
    for i in 1..reps.length - 1
      if reps.keys[i] < low
        low = reps.keys[i]
      end
    end
    return low
  end

  def get_card_value(card)
    if card[0].to_i != 0
      return card[0].to_i
    else
      return @@card_value_table[card[0]]
    end
  end

  def has_sequence(hand, royal = false)
    if get_repeats_of_a_kind(hand).length != 0
      return false
    end
    ace_and_king = 0
    flag = 0
    for i in 0..4
      flag += 1
      value = get_card_value hand[i]
      if value > 12
        ace_and_king += 1
      end
      hand.each do |card|
        if value == get_card_value(card) - 1
          flag -= 1
        elsif get_card_value(card) == 14
            if value == 2
              flag -= 1
            end
        end
      end
      if flag > 1
        return false
      end
    end
    if !royal
      return true
    elsif ace_and_king > 1
      return true
    else
      return false
    end

  end

  def get_repeats_of_a_kind(hand)
    repeats = {}
    for i in 0..4
      value = get_card_value hand[i]
      if repeats[value] != nil
        next
      end
      hand[i + 1..4].each do |card|
        if value == get_card_value(card)
          if repeats[value] != nil
            repeats[value] += 1
          else
            repeats[value] = 2
          end
        end
      end
    end
    return repeats
  end

  def return_stronger_hand(left, right)
    # Get single suit status
    left_single_suit = has_single_suit(left)
    right_single_suit = has_single_suit(right)

    # Get repetitions
    left_reps = get_repeats_of_a_kind(left)
    left_reps_keys = left_reps.keys
    right_reps = get_repeats_of_a_kind(right)
    right_reps_keys = right_reps.keys

    # Get kickers
    left_kicker = right_kicker = -1
    left_copy = left.dup
    right_copy = right.dup
    while left_kicker == right_kicker && left_kicker != 0 do
      left_kicker, left_string = get_kicker(left_copy, left_reps.keys, true)
      right_kicker, right_string = get_kicker(right_copy, right_reps.keys, true)
      left_copy.delete(left_string)
      right_copy.delete(right_string)
    end


    # Determine higher kicker
    if left_kicker == 0
      higher_kicker_hand = "TIE!"
    elsif
      higher_kicker_hand = left_kicker > right_kicker ? left : right
    end

    # Get sequences
    left_sequence = left_reps.length != 0 ? false : has_sequence(left)
    right_sequence = right_reps.length != 0 ? false : has_sequence(right)

    # Get Royal Sequences
    left_royal_sequence = left_reps.length != 0 ? false : has_sequence(left, true)
    right_royal_sequence = right_reps.length != 0 ? false : has_sequence(right, true)

    # Check for royal flush
    left_royal_flush = left_royal_sequence && left_single_suit
    right_royal_flush = right_royal_sequence && right_single_suit

    if left_royal_flush && right_royal_flush
      return 'TIE - Two royal flushes split the pot!'
    elsif left_royal_flush
      return left
    elsif right_royal_flush
      return right
    end

    # Check for straight flush
    left_straight_flush = left_sequence && left_single_suit
    right_straight_flush = right_sequence && right_single_suit

    if left_straight_flush && right_straight_flush
      return higher_kicker_hand
    elsif left_straight_flush
      return left
    elsif right_straight_flush
      return right
    end

    # Check for four of a kind
    left_foa = left_reps[left_reps_keys[0]] == 4 ? true : false
    right_foa = right_reps[right_reps_keys[0]] == 4 ? true : false

    if left_foa && right_foa
      if left_reps_keys[0] > right_reps_keys[0]
        return left
      elsif left_reps_keys[0] < right_reps_keys[0]
        return right
      else
        return higher_kicker_hand
      end
    elsif left_foa
      return left
    elsif right_foa
      return right
    end

    # Check for full house
    left_fh = (left_reps.length == 2 && (left_reps[left_reps_keys[0]] + left_reps[left_reps_keys[1]] == 5)) ? true : false
    right_fh = (right_reps.length == 2 && (right_reps[right_reps_keys[0]] + right_reps[right_reps_keys[1]] == 5)) ? true : false

    if left_fh && right_fh
      left_3oak_key = left_reps[left_reps_keys[0]] == 3 ? left_reps_keys[0] : left_reps_keys[1]
      right_3oak_key = right_reps[right_reps_keys[0]] == 3 ? right_reps_keys[0] : right_reps_keys[1]
      if left_3oak_key > right_3oak_key
        return left
      elsif left_3oak_key < right_3oak_key
        return right
      else
        left_2oak_key = left_reps[left_reps_keys[0]] == 2 ? left_reps_keys[0] : left_reps_keys[1]
        right_2oak_key = right_reps[right_reps_keys[0]] == 2 ? right_reps_keys[0] : right_reps_keys[1]
        if left_2oak_key > right_2oak_key
          return left
        elsif left_2oak_key < right_2oak_key
          return right
        else
          return higher_kicker_hand
        end
      end
    elsif left_fh
      return left
    elsif right_fh
      return right
    end

    # Check for flush
    if left_single_suit && right_single_suit
      return higher_kicker_hand
    elsif left_single_suit
      return left
    elsif right_single_suit
      return right
    end

    # Check for straight
    if left_sequence && right_sequence
      return higher_kicker_hand
    elsif left_sequence
      return left
    elsif right_sequence
      return right
    end

    # Check for three of a kind
    left_3oak = (left_reps.length == 1 && left_reps[left_reps_keys[0]] == 3) ? true : false
    right_3oak = (right_reps.length == 1 && right_reps[right_reps_keys[0]] == 3) ? true : false

    if left_3oak && right_3oak
      if left_reps_keys[0] > right_reps_keys[0]
        return left
      elsif left_reps_keys[0] < right_reps_keys[0]
        return right
      else
        return higher_kicker_hand
      end
    elsif left_3oak
      return left
    elsif right_3oak
      return right
    end

    # Check for two pairs
    left_2pairs = left_reps.length == 2 ? true : false
    right_2pairs = right_reps.length == 2 ? true : false

    if left_2pairs && right_2pairs
      higher_left_rep = get_higher_rep(left_reps)
      higher_right_rep = get_higher_rep(right_reps)
      if higher_left_rep > higher_right_rep
        return left
      elsif higher_left_rep < higher_right_rep
        return right
      else
        lower_left_rep = get_lower_rep(left_reps)
        lower_right_rep = get_lower_rep(right_reps)
        if lower_left_rep > lower_right_rep
          return left
        elsif lower_left_rep < lower_right_rep
          return right
        else
          return higher_kicker_hand
        end
      end
    elsif left_2pairs
      return left
    elsif right_2pairs
      return right
    end

    # Check for pair
    left_pair = left_reps.length == 1 ? true : false
    right_pair = right_reps.length == 1 ? true : false

    if left_pair && right_pair
      if get_higher_rep(left_reps) > get_higher_rep(right_reps)
        return left
      elsif get_higher_rep(left_reps) < get_higher_rep(right_reps)
        return right
      else
        return higher_kicker_hand
      end
    elsif left_pair
      return left
    elsif right_pair
      return right
    end

    # Decide with kicker
    return higher_kicker_hand
  end

end


if __FILE__ == $0
  puts HandEvaluator.new.return_stronger_hand(["2D", "2C", "2D", "4C", "4H"], ["2H", "2S", "2D", "3C", "3H"])
end
