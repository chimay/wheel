" vim: set filetype=vim:


call wheel#vortex#reset()
"call wheel#vortex#add_torus('tore')
"call wheel#vortex#add_torus()
"call wheel#vortex#add_circle('cercle')
"call wheel#vortex#add_circle()
call wheel#vortex#add_here()
"call wheel#vortex#add_file("~/racine/public/wheel/README.md")
call wheel#vortex#add_file()
echo g:wheel
call wheel#riwo#write("g:wheel", "~/racine/test/vim/riwo-write")
