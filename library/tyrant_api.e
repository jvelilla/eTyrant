note
	description: "[
		{TYRANT_API} is network interface to the DBM called Tokyo Cabinet
		This API implements the Binary Protocol
			put
			get
			remove
			vanish (wipe_out)
			iterator (reset, next_key)
			size (number of records)
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TYRANT_API

create
	make, make_client_by_port


feature -- Initialization
	make
		-- Create a new instance in the defaul port a host
		do
			create socket.make_client_by_port (1978, "localhost")
			open
		ensure
			socket_created : socket /= Void
			is_connected   : is_open
			correct  : not has_error
		end

	make_client_by_port ( a_port : INTEGER; a_host : STRING)
		-- Create a new client in `a_port' and `a_host'
		do
			create socket.make_client_by_port (a_port, a_host)
			open
		ensure
			socket_created : socket /= Void
			is_connected   : is_open
			correct  : not has_error
		end

feature {NONE}-- Socket Handler
	open
		-- Open the connection
		require
			not_connected : not is_open
		do
			socket.connect
			check
				socket.is_connected
			end
		ensure
			is_connected : is_open
		end

	set_operation ( an_operation : INTEGER_8)
		require
			is_connected : is_open
		do
			socket.put_integer_8 (Operation_prefix)
			socket.put_integer_8 (an_operation)
		end

feature -- Close Connection
	close
		-- Close the connection
		require
			connected : is_open
		do
			socket.close
			check
				socket.is_closed
			end
		ensure
			not_connected : is_closed
		end

feature -- Status Report
	is_open : BOOLEAN
		-- Is the connection open?
		do
			Result := socket.is_connected
		end

	is_closed : BOOLEAN
		-- Is the connection closed?
		do
			Result := socket.is_closed
		end

	has_error : BOOLEAN
			-- Did an error occurr?

	error_description: STRING
		-- Textual description of error
		require
			has_error: has_error
		do
			Result := error_message
		ensure
			result_exists: Result /= Void
			result_not_empty: not Result.is_empty
		end

feature {NONE} -- Constants

	Operation_prefix : INTEGER_8 = 0xC8
	Put_operation : INTEGER_8 = 0x10
	Get_operation : INTEGER_8 = 0x30
	Vanish_operation : INTEGER_8 = 0x72
	Remove_operation : INTEGER_8 = 0x20
	Size_operation : INTEGER_8 = 0x80
	Iterator_Initialize_operation : INTEGER_8 = 0x50
	Iterator_Next_Key_operation : INTEGER_8 = 0x51


	socket : NETWORK_STREAM_SOCKET

	error_message : STRING
		-- error message

feature -- Status Change
	clean_error
		-- Reset the last error.
		do
			has_error := False
		ensure
			no_error: not has_error
		end

feature -- Tyrant Operations

	put ( a_key : STRING; a_value : STRING)
		-- Store a new record, If a record with the same `a_key' exists, it is overwritten.
		require
			valid_key : a_key /= Void
			valid_value : a_value /= Void
			is_connected : is_open
		do

			set_operation (Put_operation)
			socket.put_integer_32 (a_key.count)
			socket.put_integer_32 (a_value.count)
			socket.put_string (a_key)
			socket.put_string (a_value)
			socket.read_integer_8
			if 0 /= socket.last_integer_8 then
				has_error := True
				error_message := "Error trying to add a record qwith key: [" + a_key +" and value:" +a_value+"]"
			end

		ensure
			connected:  is_open
		end


	size : INTEGER_64
		-- Return number of records
		require
			is_connected : is_open
		do

			set_operation (Size_operation)
			socket.read_integer_8
			if 0 /= socket.last_integer_8 then
				has_error := True
				error_message := "Error trying to get the size]"
			else
				socket.read_integer_64
				Result := socket.last_integer_64
			end
		ensure
			connected : is_open
		end


	get ( a_key : STRING) : STRING
		-- Get the value associated with `a_key', if present.
		require
			valid_key : a_key /= Void
			is_connected : is_open
		do
			set_operation (Get_operation)
			socket.put_integer_32 (a_key.count)
			socket.put_string (a_key)
			socket.read_integer_8
			if 0 = socket.last_integer_8 then
				socket.read_integer_32
				socket.read_stream (socket.last_integer)
				Result := socket.last_string
			else
				has_error := True
				error_message := "Error trying to get the key: [" + a_key + "]"
			end
		ensure
			connected : is_open
		end


	remove ( a_key : STRING)
		-- Remove record associated with `a_key', if present.
		require
			valid_key : a_key /= Void
			is_connected : is_open
		do
			set_operation (Remove_operation)
			socket.put_integer_32 (a_key.count)
			socket.put_string (a_key)
			socket.read_integer_8
			if 0 /= socket.last_integer_8 then
				has_error := True
				error_message := "Error trying to remove the key: [" + a_key + "]"
			end
		ensure
			connected : is_open
			-- size is old size - 1
		end

	wipe_out
		-- remove all records
		require
			is_connected : is_open
		do
			set_operation (Vanish_operation)
			socket.read_integer_8
			if 0 /= socket.last_integer_8 then
				has_error := True
				error_message := "Error trying to remove all records"
			end
		ensure
			 -- is_empty : size = 0
		end

feature -- Tyrant Invariant

	reset
		-- Initialize the iterator
		require
			is_connected : is_open
		do
			set_operation (Iterator_Initialize_operation)
			socket.read_integer_8
			if 0 /= socket.last_integer_8 then
				has_error := True
				error_message := "Error trying to reset the iterator"
			end
		ensure
			 --
		end

	next_key : STRING
		-- Return value of the next key, NULL, when no record is to be get out of the iterator.
		require
			is_connected : is_open
		do
			set_operation (Iterator_Next_Key_operation)
			socket.read_integer_8
			if 0 = socket.last_integer_8 then
				socket.read_integer_32
				socket.read_stream (socket.last_integer)
				Result := socket.last_string
			else
				has_error := True
				error_message := "Error trying to get the next key"
			end
		ensure
			connected : is_open
		end

invariant
	socket_valid : socket /= Void
	valid_socket_state   : (is_open or else is_closed )
	non_empty_description: has_error implies (error_description /= Void and (not error_description.is_empty))
end
