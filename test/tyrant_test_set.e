note
	description: "[
		Eiffel tests that can be executed by testing tool.
		Tyrant API
		put
		get
		remove
		vanish
		iterator
		size
		
		socket
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TYRANT_TEST_SET

inherit
	EQA_TEST_SET
		redefine
			on_prepare,
			on_clean
		end

feature -- Set Up

	on_prepare
		do
			create l_tyrant.make
		end

	on_clean
		do
			l_tyrant.wipe_out
			l_tyrant.close
		end
feature -- Test routines

	retrieve_what_was_put
		local
			l_value : STRING
		do
			l_tyrant.put ("key3","value3")
			l_value := l_tyrant.get ("key3")
			assert ("Equals", l_value ~ "value3")
		end


	key_does_not_exist
		local
			l_value : STRING
		do
			l_value := l_tyrant.get ("key10")
			assert ("NULL", l_value = Void)
		end

	vanish_remove_all
		do
			l_tyrant.put ("key3","value3")
			l_tyrant.wipe_out
			assert ("NULL", l_tyrant.get ("key3") = Void)
		end


	remove_key
		do
			l_tyrant.put ("key3","value3")
			l_tyrant.remove ("key3")
			assert ("NULL", l_tyrant.get ("key3") = Void)
		end

	remove_key_does_not_exist
		do
			l_tyrant.remove ("key10")
			assert ("Has error true", l_tyrant.has_error)
		end

	empty_tyrant_size_is_zero
		do
			l_tyrant.wipe_out
			assert ("Expected 0", 0 = l_tyrant.size )
		end

	tyrant_size_is_three
		do
			l_tyrant.put ("key7","value2")
			l_tyrant.put ("key4","value8")
			l_tyrant.put ("key9","value3")
			assert ("Expected 3", 3 = l_tyrant.size)
		end

	iterate_empty_tyrant
		do
			l_tyrant.reset
			assert("Expected NULL", l_tyrant.next_key = Void)
		end


	iterate_one_element_tyrant
		do
			l_tyrant.put ("key7","value2")
			l_tyrant.reset
			assert("Expected key7", l_tyrant.next_key ~ "key7")
		end

feature -- Implementation

	l_tyrant : TYRANT_API

end


