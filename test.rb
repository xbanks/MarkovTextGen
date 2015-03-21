Word = Struct.new(:word, :next_wrds, :total)

word = Word.new("xavier", {"banks" => 1, "ramone" => 23, "hi" => 2}, 26)
puts word[:total]
puts
all_words = Hash.new { |hash, key| hash[key] = Word.new(key, Hash.new { |hash, key| hash[key] = 0 }, ) }

all_words["Xavier"][:next_wrds]["Ramone"]+=1
all_words["Xavier"][:next_wrds]["Banks"]+=1
all_words["Banks"][:next_wrds]["Hi"]+=1
all_words["Banks"][:next_wrds]["goodbye"]+=1
size = all_words["Xavier"][:next_wrds].size
puts "size of :next_wrds = #{size}"

puts all_words