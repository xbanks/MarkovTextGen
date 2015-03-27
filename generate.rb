require "./gen_utils.rb"

# Generates a sentence with up to @num_words amount of words based on the @first word
# This is done using the given hash that should have been created using the given train.rb file



def generate_sentence(hash, first_word, num_words = 10)
	sentence = [first_word]
	sentence_ends = ['.', '!', '?']

	(num_words-1).times do
		arr = []
		arr << sentence[-2] if sentence.size > 1
		arr << sentence[-1]
		# puts hash[arr]
		if hash[arr]
			sentence << draw(hash[arr][:HASH]) 
		elsif hash[arr.last]
			sentence << draw(hash[arr.last][:HASH])
		else
			return sentence.join(" ")
		end

		sentence_ends.each do |delim|
			return sentence.join(" ") if sentence.last.include? delim
		end
	end 

	return sentence.join(" ")
end

def draw(hash)
	rand = Random.rand() * 100

	hash = hash.to_a
	sums = []

	hash.each_with_index { |e, i| sums << (sums.last || 0) + hash[i][1][:pct] }
	hash.each_with_index { |e, i| return e[0] if rand < sums[i] }
end

# Creates a Hash table loaded from an input file
# the default filename is used for testing mostly because it's quicker
def load_hash(hash = nil)
	default = "yaml_output.yaml"
	print "filename: "

	filename = STDIN.gets.chomp
	filename = filename.downcase == "def" ? default : filename
	filetype = filename.split(".").last
	
	file = File.open(filename, "r") if exists = File.exist?(filename)

	if !exists
		puts "File #{filename} does not exist"
		exit(0)
	elsif (file_string = file.readlines.join).length == 0
		puts "File #{filename} is empty"
		exit(0)
	end

	benchmark = Benchmark.measure {puts "LOADING YAML"; hash = YAML::load(file_string) } if filetype == "yaml"
	benchmark = Benchmark.measure {puts "LOADING JSON"; hash = JSON.parse(file_string) } if filetype == "json"
	if hash == nil
		puts "invalid filename" 
		exit(0)
	end
	
	puts "LOAD TIME: #{benchmark}"
	puts "DONE\n"
	return hash
end

# Prompts the user for how to get the hash file to be used in sentence generation
# The user can either create a new one using the text_to_hash function from train.rb
# Or load one from a file using the load_hash function
def get_hash
	puts "Options:"
	puts "1: Create new Hash"
	puts "2: Load Hash from file"
	print "Choice: "
	hash_table = Hash.new
	case STDIN.gets.chomp.to_i
	when 1
		print "Filenames: (separate by space) "
		filenames = STDIN.gets.chomp.split(" ")
		hash_table = text_to_hash(filenames)
	when 2
		hash_table = load_hash
	else
		puts "invalid choice, bye bye..."
		exit(0)
	end
end

# Prompts the user for a @start_word to begin a sentence with
# Uses the generate_sentence method to create the sentence based on this @start_word
def make_sentence(hash_table)
	print "Start word: "
	start_word = STDIN.gets.downcase.chomp 
	print "Word count: "
	word_count = STDIN.gets.chomp.to_i
	sentence = generate_sentence(hash_table, start_word, word_count)
	
	puts "#{sentence}\n"
	outfile = File.open("genout.txt", "a")
	outfile.puts "-----Start word: #{start_word}------"
	outfile.puts "Word count: #{word_count}"
	outfile.puts "TEXT = #{sentence}"
	outfile.close
	puts "DONE"
end

hash = get_hash
another = 'y'
while(another == 'y')
	make_sentence(hash)
	print "Another? <y/n>"
	another = STDIN.gets.downcase.chomp
end