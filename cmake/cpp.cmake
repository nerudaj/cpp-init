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

function ( enable_autoformatter TARGET )
	file ( COPY_FILE
		"${CPPINIT_FOLDER}/.clang-format"
		"${CMAKE_CURRENT_SOURCE_DIR}/.clang-format"
	)

	target_sources ( ${TARGET} PRIVATE 
		"${CMAKE_CURRENT_SOURCE_DIR}/.clang-format"
	)

	
endfunction ()

# NOTE: C++23 doesn't go well with .clang-tidy v17 currently installed in MSVC
function ( enable_linter TARGET )
	file ( COPY_FILE
		"${CPPINIT_FOLDER}/.clang-tidy"
		"${CMAKE_CURRENT_SOURCE_DIR}/.clang-tidy"
	)

	target_sources ( ${TARGET} PRIVATE 
		"${CMAKE_CURRENT_SOURCE_DIR}/.clang-tidy"
	)

	if ( ${MSVC} )
		set_target_properties ( ${TARGET} PROPERTIES
			VS_GLOBAL_RunCodeAnalysis true
			VS_GLOBAL_EnableMicrosoftCodeAnalysis false
			VS_GLOBAL_EnableClangTidyCodeAnalysis true
		)
	else ()
		message ( "apply_compile_options: no options for non-msvc compiler" )
	endif ()
endfunction ()