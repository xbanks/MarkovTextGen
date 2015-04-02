require 'yaml'
require 'json'
require 'benchmark'
require './word.rb'

# Creates or updates a hash table using the input text file
def create_hash(text_file, chain_length = 2, hash_table = nil)
	# line = text_file.gets
	# wordStruct = Struct.new(:WORD,:HASH, :TOTAL, :PERCENT)
	# [Hash.new { |hash, key| hash[key] = 0 }, 0]

	hash_table ||= Hash.new { |hash, key| hash[key] = Word.new(key,Hash.new { |hash, key| hash[key] = {count: 0, pct: 0} }, 0, 0) }

	# 
	while line_array = text_file.gets
		line_array = line_array.downcase.gsub(/"/, "")
		line_array = line_array.split(/\s/)
		line_array.each_with_index do |word, i|
			if i < line_array.size-1
				# puts "Adding #{word}..."
				arr = []

				0.upto(chain_length-1) do |j|
					arr.unshift( line_array[i-j] )

					if arr.size > 1
						hash_table[arr].hash[line_array[i+1]][:count] += 1
						hash_table[arr].total += 1
					else
						hash_table[word].hash[line_array[i+1]][:count] += 1
						hash_table[word].total += 1
					end
				end

			end
		end
	end

	# Fixes the percentages for each word in the hash
	hash_table.each_pair do |key1, value1| 
		value1.hash.each_pair do |key2, value2|
			total = value1.total
			num = value2[:count].to_f
			percent =  (num / total) * 100
			hash_table[key1].hash[key2][:pct] = percent
		end
	end

	return hash_table
end

# Analyzes the given hash.
# Displays the amount of words with hash sizes greater than {greater_than_value}
def analysis(hash, greater_than_value = 100)
	# out_file.puts "Hash Map Size: #{hash_table.size} total words"
	# hash_table.each do |key| 
	# 	key.last.each_pair { |name, val| out_file.puts "#{name} = #{val}" } 
	# end
	puts "Begin Analysis..."
	most = []
	hash.each { |k,v| most << [k, v.hash.size] if v.hash.size > greater_than_value }

	puts "\tWords with >#{greater_than_value} values:"
	most.each { |a| puts "\t\t#{a}" }
	puts "End Analysis..."
end

def fix_hash(hash)
	hash.each_value do |val|
		val.hash = make_dumpable(val.hash)
	end

	hash.default = nil
	hash
end

def make_dumpable(hash)
	return hash if hash.default != nil
	hash.default = nil
	return hash
end

# Dumps the contents of the given hash into two files
# One using YAML and another using JSON to benchmark the speed of each method
def dump(hash, yaml_filename = "yaml_output.yaml", json_filename = "json_output.json")
	puts "Dumping..."
	out_file1 = File.open(yaml_filename, "wb+")
	out_file2 = File.open(json_filename, "wb+")

	print "\tDumping YAML..."
	hash = fix_hash(hash)
	yaml_bench = Benchmark.measure { out_file1.puts Marshal::dump(hash) }
	print "DONE\n"
	print "\tDumping JSON..."
	json_bench = Benchmark.measure { out_file2.puts JSON.generate(hash) }
	print "DONE\n"

	puts "\tYAML DUMP BENCHMARK: #{yaml_bench}"
	puts "\tJSON DUMP BENCHMARK: #{json_bench}"

	out_file1.close
	out_file2.close
	puts "Done..."
end

# Opens two files, one created using YAML and the other, JSON
# Compares the hash contents of each to determine whether or not they match
def check_files(yaml_filename = "yaml_output.yaml", json_filename = "json_output.json")
	puts "Checking Files..."
	
	yaml_in_file1 = File.open(yaml_filename, "r")
	json_in_file2 = File.open(json_filename, "r")

	yaml_string = yaml_in_file1.readlines().join()
	json_string = json_in_file2.readlines().join()

	print "\tLoading YAML from #{yaml_filename}..."
	yaml_hash = nil
	yaml_bench = Benchmark.measure { yaml_hash = Marshal::load(yaml_string) }
	print "DONE\n"

	print "\tLoading JSON from #{json_filename}..."
	json_hash = nil
	json_bench = Benchmark.measure { json_hash = JSON.parse(json_string) }
	print "DONE\n"
	
	puts "\tYAML LOAD BENCHMARK: #{yaml_bench}"
	puts "\tJSON LOAD BENCHMARK: #{json_bench}"

	same = true
	differences = []
	yaml_hash.each_pair do |key, val| 
		diff = (json_hash[key].to_s == val.to_s )
		differences << "KEY: \"#{key}\"" if !diff
		same &= diff #& same
	end
	match = (same) ? "match" : "don't match"
	puts "String values #{match}"
	print "Print differences? <y/n>"
	puts differences if STDIN.gets.chomp.downcase == 'y'
	# key = "chapter"
	# puts yaml_hash[key].to_s == json_hash[key].to_s
	puts "Done..."
end

def text_to_hash(args)
	hash_table = nil
	args.each do |file|
		txt_file = File.open(file, "r")
		print "Adding #{file} to hash..."
		hash_table = create_hash(txt_file, 3, hash_table)
		print "DONE\n"
		txt_file.close()
	end
	hash_table
end