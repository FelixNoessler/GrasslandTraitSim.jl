import Pkg
Pkg.rm("GrasslandTraitSim")
Pkg.rm("GrasslandTraitVis")

img_path = "docs/src/img/"
[img[1] == '.' ? "" : rm("$(img_path)$img") for img in readdir(img_path)]
rm("docs/build/", recursive = true)
