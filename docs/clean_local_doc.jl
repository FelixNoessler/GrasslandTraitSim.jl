import Pkg
Pkg.rm("GrasslandTraitSim")

img_path = "docs/src/img/"
[img[1] == '.' ? "" : rm("$(img_path)$img") for img in readdir(img_path)]

assets_path = "docs/src/assets/"
[file[1] == '.' ? "" : rm("$(assets_path)$file") for file in readdir(assets_path)]

rm("docs/build/", recursive = true)
rm("docs/src/index.md")
