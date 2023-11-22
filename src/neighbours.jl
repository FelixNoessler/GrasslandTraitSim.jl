# """
#     set_neighbours_surroundings!(; calc, input_obj)

# Define each patch's neighbouring and surrounding patches.

# ![](../img/neighbours.svg)
# """
# function set_neighbours_surroundings!(; calc, input_obj)
#     @unpack patch_xdim, patch_ydim, npatches = input_obj.simp
#     @unpack nneighbours, surroundings, neighbours, xs, ys = calc.patch

#     i = 0
#     for x in 1:patch_xdim
#         for y in 1:patch_ydim
#             i += 1

#             xs[i] = x
#             ys[i] = y
#         end
#     end

#     neighbours .= missing

#     for pa in Base.OneTo(npatches)
#         x = xs[pa]
#         y = ys[pa]

#         if x - 1 > 0
#             neighbours[pa, 1] = get_patchindex(x - 1, y; patch_xdim)
#         end
#         if x + 1 <= patch_xdim
#             neighbours[pa, 2] = get_patchindex(x + 1, y; patch_xdim)
#         end
#         if y + 1 <= patch_ydim
#             neighbours[pa, 3] = get_patchindex(x, y + 1; patch_xdim)
#         end
#         if y - 1 > 0
#             neighbours[pa, 4] = get_patchindex(x, y - 1; patch_xdim)
#         end
#     end

#     surroundings[:, 2:5] .= neighbours
#     surroundings[:, 1] .= Base.OneTo(npatches)

#     for pa in Base.OneTo(npatches)
#         nneighbours_patch = 0
#         for i in 1:4
#             if !ismissing(neighbours[pa, i])
#                 nneighbours_patch += 1
#             end
#         end
#         nneighbours[pa] = nneighbours_patch
#     end

#     return nothing
# end

# function get_patchindex(x, y; patch_xdim)
#     return x + (y - 1) * patch_xdim
# end
