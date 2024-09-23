set ( CMAKE_GENERATOR_PLATFORM     x64 )
set ( CMAKE_CXX_STANDARD		   23 )
set ( CMAKE_CXX_STANDARD_REQUIRED  ON )

function ( apply_compile_options TARGET )
	if ( ${MSVC} )
		target_compile_options ( ${TARGET}
			PRIVATE
			/W4
			/MP
			/we4265 # Missing virtual dtor
			/we4834 # Discarding result of [[nodiscard]] function
			/we4456 # Name shadowing
			/we4457 # Name shadowing
			/we4458 # Name shadowing
			/we4459 # Name shadowing
			# /wd4251
			/we5205 # Dtor on iface is not virtual
		)
		
		set_target_properties(
			${TARGET} PROPERTIES
			DEBUG_POSTFIX "-d"
		)
	else ()
		message ( "apply_compile_options: no options for non-msvc compiler" )
	endif ()
endfunction ()
