require "./gen_utils.rb"

hash_table = text_to_hash
print "Dump? <y/n> "
dump(hash_table) if STDIN.gets.chomp.downcase == 'y'
print "Analysis? <y/n> "
analysis(hash_table) if STDIN.gets.chomp.downcase == 'y'
print "Check Files? <y/n> "
check_files if STDIN.gets.chomp.downcase == 'y'