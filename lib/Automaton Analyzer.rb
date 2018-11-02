# Automaton Analyzer State	
class AutomatonState
	@id
	@nombre
	@transitions
	@final
  # @param id [Integer] ID for the state
  # @param nombre [String] Name of the state (JFlap Label)
  # @param final [Boolean] Determine if the state is final state
	def initialize(id, nombre, final)
		@id = id
		@nombre = nombre
		@transitions = Hash.new
		@final = final
	end
  # Add a transition to the state
  # @param char [String] Transition value
  # @param to [Integer] State where the transition goes
	# @return [Void]
	def addTrans(char, to)
		if @transitions[char] == nil
			@transitions[char] = Hash.new
		end
		@transitions[char][to] = to
	end
  # Return the list of transitions
  # @param char [String] List of transitions for an specific input
	# @return [Hash] List of transitions
	def transAt(char)
		ret = @transitions[char]
	end
	# Return all the transitions for the state
	# @return [Hash] List of all transitions
	def getTrans
		return @transitions
	end
	# Return name of the state
	# @return [String] Name of the state
	def getName
		return @nombre
	end
	# Return if the state is final state
	# @return [Boolean] 1 if the state is final, 0 otherwise
	def final()
		ret = @final
	end
end

# Analyzer for both kind of automatons: deterministic and non-deterministic
# First create the analyzer with new, 
# then use the analyze method to know if the string is accepted or not
# @attr valid [Boolean] Determine if a string is valid or not in certain time of the instance
# @attr errno [Integer] Identifier for some errors on the analyzer
# @attr deterministic [Boolean] Determine if {#isDeterministic} check is needed
class AutomatonAnalyzer
	attr_accessor :valid, :deterministic, :errno
	# Return errno of the analyzer
	# @return [Boolean] 0 errno is that the analyzer completed with no error, otherwise it is different to 0
	def errno()
		return @errno
	end
	# Initialize the analyzer
	# @param deterministic [Boolean] Define if the Automaton will be deterministic or non-deterministic
  def initialize(deterministic)
		@deterministic = deterministic
		@errno = 0
  end
	# Check if the automaton is deterministic
	# @param states [Array] List of automaton's transitions
	# @return [Boolean] 1 if the automaton is deterministic, 0 otherwise
  def isDeterministic(states)
    return false if !@deterministic
    states.each do |estado|
        transiciones = estado.getTrans
        transiciones.each do |transition|
             return false if estado.transAt(transition[0]).length > 1
        end
    end
  end
	# Return state id from a read line
	# @param modified [String] Line where ID of the state is contained
	# @return [Integer] State ID
	def getStateID(modified)
		modified.slice! "\t\t<state id=\""
		lastQuota = true
		id = 0
		while(lastQuota)
			id = id * 10
			char = modified[0]
			modified.slice! modified[0]
			lastQuota = (modified[0] != "\"")
			id = id + char.to_i
		end
		id = id
	end
	# Return state name from a read line
	# @param modified [String] Line where name of the state is contained
	# @return [String] State name
	def getStateName(modified)
		modified.slice! "\" name=\""
		lastQuota = true
		id = ""
		while(lastQuota)
			id = id + modified[0]
			modified.slice! modified[0]
			lastQuota = (modified[0] != "\"")
		end
		id = id
	end
	# Return the next state of the transition 
	# @param modified [String] Line where next state is contained is contained
	# @return [Integer] Next state of a transition
	def readTransInt(modified)
		lastQuota = true
		id = 0
		while(lastQuota)
			id = id * 10
			char = modified[0]
			modified.slice! modified[0]
			lastQuota = (modified[0] != "<")
			id = id + char.to_i
		end
		id = id

	end
	# Return if a string is valid for an automaton
	# @param initial [AutomatonState] Initial state
	# @param states [Array[AutomatonState]] List of transitions
	# @param line [String] String to be validated
	# @return [Boolean] True if the string is accepted, false otherwise
	def validateString(initial, states, line)
		st = initial
		usedLine = String.new line
		if(usedLine != "")
			char = usedLine[0]
			usedLine.slice! char
			sts = states[st].transAt(char)
			if sts != nil
				sts.each do |transition|
					v = validateString(transition[0], states, usedLine)
				end
			end
		else
			if(states[st].final == 1)
				@valid = true
			end
		end
	end

	# Returns true if the automaton ends in final state, returns false otherwise
	# @param sourceFile [String] JFLAP file location
	# @param testString [String] String to be analyzed
	# @return [Boolean] True if the string is accepted, False otherwise
	def analyze(sourceFile, testString)
		file = File.new(sourceFile, "r")
		line = file.read
		file.close
		counter = 1
		lines = line.split("\n")
		for lin in lines
			counter = counter + 1
		end
		if !lines[0].include? "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
			@errno = 1
			return false
		end
		# Check if finite automaton
		if !lines[1].match "<type>fa</type>"
			@errno = 2
			return false
		end
		states = []
		counter = 4
		i = 0
		initialState = nil
		modified = lines[counter]
		while(modified.include? "state")
			final = 0
			aux = counter
			id = getStateID(modified)
			nombre = getStateName(modified)
			if(lines[counter + 3 ].include? "initial")
				aux = aux + 1
				initialState = id
			end
			if(lines[aux + 3].include? "final")
				final = 1
				aux = aux + 1
			end
			counter = aux + 4
			modified = lines[counter]
			states[id] = AutomatonState.new(id, nombre, final)
			i = i + 1
		end
		counter = counter + 1
		modified = lines[counter]
		while(modified.include? "transition")
			counter = counter + 1
			modified = lines[counter]
			modified.slice! "\t\t\t<from>"
			from = readTransInt(modified)
			counter = counter + 1
			modified = lines[counter]
			modified.slice! "\t\t\t<to>"
			to = readTransInt(modified)
			counter = counter + 1
			modified = lines[counter]
			while modified.include? "control"
				counter = counter + 1
				modified = lines[counter]
			end
			modified.slice! "\t\t\t<read>"
			trans = modified[0]
			states[from].addTrans(trans, to)
			counter = counter + 2
			modified = lines[counter]
		end
		#Validate
    lin = testString
    return false if(@deterministic && !isDeterministic(states))
		return false if initialState == nil
		valid = validateString(initialState, states, lin)
		if @valid
			ret = true
		else
			ret = false
		end
	end
end

