module ContestsHelper
  def duration_between(from_date, to_date)
    hours, minutes, seconds, fracs = Date.send(
      :day_fraction_to_time, to_date.minus_with_duration(from_date))
    days = (hours/24).round
    hours = hours % 24
    return [
      pluralize(days, "day"),
      pluralize(hours, "hour"),
      pluralize(minutes, "minute"),
      pluralize(seconds, "second"),
    ].join(', ')
  end

  module Level1

    def self.random_letter
      letters = "abcdefghijklmnopqrstuvwxyz"
      letters[rand letters.length]
    end

    def self.random_letters num
      (1..num).collect do
        random_letter
      end
    end

    WORDS = Marshal.load(open('lib/words2.dump'))

    def self.random_words num_words
      words = (1..num_words).collect do
        WORDS[rand WORDS.length]
      end.uniq
      while words.length < num_words
        words << WORDS[rand WORDS.length]
        words.uniq
      end
      return words
    end

    def self.generate_level0 len, num_words
      words = random_words num_words
      text = words.map {|word| if rand > 0.75 then word.reverse else word end }
      remaining = len - text.map(&:length).sum
      while remaining > 0
        nonce = random_letters(rand(remaining)+1)
        idx = rand text.length
        text.insert idx, nonce
        remaining = len - text.map(&:length).sum
      end
      return {words: words, puzzle: text.join('')}
    end

    def self.verify_level0 word_indices, puzzle
      word_indices.each do |wsym, loc|
        word = wsym.to_s
        if puzzle[loc..loc+word.length-1] == word
          next
        end

        start = loc-word.length+1
        if (start >= 0) and (puzzle[start..loc] == word.reverse)
          next
        end

        return false
      end

      return true
    end

    def self.generate_level1 len, num_words
      words = random_words num_words
      text = Array.new(len, nil)
      text.map! {|x| Array.new(len, nil)}
      words.each do |word|
        row, col = rand(len), rand(len)
        fwd = rand > 0.5
        horiz = rand > 0.5
        if horiz
          while (col + word.length >= len or
                 text[row][col..col+word.length-1].any? {|x| !x.nil? })
            row, col = rand(len), rand(len)
          end
          if fwd
            text[row][col..col+word.length-1] = word.split //
          else
            text[row][col..col+word.length-1] = word.reverse.split //
          end
        else
          while (row + word.length >= len or
                 text[row..row+word.length-1].map{|r| r[col]}.any? {|x| !x.nil? })
            row, col = rand(len), rand(len)
          end
          chars = []
          if fwd
            chars = word.reverse.split //
          else
            chars = word.split //
          end
          text[row..row+word.length-1].map!{|r| r[col] = chars.pop}
        end
      end
      text.each_index do |row|
        text[row].each_index do |col|
          if text[row][col].nil?
            text[row][col] = random_letter
          end
        end
      end
      return {words: words, puzzle: text.map{|row| row.join ''}.join("\n") }
    end

    def self.verify_level1 word_indices, puzzle_chars
      puzzle = puzzle_chars.split /\n/
      word_indices.each do |wsym, loc|
        word = wsym.to_s
        row, col = loc

        puzzle_row = puzzle[row]
        if puzzle_row[col..col+word.length-1] == word
          next
        else
          Rails.logger.debug("#{word} != #{puzzle_row[col..col+word.length-1]}")
        end

        horiz_start = col-word.length+1
        if (horiz_start >= 0) and (puzzle_row[horiz_start..col] == word.reverse)
          next
        else
          Rails.logger.debug("#{word} != #{puzzle_row[horiz_start..col]}")
        end

        puzzle_col = puzzle.map {|r| r[col]}
        if puzzle_col[row..row+word.length-1].join('') == word
          next
        else
          Rails.logger.debug("#{word} != #{puzzle_col[row..row+word.length-1].join('')}")
        end

        vert_start = row-word.length+1
        if (vert_start >= 0) and (puzzle_col[vert_start..row].join('') == word.reverse)
          next
        else
          Rails.logger.debug("#{word} != #{puzzle_col[vert_start..row].join('')}")
        end

        return false
      end
      return true
    end

    def self.generate_level2 len, num_words
      words = random_words num_words
      text = Array.new(len, nil)
      text.map! {|x| Array.new(len, nil)}
      words.each do |orig_word|
        word = orig_word.clone
        word[rand word.length] = random_letter
        row, col = rand(len), rand(len)
        fwd = rand > 0.5
        horiz = rand > 0.5
        if horiz
          while (col + word.length >= len or
                 text[row][col..col+word.length-1].any? {|x| !x.nil? })
            row, col = rand(len), rand(len)
          end
          if fwd
            text[row][col..col+word.length-1] = word.split //
          else
            text[row][col..col+word.length-1] = word.reverse.split //
          end
        else
          while (row + word.length >= len or
                 text[row..row+word.length-1].map{|r| r[col]}.any? {|x| !x.nil? })
            row, col = rand(len), rand(len)
          end
          chars = []
          if fwd
            chars = word.reverse.split //
          else
            chars = word.split //
          end
          text[row..row+word.length-1].map!{|r| r[col] = chars.pop}
        end
      end
      text.each_index do |row|
        text[row].each_index do |col|
          if text[row][col].nil?
            text[row][col] = random_letter
          end
        end
      end
      return {words: words, puzzle: text.map{|row| row.join ''}.join("\n") }
    end

    def self.off_by_one? word1, word2
      if word1 == word2
        return true
      end

      errors = 0
      len = word1.length > word2.length ? word1.length : word2.length
      (0..len).each do |i|
        if word1[i] != word2[i]
          if errors >= 1
            return false
          else
            errors += 1
          end
        end
      end
      return true
    end

    def self.verify_level2 word_indices, puzzle_chars
      puzzle = puzzle_chars.split /\n/
      word_indices.each do |wsym, loc|
        word = wsym.to_s
        row, col = loc

        puzzle_row = puzzle[row]
        if off_by_one? puzzle_row[col..col+word.length-1], word
          next
        end

        horiz_start = col-word.length+1
        if ((horiz_start >= 0) and
            (off_by_one? puzzle_row[horiz_start..col], word.reverse))
          next
        end

        puzzle_col = puzzle.map {|r| r[col]}
        if off_by_one? puzzle_col[row..row+word.length-1].join(''), word
          next
        end

        vert_start = row-word.length+1
        if ((vert_start >= 0) and
            (off_by_one? puzzle_col[vert_start..row].join(''), word.reverse))
          next
        end

        return false
      end
      return true
    end
  end
end
