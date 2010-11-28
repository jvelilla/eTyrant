note
	description : "test_suite application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION


create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		do
			retrieve_what_was_put
		end


	retrieve_what_was_put
		local
			l_tyrant : TYRANT_API

		do
			create l_tyrant.make
			l_tyrant.put ("key3","value3")
			check
				l_tyrant.get ("key3") ~ "value3"
			end
			print (l_tyrant.get ("key3"))
			l_tyrant.close
		end

end
