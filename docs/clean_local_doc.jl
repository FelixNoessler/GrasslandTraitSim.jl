import Pkg
Pkg.rm("GrasslandTraitSim")

img_path = "src/img/"
[img[1] == '.' ? "" : rm("$(img_path)$img") for img in readdir(img_path)]

assets_path = "src/assets/"
[file[1] == '.' ? "" : rm("$(assets_path)$file") for file in readdir(assets_path)]

rm("build/", recursive = true)
