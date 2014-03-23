require '../solea/solea'

class Integer
  class << self
    def from_spell spelling
      spelling.split(/[^a-z]+/i).inject([0]) do |so_far, word|
        if powers_1000.include? word.downcase
          so_far[-1] *= 1000 ** powers_1000.index(word.downcase)
          so_far << 0
        elsif word.downcase == "hundred"
          so_far[-1] *= 100
        elsif number_names[word.downcase]
          so_far[-1] += number_names[word.downcase]
        else
          raise ArgumentError, "Number name not found: \"#{word}\""
        end
        so_far
      end.inject(:+)
    end

    private

    def powers_1000
      [nil, "thousand", "million", "billion", "trillion"]
    end

    def number_names
      { "one"       => 1,
        "two"       => 2,
        "three"     => 3,
        "four"      => 4,
        "five"      => 5,
        "six"       => 6,
        "seven"     => 7,
        "eight"     => 8,
        "nine"      => 9,
        "ten"       => 10,
        "eleven"    => 11,
        "twelve"    => 12,
        "thirteen"  => 13,
        "fourteen"  => 14,
        "fifteen"   => 15,
        "sixteen"   => 16,
        "seventeen" => 17,
        "eighteen"  => 18,
        "nineteen"  => 19,
        "twenty"    => 20,
        "thirty"    => 30,
        "forty"     => 40,
        "fifty"     => 50,
        "sixty"     => 60,
        "seventy"   => 70,
        "eighty"    => 80,
        "ninety"    => 90
      }
    end
  end

  def ord spell: false
    last_part = if self % 100 == 0; self
                  elsif self % 100 < 21 || self % 100 % 10 == 0; self % 100
                  else self % 10
                end

    first_part = (self - last_part).spell unless last_part == self

    if spell
      spellings = {
        1 =>  "first",
        2 =>  "second",
        3 =>  "third",
        5 =>  "fifth",
        8 =>  "eighth",
        9 =>  "ninth",
        12 => "twelfth"
      }
      if spellings[last_part]
        [first_part, spellings[last_part]].compact.join(" ")
      elsif last_part % 10 == 0 && (11..99) === last_part
        [first_part, last_part.spell[0..-2] + "ieth"].compact.join(" ")
      else
        [first_part, last_part.spell + "th"].compact.join(" ")
      end
    else
      self.to_s + (last_part == 1 ? "st" :
                   last_part == 2 ? "nd" :
                   last_part == 3 ? "rd" : "th")
    end
  end

  def spell
    number_names = Integer.send(:number_names).invert
    return number_names[self] if number_names[self]
    powers_1000 = Integer.send(:powers_1000)
    raise ArgumentError, "#{self} too large to spell.  Largest denomination allowed is #{powers_1000[-1]}s." \
      if self >= 1000 ** powers_1000.count

    if self < 100
      "#{(self / 10 * 10).spell} #{(self % 10).spell}"
    elsif self < 1000
      mod100 = (self % 100).spell if self % 100 > 0
      ["#{(self / 100).spell} hundred", mod100].compact.join(" ")
    else
      str, exp, num = nil, 0, self
      while num > 0
        group_of_zeros = num % 1000 ** exp.succ
        hundreds_of_this_group = group_of_zeros / 1000 ** exp
        if hundreds_of_this_group > 0
          str = [hundreds_of_this_group.spell, powers_1000[exp], str].compact.join(" ")
        end
        exp, num = exp + 1, num - group_of_zeros
      end
      str
    end
  end
end

