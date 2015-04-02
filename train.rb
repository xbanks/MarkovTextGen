require "./gen_utils.rb"
# Makes sure we actually have files to use

puts "Number of args: #{ARGV.size}"
if ARGV.size == 0
	puts "Usage: ruby train.rb <text files>"
	puts "ex: ruby train.rb example1.txt example2.txt example3.txt"
	exit(0)
end

hash_table = text_to_hash(ARGV)
print "Dump? <y/n> "
dump(hash_table) if STDIN.gets.chomp.downcase == 'y'
print "Analysis? <y/n> "
analysis(hash_table) if STDIN.gets.chomp.downcase == 'y'
print "Check Files? <y/n> "
check_files if STDIN.gets.chomp.downcase == 'y'