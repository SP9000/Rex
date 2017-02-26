.import __file_load
.import __file_save
.import __file_name
.import __file_size

.scope file
	load = __file_load ; loads the file in (<X/>Y)
	save = __file_save 
	name = __file_name ; the name of the file used in file operations
	size = __file_size ; the size of the file used in file operations
.endscope
