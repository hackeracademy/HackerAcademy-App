# To add generation and verification for a new Dojo, you should create a new
# submodule named "Dojo[N]" (e.g. Dojo1) which will contain all the code to
# generate/verify the puzzles. The module should also contain two methods with
# the following names and signatures: self.generate_puzzle(level, *args) which
# will return the new puzzle for the given level in an appopriate format, and
# self.verify_puzzle(level, *args), which will verify a puzle of the given
# level, returning true or false.

require 'digest/md5'

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

  def self.generate_puzzle(dojo, level, args)
    return self.const_get(:"Dojo#{dojo}").generate_puzzle(level, *args)
  end

  def self.verify_puzzle(dojo, level, args)
    return self.const_get(:"Dojo#{dojo}").verify_puzzle(level, *args)
  end

  module Dojo2

    POSTS = Marshal.load(open('lib/ecdojoposts.dump'))
    # hash:
    # ID => [ ID (str) , DATETIME (int), MESSAGE (string) ]

    def self.generate_level0
      query = %w(guy girl drink dance shirt red the you).sample
      # select random subset of posts
      posts = POSTS.values.sort_by{rand}[0..50]
      # choose a word
      return {query: query, posts: posts}
    end

    def self.verify_level0(posts, query, soln)
      s = soln.split("\n").map{|x| x.strip}.join("+")
      
      times_ids = []

      posts.split('+').each do |post_id|
        if POSTS[post_id][2].downcase.include? query #TODO make this a better check
          times_ids << [POSTS[post_id][1], POSTS[post_id][0]]
        end
      end

      if times_ids.length.to_s == "0"
        actual_soln = "0"
      else
        actual_soln = [times_ids.length.to_s,times_ids.sort.map{|x| x[1]}.join("+")].join("+")
      end

      return s == actual_soln
    end

    LOCATIONS = Marshal.load(open('lib/ecdojolocations.dump'))
    SALT = "nacl"

    # string obfuscation functions
    # input is an array of characters

    def self.random_char
      return (rand(122-97) + 97).chr
    end

    def self.jumble_case(input)
      return input.map{|x| rand() > 0.5 ? x.upcase : x.downcase}
    end

    def self.swap_letter(input)
      x = rand(input.length-1)+1
      rmved = input.delete_at(x)
      output = input.insert(x-1, rmved)
      return output
    end

    def self.remove_letter(input)
      input.delete_at(rand(input.length))
      return input
    end

    def self.replace_letter(input)
      input[rand(input.length)] = random_char()
      return input
    end

    def self.add_letter(input)
      input.insert(rand(input.length), random_char())
      return input
    end

    def self.obfuscate(string)
      arr = string.split(//)

      arr = jumble_case(arr) if rand < (0.1 + 0.3 * arr.length / 18)
      arr = swap_letter(arr) if rand < (0.1 + 0.3 * arr.length / 18)
      arr = remove_letter(arr) if rand < (0.1 + 0.3 * arr.length / 18)
      arr = replace_letter(arr) if rand < (0.1 + 0.3 * arr.length / 18)
      arr = add_letter(arr) if rand < (0.1 + 0.3 * arr.length / 18)

      return arr.join()
    end

    def self.generate_level1
      locations = LOCATIONS.sort_by{rand}[0..100]
      searches = locations.sort_by{rand} #locations.sort_by{rand}[0..100]

      hash_searches = []

      searches.each do |search|
        hash = Digest::MD5.hexdigest(search + SALT)
        search = obfuscate(search)
        hash_searches << [hash, search]
      end

      
      return {searches: hash_searches, locations: locations}
    end

    def self.verify_level1(searches,locations,solution)
      s = solution.split("\n").map{|x| x.strip}
      pairs = s.each_slice(2).to_a

      if searches.split('+').length != pairs.length
        return [false,-1]
      end

      total = pairs.length
      sum = 0

      pairs.each do |hash,term|
        sum += 1 if Digest::MD5.hexdigest(term + SALT) == hash
      end

      score = 1.0 * sum / total

      return [score > 0.75,score]

    end

    COMMON_WORDS = ["Bank", "Bakery", "Arts", "Court", "HQ", "North", "On", "Beach", "Community", "Garden", "Hot", "Gallery", "Dental", "on", "Golf", "Downtown", "Coffee", "Theatre", "/", "Yonge", "Gym", "Library", "Family", "In", "Car", "International", "Square", "Ave", "Express", "Shop", "Village", "Green", "Bloor", "at", "Big", "High", "Dog", "Services", "Public", "Clinic", "Studio", "Bistro", "Inc.", "Fitness", "Dr", "Health", "de", "Salon", "St.", "Casa", "A", "Church", "King", "Center", "for", "Avenue", "Spa", "East", "Store", "Home", "University", "Inn", "@", "Room", "Market", "Food", "Hotel", "Hair", "Place", "Pizza", "Dr.", "Bay", "the", "Hamilton", "Of", "West", "Grill", "City", "Station", "Building", "College", "Toronto", "Pub", "Lounge", "Hall", "And", "Office", "Canadian", "St", "Stop", "School", "Canada", "Club", "Street", "Cafe", "House", "of", "Bus", "Restaurant", "Bar", "and", "The", "Park", "Centre", "-", "&"] ;

    def self.remove_common_words(input) #array of words
      return input - COMMON_WORDS
    end

    def self.swap_words(input) #array of words
      return swap_letter(input)
    end

    def self.obfuscate_level2(string)
      words = string.split(" ")
      words = remove_common_words(words)
      words = swap_words(words) if rand < 0.1

      arr = words.join(" ").split(//)

      arr = jumble_case(arr) if rand < (0.2 + 0.3 * arr.length / 18)
      arr = swap_letter(arr) if rand < (0.2 + 0.3 * arr.length / 18)
      arr = remove_letter(arr) if rand < (0.2 + 0.3 * arr.length / 18)
      arr = replace_letter(arr) if rand < (0.2 + 0.3 * arr.length / 18)
      arr = add_letter(arr) if rand < (0.2 + 0.3 * arr.length / 18)

      return arr.join()
    end

    def self.generate_level2
      locations = LOCATIONS.sort_by{rand}[0..100]
      searches = locations.sort_by{rand} #.sort_by{rand}[0..100]

      hash_searches = []

      searches.each do |search|
        hash = Digest::MD5.hexdigest(search + SALT)
        search = obfuscate_level2(search)
        hash_searches << [hash, search]
      end

      return {searches: hash_searches, locations: locations}
    end

    def self.verify_level2(searches,locations,solution)
      return verify_level1(searches,locations,solution)
    end


    def self.generate_puzzle(level, *args)
      return self.send("generate_level#{level}", *args)
    end

    def self.verify_puzzle(level, *args)
      return self.send("verify_level#{level}", *args)
    end
  end

  module Dojo1

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

    def self.generate_puzzle(level, *args)
      return self.send("generate_level#{level}", *args)
    end

    def self.verify_puzzle(level, *args)
      return self.send("verify_level#{level}", *args)
    end
  end

end
