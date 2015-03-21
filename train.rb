require 'yaml'
require 'json'
require 'benchmark'


def create_hash(text_file)
	line = text_file.gets

	wordStruct = Struct.new(:WORD,:HASH, :TOTAL)
	# [Hash.new { |hash, key| hash[key] = 0 }, 0]
	hash_table = Hash.new { |hash, key| hash[key] = wordStruct.new(key,Hash.new { |hash, key| hash[key] = 0 }, 0) }


	while line_array = text_file.gets
		line_array = line_array.downcase.gsub(/"/, "")
		line_array = line_array.split(/\s/)
		line_array.each_with_index do |word, i|
			if i < line_array.size-1
				hash_table[word][:HASH][line_array[i+1]] += 1
				hash_table[word][:TOTAL] += 1
			end
		end
	end
	return hash_table
end

def analysis(hash)
	# out_file.puts "Hash Map Size: #{hash_table.size} total words"
	# hash_table.each do |key| 
	# 	key.last.each_pair { |name, val| out_file.puts "#{name} = #{val}" } 
	# end

	most = []
	greater_than_val = 300
	hash_table.each { |k,v| most << [k, v[:HASH].size] if v[:HASH].size > greater_than_val }

	puts "Words with >#{greater_than_val} values:"
	most.each {|a| print a; puts}
end

def dump(hash)
	out_file1 = File.open("yaml_output.txt", "w")
	out_file2 = File.open("json_output.txt", "w")

	yaml_bench = Benchmark.measure { out_file1.puts YAML::dump(hash) }
	json_bench = Benchmark.measure { out_file2.puts JSON.generate(hash) }

	puts "YAML BENCHMARK: #{yaml_bench}"
	puts "JSON BENCHMARK: #{json_bench}"

	out_file1.close()
	out_file2.close()
end

def check_files()
	yaml_in_file1 = File.open("yaml_output.txt", "r")
	json_in_file2 = File.open("json_output.txt", "r")

	yaml_string = yaml_in_file1.readlines().join()
	json_string = json_in_file2.readlines().join()

	yaml_hash = YAML::load(yaml_string)
	json_hash = JSON.parse(json_string)
	
	same = true
	yaml_hash.each_pair { |key, val| same =  (json_hash[key].to_s == val.to_s ) & same }
	puts same
	key = "chapter"
	# puts yaml_hash[key].to_s == json_hash[key].to_s
	
end


puts ARGV.first
txt_file = File.open(ARGV.first, "r")
hash_table = create_hash(txt_file)
# dump(hash_table)
check_files
txt_file.close()