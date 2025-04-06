--!native
--!strict

--[=[
    A simple API for blazing fast scriptevents

    @examples - Can be found on the github repo, in examples section
    https://github.com/rT0mmy/Event

    @class Event<T...>

	@prop Connections {(T...) -> ()}
	
	@method :Connect (callback: (T...) -> ()) -> nil
	@method :Once (callback: (T...) -> ()) -> nil
	@method :Fire (T...) -> nil
	@method :Wait (timeout: number) -> ...any
	@method :Destroy () -> nil
]=]


type Callback<T...> = (T...) -> ()

export type Connection<T...> = {
	Disconnect: (self: Connection<T...>) -> nil,
	Callback: Callback<T...>
}

export type Event<T...> = {
	Connections: {Connection<T...>},
	
	Connect: (self: Event<T...>, callback: Callback<T...>) -> Connection<T...>,
	
	Once: (self: Event<T...>, callback: Callback<T...>) -> Connection<T...>,
	Wait: (self: Event<T...>, timeout: number?) -> ...any,
	Fire: (self: Event<T...>, T...) -> ...any,
	
	Destroy: (self: Event<T...>) -> nil
}

local Event = {}

--[=[
    Creates a new Event<T...>
    
    @return Event<T...>
]=]
function Event.new<T...>(): Event<T...>
	return {
		Connections = {},
		
		Connect = Event.Connect,
		Destroy = Event.Destroy,
		
		Once = Event.Once,
		Wait = Event.Wait,
		Fire = Event.Fire,
	}
end

--[=[
    Creates a new Connection for the Event<T...>

    @param callback (T...) -> nil
    @return Connection
]=]
function Event.Connect<T...>(self: Event<T...>, callback: Callback<T...>): Connection<T...>
	local n = #self.Connections + 1
	
	local Connection: Connection<T...> = {
		Disconnect = function()
			table.remove(self.Connections, n)
			return nil
		end,
		
		Callback = callback
	}
	
	table.insert(self.Connections, Connection)
	
	return Connection
end

--[=[
    Creates a new single-use Connection for the specified Event<T...>

    @param callback (T...) -> nil
    @return Connection
]=]
function Event.Once<T...>(self: Event<T...>, callback: Callback<T...>): Connection<T...>
	local Connection

	Connection = self:Connect(function(...)
		callback(...)

		if Connection then
			Connection:Disconnect()
		end
	end)

	return Connection
end

--[=[
   Creates a new asynchronous Connection for the specified Event, 
   thus yielding the runtime code until the event is triggered. 
   An optional timeout argument defines how long the code will yield (in seconds) 
   until the Wait method is terminated and therefore fails.

    @param timeout number
    @return ... any
]=]
function Event.Wait<T...>(self: Event<T...>, timeout: number?): ...any
	local yield = coroutine.running()

	local function resumeCoroutine(...)
		task.spawn(yield, ...)
	end

	local Connection = self:Once(resumeCoroutine)

	if timeout then
		task.delay(timeout, function()
			resumeCoroutine()

			if Connection then
				Connection:Disconnect()
			end
		end)
	end

	return coroutine.yield()
end

--[=[
    Fires the event, triggering all Connections (callbacks)

    @param (...) T...
    @return nil
]=]
function Event.Fire<T...>(self: Event<T...>, ...:T...): ...any
	for _, connection in self.Connections do
		connection.Callback(...)
	end
end

--[=[
   Destroys Event, therefore clears all Connections

    @return nil
]=]
function Event.Destroy<T...>(self: Event<T...>)
	for _, connection in self.Connections do
		connection:Disconnect()
	end
	
	return nil
end

return Event.new
