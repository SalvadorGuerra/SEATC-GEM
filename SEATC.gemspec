
Gem::Specification.new do |s|
  s.name               = "SEATC"
  s.version            = "0.3.0"
  s.default_executable = "SEATC"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Salvador Guerra Delgado"]
  s.date = %q{2018-11-01}
  s.description = "A gem for development on SEATC, can be used for other system that requires automaton and grammars analysis"
  s.email = %q{salvador.guerra.delgado2@gmail.com}
  s.files = ["Rakefile", "lib/Automaton Analyzer.rb", "lib/Regular Grammar Analyzer.rb", 
  "lib/Regular Expression.rb", "lib/PDA.rb","lib/Grammar Analyzer.rb", "lib/Grammar Reader.rb", "lib/Turing Analyzer.rb", "lib/Turing Reader.rb", 
  "bin/Deterministic Finite Automaton", "bin/Nondeterministic Finite Automaton", 
  "bin/Regular Grammar", "bin/Grammar Analyzer", "bin/Regular Expression", "bin/Turing Analyzer",
  "bin/Pushdown Automaton", "samples/Finite Automaton.jff", "samples/Regular Grammar.jff", "samples/Turing Machine.jff",
  "samples/Regular Expression.jff", "samples/Pushdown.jff", "samples/Deterministic Finite Automaton.jff",
  "samples/Nondeterministic.jff"]
  s.test_files = []
  s.homepage = %q{http://rubygems.org/gems/SEATC}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{SEATC}
  s.license = 'MIT'

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
