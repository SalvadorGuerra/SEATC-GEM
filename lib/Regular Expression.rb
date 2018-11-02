# Regular Expression Analyzer
# @attr regex [Regexp] Regular Expression
# @attr errno [Integer] Identifier for errors
class RegularExpression
  @regex
  attr_accessor :errno
  # Identifier for errors
  # @return [Integer] If there are errors value is more than 0, otherwise is 0
	def errno()
		return @errno
	end

  def initialize
    @errno = 0
  end
	# File reader
	# @param file [String] File location
	# @return [Array[String]] Array containing separated lines of the file
  def readFile(file)
    file = File.new(file, "r")
    line = file.read
    file.close
    lines = line.split("\n")
  end
	# Regular expression creation
	# @param lines [Array[String]] Lines of the file
	# @return [Void]
  def createRegex(lines)
    regex = ""
#    if lines[0].contains? "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>") != nil
    if !lines[0].include? "JFLAP"
      @errno = 1
      return
      # return false
    end
    #if !lines[1].match "\t<type>re</type>"
    if !lines[1].include? "\t<type>re</type>"
      @errno = 2
      return
      # return false
    end
    regex = lines[3]
    regex.slice! "\r"
    regex.slice! "\t<expression>"
    regex.slice! "&#13;"
    regex.reverse!
    regex.slice! ("</expression>".reverse)
    regex.reverse!
    @regex = Regexp.new "^" + regex + "$"
  end
  # Determine if a string is accepted by a regular expression
  # @param file [String] JFLAP file location
  # @param input [String] String to be validated
  # @return [Boolean] True if string was accepted, False otherwise
  def analyze(file, input)
    createRegex(readFile(file))
    return false if @errno != 0 
    if @regex.match(input) != nil
      return true
    else
      return false
    end
  end
end
