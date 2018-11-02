# Reader for JFLAP Grammar file
# @attr error [Integer] Identifier for certain errors on reading
class GrammarReader
	# Grammar Reader SYNTAX ERROR
	SYNTAX_ERROR = 100
	# Grammar Reader PRODUCTION ERROR
	PRODUCTION_ERROR = 101
	attr_accessor :error
  def initialize()
    @error = 0
  end
	# Return the left part of a production
	# @param modified [String] String containing the left part of production
	# @return [String] Left part of production
  def getLeft(modified)
  	modified.slice! "\t\t<left>"
  	ret = modified[0]
  end
	# Return the right part of a production
	# @param modified [String] String containing the right part of production
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
	# @return [Array[String]] Array containing lines in file
  def readFile(file)
    file = File.new(file, "r")
    line = file.read
    file.close
    lines = line.split("\n")
  end

  # Returns a Hash containing the productions
	# @param lines [Array[String]] Separated lines of the file
	# @return [Hash] Hash containing in key the left part of the production, and in value an Array with the right parts of the production
  def createProductions(lines)
    productions = Hash.new
    if !lines[0].include? "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><!--Created with JFLAP"
      @error = SYNTAX_ERROR
      return productions
    end
    if !lines[1].include? "\t<type>grammar</type>"
      @error = SYNTAX_ERROR
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
    	counter = counter + 4
    	modified = lines[counter]
      if productions[left] == nil
        productions[left] = Array.new
      end
      productions[left].push(right)
    	i = i + 1
    end
    return productions
  end
end