Solea.test do
  example 1.ord; expect "1st"
  example 2.ord; expect "2nd"
  example 3.ord; expect "3rd"
  example 5.ord; expect "5th"
  example 6.ord; expect "6th"
  example 7.ord; expect "7th"
  example 8.ord; expect "8th"
  example 9.ord; expect "9th"
  example 10.ord; expect "10th"
  example 11.ord; expect "11th"
  example 12.ord; expect "12th"
  example 13.ord; expect "13th"
  example 20.ord; expect "20th"
  example 21.ord; expect "21st"
  example 22.ord; expect "22nd"
  example 23.ord; expect "23rd"
  example 24.ord; expect "24th"
  example 100.ord; expect "100th"
  example 101.ord; expect "101st"
  example 17491871158767.ord; expect "17491871158767th"

  example 1.ord spell: true; expect "first"
  example 2.ord spell: true; expect "second"
  example 3.ord spell: true; expect "third"
  example 4.ord spell: true; expect "fourth"
  example 5.ord spell: true; expect "fifth"
  example 6.ord spell: true; expect "sixth"
  example 7.ord spell: true; expect "seventh"
  example 8.ord spell: true; expect "eighth"
  example 9.ord spell: true; expect "ninth"
  example 10.ord spell: true; expect "tenth"
  example 11.ord spell: true; expect "eleventh"
  example 12.ord spell: true; expect "twelfth"
  example 13.ord spell: true; expect "thirteenth"
  example 14.ord spell: true; expect "fourteenth"
  example 15.ord spell: true; expect "fifteenth"
  example 16.ord spell: true; expect "sixteenth"
  example 17.ord spell: true; expect "seventeenth"
  example 18.ord spell: true; expect "eighteenth"
  example 19.ord spell: true; expect "nineteenth"
  example 20.ord spell: true; expect "twentieth"
  example 21.ord spell: true; expect "twenty first"
  example 30.ord spell: true; expect "thirtieth"
  example 32.ord spell: true; expect "thirty second"
  example 40.ord spell: true; expect "fortieth"
  example 43.ord spell: true; expect "forty third"
  example 50.ord spell: true; expect "fiftieth"
  example 54.ord spell: true; expect "fifty fourth"
  example 60.ord spell: true; expect "sixtieth"
  example 65.ord spell: true; expect "sixty fifth"
  example 70.ord spell: true; expect "seventieth"
  example 76.ord spell: true; expect "seventy sixth"
  example 80.ord spell: true; expect "eightieth"
  example 87.ord spell: true; expect "eighty seventh"
  example 90.ord spell: true; expect "ninetieth"
  example 98.ord spell: true; expect "ninety eighth"
  example 100.ord  spell: true; expect "one hundredth"
  example 101.ord  spell: true; expect "one hundred first"
  example 102.ord  spell: true; expect "one hundred second"
  example 103.ord  spell: true; expect "one hundred third"
  example 104.ord  spell: true; expect "one hundred fourth"
  example 110.ord  spell: true; expect "one hundred tenth"
  example 111.ord  spell: true; expect "one hundred eleventh"
  example 112.ord  spell: true; expect "one hundred twelfth"
  example 113.ord  spell: true; expect "one hundred thirteenth"
  example 120.ord  spell: true; expect "one hundred twentieth"
  example 125.ord  spell: true; expect "one hundred twenty fifth"
  example 130.ord  spell: true; expect "one hundred thirtieth"
  example 500.ord  spell: true; expect "five hundredth"
  example 999.ord  spell: true; expect "nine hundred ninety ninth"
  example 1000.ord spell: true; expect "one thousandth"
  example 1001.ord spell: true; expect "one thousand first"
  example 156000.ord spell: true; expect "one hundred fifty six thousandth"
  example 1000001.ord spell: true; expect "one million first"

  example 123456789.ord spell: true
  expect "one hundred twenty three million four hundred fifty six thousand seven hundred eighty ninth"

  example 17491871158767.ord spell: true
  expect "seventeen trillion four hundred ninety one billion eight hundred seventy one million one hundred fifty eight thousand seven hundred sixty seventh"

  example 13.spell; expect "thirteen"
  example 14.spell; expect "fourteen"
  example 15.spell; expect "fifteen"
  example 16.spell; expect "sixteen"
  example 17.spell; expect "seventeen"
  example 18.spell; expect "eighteen"
  example 19.spell; expect "nineteen"
  example 20.spell; expect "twenty"
  example 21.spell; expect "twenty one"
  example 30.spell; expect "thirty"
  example 32.spell; expect "thirty two"
  example 40.spell; expect "forty"
  example 43.spell; expect "forty three"
  example 50.spell; expect "fifty"
  example 54.spell; expect "fifty four"
  example 60.spell; expect "sixty"
  example 65.spell; expect "sixty five"
  example 70.spell; expect "seventy"
  example 76.spell; expect "seventy six"
  example 80.spell; expect "eighty"
  example 87.spell; expect "eighty seven"
  example 90.spell; expect "ninety"
  example 98.spell; expect "ninety eight"
  example 100.spell; expect "one hundred"
  example 101.spell; expect "one hundred one"
  example 111.spell; expect "one hundred eleven"
  example 999.spell; expect "nine hundred ninety nine"

  example 1376451.spell
  expect "one million three hundred seventy six thousand four hundred fifty one"

  example 413500611.spell
  expect "four hundred thirteen million five hundred thousand six hundred eleven"

  example 100000.spell; expect "one hundred thousand"
  example 1000001.spell; expect "one million one"

  example 17491871158767.spell
  expect "seventeen trillion four hundred ninety one billion eight hundred seventy one million one hundred fifty eight thousand seven hundred sixty seven"

  example Integer.from_spell "one"; expect 1
  example Integer.from_spell "two"; expect 2
  example Integer.from_spell "three"; expect 3
  example Integer.from_spell "four"; expect 4
  example Integer.from_spell "five"; expect 5
  example Integer.from_spell "six"; expect 6
  example Integer.from_spell "seven"; expect 7
  example Integer.from_spell "eight"; expect 8
  example Integer.from_spell "nine"; expect 9
  example Integer.from_spell "ten"; expect 10
  example Integer.from_spell "eleven"; expect 11
  example Integer.from_spell "twelve"; expect 12
  example Integer.from_spell "thirteen"; expect 13
  example Integer.from_spell "fourteen"; expect 14
  example Integer.from_spell "fifteen"; expect 15
  example Integer.from_spell "sixteen"; expect 16
  example Integer.from_spell "seventeen"; expect 17
  example Integer.from_spell "eighteen"; expect 18
  example Integer.from_spell "nineteen"; expect 19
  example Integer.from_spell "twenty"; expect 20
  example Integer.from_spell "twenty one"; expect 21
  example Integer.from_spell "thirty"; expect 30
  example Integer.from_spell "thirty two"; expect 32
  example Integer.from_spell "forty"; expect 40
  example Integer.from_spell "forty three"; expect 43
  example Integer.from_spell "fifty"; expect  50
  example Integer.from_spell "fifty four"; expect 54
  example Integer.from_spell "sixty"; expect 60
  example Integer.from_spell "sixty five"; expect 65
  example Integer.from_spell "seventy"; expect 70
  example Integer.from_spell "seventy six"; expect 76
  example Integer.from_spell "eighty"; expect 80
  example Integer.from_spell "eighty seven"; expect 87
  example Integer.from_spell "ninety"; expect 90
  example Integer.from_spell "ninety eight"; expect 98
  example Integer.from_spell "one hundred"; expect 100
  example Integer.from_spell "one hundred one"; expect 101
  example Integer.from_spell "one hundred eleven"; expect 111
  example Integer.from_spell "five hundred"; expect 500
  example Integer.from_spell "nine hundred ninety nine"; expect 999
  example Integer.from_spell "one million one"; expect 1000001

  example Integer.from_spell "one hundred twenty three million four hundred fifty six thousand seven hundred eighty nine"
  expect 123456789

  example Integer.from_spell "one-hundred-twenty-three"; expect 123
  example Integer.from_spell "seventeen trillion four hundred ninety one billion eight hundred seventy one million one hundred fifty eight thousand seven hundred sixty seven"
  expect  17491871158767

  attempt(false, ArgumentError) { Integer.from_spell "a hundred" }
  attempt(false, ArgumentError) { 1000000000000000000000000000000000000000000000000000000.spell }
end
