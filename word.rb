class Word
	attr_accessor :word, :hash, :total, :percent
	def initialize(word, hash, total, percent)
		@word = word
		@hash = hash
		@total = total
		@percent = percent
	end

	def marshal_dump
		[@word, @hash, @total, @percent]
	end

	def marshal_load array
		@word, @hash, @total, @percent = array
	end
end