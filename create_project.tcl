# Create a reproducible Vivado project for the Basys 3 guess game.
set script_dir [file dirname [file normalize [info script]]]
set repo_root  [file normalize "$script_dir/.."]
set build_dir  [file normalize "$repo_root/build/vivado"]

file mkdir $build_dir
create_project guess_game $build_dir -part xc7a35tcpg236-1 -force

add_files -norecurse [list \
    "$repo_root/rtl/top.v" \
    "$repo_root/rtl/io.v" \
    "$repo_root/rtl/simple_ram.v" \
    "$repo_root/rtl/seven_seg.v" \
    "$repo_root/third_party/picorv32/picorv32.v" \
]

add_files -fileset constrs_1 -norecurse "$repo_root/constraints/Basys3.xdc"
set_property top top [current_fileset]
update_compile_order -fileset sources_1
puts "Project created at: $build_dir"
