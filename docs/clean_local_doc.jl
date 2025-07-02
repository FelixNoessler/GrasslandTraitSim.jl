import Pkg
try Pkg.rm("GrasslandTraitSim") catch end
try Pkg.rm("LiveServer") catch end
rm("docs/build/", recursive = true)
