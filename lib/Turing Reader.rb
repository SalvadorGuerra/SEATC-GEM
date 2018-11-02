# JFLAP Turing Machine File reader
class TuringReader
	# Lines of the file
	# @param file [String] File location
	# @return [Array[String]] Separated lines of the file
	def readFile(file)
		file = File.new file, "r"
		line = file.read
		file.close
		lines = line.split "\n"
	end
end
