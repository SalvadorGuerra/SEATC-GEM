require 'thread'
load 'Turing Reader.rb'
# Turing machine state
# @attr tag [String] Tag of the state
# @attr id [Integer] ID of the state
# @attr name [String] Name of the state
# @attr initial [Boolean] Determine if state is initial
# @attr final [Boolean] Determine if the state is final
# @attr transitions [Hash] List of transitions
class TuringState
  attr_accessor :tag, :id, :name, :initial, :final, :transitions
  def initialize
    @transitions = Hash.new
  end
end

# Turing Machine Transition
# @attr to [Integer] Next state
# @attr write [String] Element to write on the Turing machine tape
# @attr write [String] Position to move in the Turing machine tape
class TuringTransition
    attr_accessor :to, :write, :move
end

# Turing Machine Analyzer
# @attr reader [TuringReader] File reader
# @attr lines [Array[String]] Separated lines of the file
# @attr states [Array[TuringState]] List of states
# @attr valid [Boolean] Determine if there is a valid string
# @attr errno [Integer] Identifier for errors
# @attr initial [TuringState] Initial State
class TuringAnalyzer
  attr_accessor :reader, :lines, :states, :valid, :errno
	@initial

	# Determine the kind of error in the file
	# @return [Integer] More than 0 for error, 0 for no error
	def errno()
		return @errno
	end
	
  def initialize
    @reader = TuringReader.new
    @states = Array.new
    @initial = nil
    @valid = false
    @errno = 0
  end

	# Analyze a string using a JFLAP Turing machine
	# @param file [String] JFLAP file location
	# @param line [String] String to be validated
	# @return [Boolean] True if the string is accepted, False otherwise
  def analyze(file, line)
		@valid = false
    @lines = @reader.readFile file
    validateJFlap
    deleteLine
    validateTuringMachine
    deleteLine
    createStates
    position = 0
    until line[position] != "B"
      position = position + 1
    end
    validate line, @initial, position
    return @valid
  end

	# Check if the file is from JFLAP
	# @return [Boolean] True if file is from JFLAP, False otherwise
  def validateJFlap
    return true if @lines[0].match "JFLAP"
    @errno = 1
    return false
  end

	# Check if the file is from JFLAP Turing Machine
	# @return [Boolean] True if file is from JFLAP Turing machine, False otherwise
  def validateTuringMachine
    return true if @lines[0].match "turing"
    @errno = 2
    return false
  end

	# Create the list of states
	# @return [Void]
  def createStates
    return false if !lines[0].match "automaton"
    deleteLine
    if lines[0].match "<!--The list of states.-->"
        deleteLine
    else
      return false
    end
    while createState 
			i = 1
    end
    if lines[0].match "<!--The list of transitions.-->"
      deleteLine
    else
      return false
    end
    until createTransition == false
			i = 1
    end
  end

	# Create a Turing state
	# return [Boolean] False if there is an error, True otherwise
  def createState
    state = TuringState.new
    return false if !lines[0].match "block"
    deleteTabs
    lines[0].slice! "<block "
    # Create id
    state.id = 0
    lines[0].slice! "id=\""
    until lines[0][0] == "\""
      state.id = state.id * 10
      state.id = state.id + lines[0][0].to_i
      lines[0].slice! lines[0][0]
    end
    lines[0].slice! "\" "
    # Create name
    state.name = ""
    lines[0].slice! "name=\""
    until lines[0][0] == "\""
      state.name = state.name + lines[0][0]
      lines[0].slice! lines[0][0]
    end
    deleteLine
    # Tags
    return false if !lines[0].match "tag"
    deleteLine
    # X position
    deleteLine
    # Y position
    deleteLine
    # Initial?
    state.initial = false
    if lines[0].match "initial"
      @initial = state.id if @initial == nil
      state.initial = true
      deleteLine
    end
    # Final?
    state.final = false
    if lines[0].match "final"
      state.final = true
      deleteLine
    end
    # Check closing bracket
    return false if !lines[0].match "</block>"
    deleteLine
    @states[state.id] = state
    return true
  end

	# Create Turing transition
	# return [Boolean] False if there is an error, True otherwise
  def createTransition
    from = 0
    to = 0
    if lines[0].match "<transition>"
      deleteLine
    else
      return false
    end
    # From
    deleteTabs
    lines[0].slice! "<from>"
    until lines[0][0] == "<"
      from = from * 10
      from = from + lines[0][0].to_i
      lines[0].slice! lines[0][0]
    end
    deleteLine
    # To
    deleteTabs
    lines[0].slice! "<to>"
    until lines[0][0] == "<"
      to = to * 10
      to = to + lines[0][0].to_i
      lines[0].slice! lines[0][0]
    end
    deleteLine
    # Read
    if lines[0].match "<read/>"
      read = nil
    else
      deleteTabs
      read = 0
      lines[0].slice! "<read>"
      until lines[0][0] == "<"
        read = read * 10
        read = read + lines[0][0].to_i
        lines[0].slice! lines[0][0]
      end
    end
    deleteLine
    # Write
    if lines[0].match "<write/>"
      write = nil
    else
      deleteTabs
      write = 0
      lines[0].slice! "<write>"
      until lines[0][0] == "<"
        write = write * 10
        write = write + lines[0][0].to_i
        lines[0].slice! lines[0][0]
      end
    end
    deleteLine
    if lines[0].match "<move>R"
      move = "R"
    elsif lines[0].match "<move>L"
      move = "L"
    elsif lines[0].match "<move>S"
      move = "S"
    else
      move = nil
    end
    if @states[from].transitions[read] == nil
      @states[from].transitions[read] = Array.new
    end
    trans = TuringTransition.new
    trans.to = to
    trans.write = write
    trans.move = move
    @states[from].transitions[read].push trans
    deleteLine
    if lines[0].match "</transition>"
      deleteLine
      return true
    end
    return false
  end

	# Delete the first line
	# @return [Void]
  def deleteLine
    size = @lines.size
    newLines = Array.new
    for i in 0...size-1
      newLines[i] = @lines[i+1]
    end
    @lines = newLines
  end

	# Clear tabs of the first line
	# @return [Void]
  def deleteTabs
    until !lines[0].match "\t"
      lines[0].slice! "\t"
    end
  end

	# Validate a string
	# @param line [String] Tape for Turing machine
	# @param actual [TuringState] Actual state on the turing machine
	# @param position [Integer] Position on the tape
	# @return [Boolean] True if string is accepted, false otherwise
  def validate(line, actual, position)
    transitions = @states[actual].transitions
    # Launch no read transition
    read = line[position]
    if transitions[nil] != nil
      transitions[nil].each do |trans|
		    if read == "B"
		      if trans.write == nil
		        line[position] = "B"
		      else
		        line[position] = trans.write
		      end
		      newPos = position - 1 if trans.move == "L"
		      newPos = position + 1 if trans.move == "R"
		      newPos = position if trans.move == "S"
		      nilThread = Thread.new { validate(line, trans.to, newPos)}
		      nilThread.join
		    end
    	end
		end
    # Launch read transition / End if no transition
    read = line[position]
    if transitions[read] == nil
      if @valid == false && @states[actual].final == true
        @valid = true
      end
    else
      transitions[read].each do |trans|
        if trans.write == nil
          line[position] = "B"
        else
          line[position] = trans.write
        end
		    newPos = position - 1 if trans.move == "L"
		    newPos = position + 1 if trans.move == "R"
		    newPos = position if trans.move == "S"
		    thread = Thread.new { validate(line, trans.to, newPos)}
		    thread.join
		  end
  	end
	end
end
