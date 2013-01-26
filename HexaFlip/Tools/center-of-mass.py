#!/usr/bin/env python

import struct
from gimpfu import *

def center_of_mass(img, drawable):
	# start the undo group
	pdb.gimp_image_undo_group_start(img)

	width = drawable.width
	height = drawable.height

	if pdb.gimp_drawable_has_alpha(drawable):
		# extract pixels
		region = drawable.get_pixel_rgn(0,0,width,height)
		pixels = region[0:width,0:height];

		# initialize
		weighted_sum_x = 0.0
		weighted_sum_y = 0.0
		total_weight = 0.0

		# assumption: last component of each pixel is alpha
		pixel_size = len(region[0,0]);
		offset = pixel_size-1

		gimp.progress_init("Computing Center of Mass...")

		# iterate over pixels
		for y in range(0,height):
			for x in range(0,width):
				# determine pixel weight
				alpha = struct.unpack('B',pixels[offset])[0]
				pixel_weight = alpha/255.0

				# sum up weighted coordinates of pixel centers
				weighted_sum_x += pixel_weight*(x+0.5)
				weighted_sum_y += pixel_weight*(y+0.5)
				
				# keep track of the total weight
				total_weight += pixel_weight

				# skip to next pixel offset
				offset += pixel_size

			# update progress
			gimp.progress_update(1.0*y/height)

		# avoid division by zero for full-alpha drawable
		if total_weight > 0.0:
			center_of_mass_x = weighted_sum_x / total_weight
			center_of_mass_y = weighted_sum_y / total_weight
		else:
			center_of_mass_x = width / 2.0
			center_of_mass_y = height / 2.0
	else:
		center_of_mass_x = width / 2.0
		center_of_mass_y = height / 2.0

	# set guides
	pdb.gimp_image_add_vguide(img, int(drawable.offsets[0]+center_of_mass_x+0.5))	
	pdb.gimp_image_add_hguide(img, int(drawable.offsets[1]+center_of_mass_y+0.5))

	# end the undo group
	pdb.gimp_image_undo_group_end(img)
	
	return

register(
    "center-of-mass",
	"Determines the Center of Mass",
	"Places a guide cross at the center of mass of a layer/mask, where a pixel's opacity determines its weight.",
	"Christian Schuster",
	"Christian Schuster",
	"2012",
	"<Layers>/Mark Center of Mass",
	"RGB*, GRAY*",
	[
		(PF_IMAGE, "inImage", "Image", None),
		(PF_DRAWABLE, "inDrawable", "Drawable", None),
	],
	[
	],
	center_of_mass)

main()
