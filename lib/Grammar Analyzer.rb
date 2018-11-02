require 'thread'
load 'Grammar Reader.rb'

# Analyzer for grammars
# For using it first creates the analyzer with new,
# then use the analyze method to know if the string is accepted or not
# @attr mutex [Object] Mutex for managing concurrency
# @attr valid [Boolean] Determine if a string is valid or not in certain time of the instance
# @attr errno [Integer] Identifier for some errors on the analyzer
class GrammarAnalyzer
	attr_accessor :mutex, :valid, :errno
	# Return errno of the analyzer
	# @return [Integer] 0 errno is that the analyzer completed with no error, otherwise it is different to 0
	def errno()
		return @errno
	end
	# Initialize the analyzer
	def initialize
		@mutex = Mutex.new
		@valid = false
	end
	# Synchronized println in case of need
	# @param s [String] String to be printed
	# @return [Void]
	def println(s)
		@mutex.synchronize {
			puts s
		}
	end
	# Check if a char is non-terminal
	# @param char Char to be checked
	# @return [bool] True if the char is non-terminal, False otherwise
	def isNT(char)
		return "A" <= char && char <= "Z"
	end
	# Method for removing the first char of a string
	# @param line [String] String to be modified
	# @return [String] Modified string
	def removeFirst(line)
		line.reverse!
		line.chop!
		line.reverse!
	end
	# Determine if the analyzer must continue or not
	# @param prod [String] Actual produced line
	# @param line [String] Final line to be matched
	# @return [Boolean] True if analyzer can continue, False otherwise
	def canContinue(prod, line)
		p = String.new prod
		s = 0
		for i in 0...p.length
			s = s + 1 if !isNT(p[i])
		end
		return s <= line.length
	end

	# Threaded method to determine if the string is accepted or not
	# @param prod [String] Actual produced line
	# @param line [String] String to be matched
	# @param prods [Hash] Productions of the grammar
	# @return [Void]
	def analyzer(prod, line, prods)
		while canContinue(prod, line)
			if prod.length == 0
				if line.length == 0
					@valid = true
				end
				return
			end
			if isNT(prod[0])
        if prods[prod[0]] == nil # Errno will be 0
        	@errno = 3
					return
				end
				prods[prod[0]].each do |p|
					t = Thread.new { analyzer(String.new(p + prod.slice(1, prod.length - 1)), String.new(line), prods)}
					t.join
				end
				return
			end
			if prod[0] == line[0]
				removeFirst line
				removeFirst prod
			else
				return
			end
		end
	end
	# Determine if a string is valid for a Grammar
	# @param file [String] JFLAP file location
	# @param line [String] String to be checked
	# @return [Boolean] True if the string can be matched, False otherwise
	def analyze(file, line)
		reader = GrammarReader.new
		prods = reader.createProductions(reader.readFile(file))
		@errno = reader.error
		return false if @errno != 0
		prods['S'].each do |p|
			t = Thread.new { analyzer(String.new(p), String.new(line), prods)}
			t.join
		end
		ret = @valid
	end

end

