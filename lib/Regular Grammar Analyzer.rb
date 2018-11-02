# Regular Grammar Production, since it is deprecated it is needed to add a Regular Grammar Checker to {#GrammarAnalyzer}
# @deprecated
# @attr left [String] Left part of production
# @attr right [Array] Right part of production
class RegularGrammarProduction
  @left
  @right
  def initialize(left)
    @left = left
    @right = []
  end
	# Add element to right production
	# @param right [String] New production to push
	# @return [Void]
  def addRight(right)
    @right.push(right)
  end
	# Get elements from right production
	# @return [Array[String]] productions
  def getRight()
    return @right
  end
end

# Regular Grammar Analyzer, since it is deprecated it is needed to add a Regular Grammar Checker to {#GrammarAnalyzer}
# @deprecated
# @attr valid [Boolean] Determine  if the string is valid in a certain time
# @attr errno [Integer] Identify errors
class RegularGrammar
  @valid
  attr_accessor :errno
	# Regular Grammar SYNTAX ERROR Identificator
	SYNTAX_ERROR = 1
	# Regular Grammar PRODUCTION ERROR Identificator
	PRODUCTION_ERROR = 2
	#Identify errors
	# @return [Integer] 0 if no errors, different from 0 otherwise
	def errno()
		return @errno
	end

  def initialize()
    @valid = false
    @errno = 0
  end
	# Get left part of production
	# @param modified [String] String containing left part of production
	# @return [String] Left part of production
  def getLeft(modified)
  	modified.slice! "\t\t<left>"
  	ret = modified[0]
  end
	# Get right part of production
	# @param modified [String] String containing right part of production
	# @return [String] Right part of production
  def getRight(modified)
  	modified.slice! "\t\t<right>"
  	ret = ""
  	while(modified[0] != "<")
        	sliced = modified[0]
  		modified.slice! sliced
  		ret = ret + sliced
  	end
  	return ret
  end

  # Returns an Array containing the lines from the file
	# @param file [String] File location
	# @return [Array[String]] Separated lines of the file
  def readFile(file)
    file = File.new(file, "r")
    line = file.read
    file.close
    lines = line.split("\n")
  end

  # Returns the Hash containing the productions
	# @param lines [Array[String]] Separated lines of JFLAP file
	# @return [Hash] Productions of the grammar
  def createProductions(lines)
    productions = Hash.new
    if !lines[0].include? "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
      @errno = 1
      return productions
    end
    if !lines[1].include? "\t<type>grammar</type>&#13;"
      @errno = 2
    	return productions
    end
    counter = 3
    i = 0
    modified = lines[counter]
    while(modified.include? "production")
    	modified = lines[counter + 1]
    	left = getLeft(modified)
    	modified = lines[counter + 2]
    	right = getRight(modified)
      while right[0] == "\t"
        right.slice! "\t"
      end
      if right.length > 2
        @error = PRODUCTION_ERROR
      end
    	counter = counter + 4
    	modified = lines[counter]
      if productions[left] == nil
        productions[left] = RegularGrammarProduction.new(left)
      end
      productions[left].addRight(right)
    	i = i + 1
    end
    return productions
  end

	# Verify lambda production
	# @param string [String] String to be verified
	# @return [Void]
  def chompLambda(string)
    if !@valid
      @valid = (string.length==0)
    end
  end
	
	# Verify only terminal production
	# @param string [String] String to be verified
	# @return [Void]
  def chompChar(string, char)
    if !@valid
      @valid = (string.length == 1 && string[0] == char)
    end
  end

	# Analyze an input
	# @param productions [Hash] Grammar productions
	# @param line [String] String to be verified
	# @param state [RegularGrammarState] Actual State
	# @return [Boolean] True if string is accepted, False otherwise
  def analyzeInput(productions, line, state)
    # Right Grammar S -> aS | a
    prods = productions[state].getRight()
    prods = prods.sort_by(&:length)
    prods.reverse!
    prods.each do |p|
      #Check for lambda
      if p.length == 0
        if line.length == 0
          return true
        else
          return false
        end
      elsif p.length == 1
        # Check for ending
        # For a terminal only production
        if p[0].downcase == p[0]
          # Terminal
          ret = p[0] == line[0] && line.length == 1
          return ret
        else
          # Non-terminal
          ret = analyzeInput(productions, line, p[0])
          return ret
        end
      elsif p.length > 1
        if line.length > 1
          # For a non-terminal and terminal production
          if p[0].downcase != p[0]
            # S -> Sa
            puts "Example S -> aS"
            return false if p[1] != line[0]
            newLine = line
            newLine.slice! p[1]
            ret = analyzeInput(productions, newLine, p[0])
            return ret
          else
            # S -> aS
            return false if p[0] != line[0]
            newLine = line
            newLine.reverse!
            newLine.slice! p[0]
            newLine.reverse!
            ret = analyzeInput(productions, newLine, p[1])
            return ret
          end
        elsif line.length == 1
          # For a non-terminal and terminal production
          if p[0].downcase != p[0]
            # S -> Sa
            return true if productions[p[0]].getRight.include? ""
            return false if p[1] != line[0]
            return true if productions[state].getRight.include?(p[1]) && p[1] == line[0]
            newLine = line
            newLine.slice! p[1]
            puts p[0]
            ret = analyzeInput(productions, newLine, p[0])
            return ret
          else
            # S -> aS
            return true if productions[p[1]].getRight.include?("")
            return false if p[0] != line[0]
            return true if (productions[state].getRight.include?(p[0]) && p[0] == line[0])
            newLine = line
            newLine.reverse!
            newLine.slice! p[0]
            newLine.reverse!
            ret = analyzeInput(productions, newLine, p[1])
            return ret
          end
        end
      end
    end
  end

	# Analyze a string from a JFLAP file
	# @param file [String] JFLAP File location
	# @param line [String] String to be verified
	# @return [Boolean] True if string is accepted, False otherwise
  def analyze(file, line)
    productions = createProductions(readFile(file))
    @valid = analyzeInput(productions, line, "S")
    puts @valid
    return @valid
  end
end
