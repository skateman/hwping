require 'mkmf'
$CFLAGS = '--std=gnu++14 -O3'
$LDFLAGS = '-lopencv_core -lopencv_highgui -lopencv_stitching'

have_library('opencv_core')
have_library('opencv_highui')
have_library('opencv_stitching')

create_header
extension_name = 'webcam'
dir_config(extension_name)
create_makefile(extension_name)
