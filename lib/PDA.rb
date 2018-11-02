# Transition of Pushdown Automaton
# @attr destination [Integer] Next state in the transition
# @attr push [String] Elements to push in stack
# @attr pop [String] Element to pop in stack
class PDATransition
	attr_accessor :destination, :push, :pop
	# @param destination [Integer] Destination of the transition
	# @param push [String] String to be pushed on stack
	# @param pop [String] String to be popped of the stack
	def initialize(destination, push, pop)
		@destination = destination
		@push = push
		@pop = pop
	end
	# Return the destination
	# @return [Integer] Next destination
	def getDestination()
		return @destination
	end
end

# Pushdown Automaton state
# @attr id [Integer] ID of the state
# @attr nombre [String] Name of the state
# @attr transitions [Hash] Transitions of the state
# @attr final [Boolean] Determine if the state is final or not
class PDAState
	@id
	@nombre
	@transitions
	@final
	# @param id [Integer] ID of the state
	# @param nombre [String] Name of the state
	# @param final [Boolean] The state is final or not
	def initialize(id, nombre, final)
		@id = id
		@nombre = nombre
		@transitions = Hash.new
		@final = final
	end
	# Add a transition with a determinated input
	# @param char [String] Key where the transition will be added
	# @param to [Integer] ID of the next state
	# @param pop [String] Value to be popped of the stack
	# @param push [String] Value to be pushed on the stack
	# @return [Void]
	def addTrans(char, to, pop, push)
		if @transitions[char] == nil
			@transitions[char] = Hash.new
		end
		@transitions[char][to] = PDATransition.new to, push, pop
	end
	# Return the transition for a determinated input
	# @param char [String] Input to be searched
	# @return [Hash] Transitions for the input
	def transAt(char)
		ret = @transitions[char]
	end
	
	# Determine if the state is final or not
	# @return [Boolean] True if the state is final, False otherwise
	def final()
		ret = @final
	end
end

# Pushdown Automaton Analyzer
# @attr valid [Boolean] Determine if the analyzer has been invalidated or not
# @attr errno [Integer] Identifier for errors
class PDAAnalyzer
	@valid = false
	attr_accessor :errno
	# Determine error number
	# @return [Integer] Identifier of the error (0 -> No error)
	def errno()
		return @errno
	end
	
	def initialize 
		@errno = 0
	end
	# Get a state ID
	# @param modified [String] String containing the state ID
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
	# Get a state name
	# @param modified [String] String containing the state name
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
	# Get a transition push
	# @param modified [String] String containing the transition push
	# @return [String] Transtion push
	def readPush(modified)
		lastQuota = true
		id = ""
		while(lastQuota)
			id = id + modified[0]
			modified.slice! modified[0]
			lastQuota = (modified[0] != "<")
		end
		id = id
	end
	# Get a transition pop
	# @param modified [String] String containing the transition pop
	# @return [String] Transtion pop
	def readPop(modified)
		lastQuota = true
		id = ""
		while(lastQuota)
			id = id + modified[0]
			modified.slice! modified[0]
			lastQuota = (modified[0] != "<")
		end
		id = id
	end
	# Get a transition next state
	# @param modified [String] String containing the transition next state
	# @return [Integer] Transtion next state
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
	# Validate an input string
	# @param initial [PDAState] Initial state
	# @param states [Hash] Transitions of the automaton
	# @param line [String] Line to be validated
	# @param stack [Array] Stack of the automaton
	# @return [Boolean] True if the string was accepted, False otherwise
	def validateString(initial, states, line, stack)
		st = initial
		usedLine = String.new line
		if(usedLine != "")
			char = usedLine[0]
			usedLine.slice! char
			sts = states[st].transAt(char)
			if sts != nil
				sts.each do |transition|
					pushable = String.new transition[1].push
					if(stack.length == 0 && transition[1].pop != "")
						return false
					end
					if(transition[1].pop != "")
						pop = stack.pop
						if(pop != transition[1].pop)
							return false
						end
					end
					pushable.reverse!
					while(pushable!="")
						stack.push pushable[0]
						pushable.slice! pushable[0]
					end
					v = validateString(transition[0], states, usedLine, stack)
				end
			end
		else
			if(states[st].final == 1 || stack.length == 0)
				@valid = true
			end
		end
	end

	# Analyze a JFLAP file for Pushdown automaton and determine if a string is valid for that automaton
	# @param sourceFile [String] JFLAP File location
	# @param testString [String] String to be validated
	# @return [Boolean] True if the string was accepted, false otherwise
	def analyze(sourceFile, testString)
		@valid = false
		file = File.new(sourceFile, "r")
		line = file.read
		file.close
		counter = 1
		lines = line.split("\n")
		for lin in lines
			counter = counter + 1
		end
		if !lines[0].include? "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><!--Created with JFLAP 6.4.--><structure>"
			@errno = 1
			return false
		end
		# Check if pushdown automaton
		if !lines[1].match "<type>pda</type>"
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
			states[id] = PDAState.new(id, nombre, final)
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
			modified.slice! "\t\t\t<read>"
			read = modified[0]
			counter = counter + 1
			modified = lines[counter]
			if(modified.include? "<pop>")
				modified.slice! "\t\t\t<pop>"
				pop = readPop(modified)
			else
				pop=""
			end
			counter = counter + 1
			modified = lines[counter]
			if(modified.include? "<push>")
				modified.slice! "\t\t\t<push>"
				push = readPush(modified)
			else
				push=""
			end
			states[from].addTrans(read, to, pop, push)
			counter = counter + 2
			modified = lines[counter]
		end
		#Validate
		lin = testString
		stack = Array.new
		valid = validateString(initialState, states, lin, stack)
		if @valid
			ret = true
		else
			ret = false
		end
	end
end
