--!strict
--!native
--!optimize 2

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
export type Connection = ()->nil

export type Event<T...> = {
	Connections: {[number]: Callback<T...>},
	
	Connect: (self: Event<T...>, callback: Callback<T...>) -> Connection,
	Once: (self: Event<T...>, callback: Callback<T...>) -> Connection,

	Fire: (self: Event<T...>, T...) -> (),
	Wait: (self: Event<T...>, timeout: number?) -> ...any,

	Destroy: (self: Event<T...>) -> (),
}

local Event = {}

--[=[
    Creates a new Event<T...>
    
    @return Event<T...>
]=]
function Event.new<T...>(): Event<T...>
	return {
		Connections = {},

		Destroy = Event.Destroy,
		Connect = Event.Connect,

		Once = Event.Once,
		Fire = Event.Fire,
		Wait = Event.Wait
	}
end

--[=[
    Creates a new Connection for the Event<T...>

    @param callback (T...) -> nil
    @return Connection
]=]
function Event.Connect<T...>(self: Event<T...>, callback: Callback<T...>): Connection
	local n = #self.Connections+1
	self.Connections[n] = callback
	
	return function()
		self.Connections[n] = nil
	end
end

--[=[
    Creates a new single-use Connection for the specified Event<T...>

    @param callback (T...) -> nil
    @return Connection
]=]
function Event.Once<T...>(self: Event<T...>, callback: Callback<T...>): Connection
	local c
	
	c = self:Connect(function(...)
		callback(...)
		c()
	end)

	return c
end

--[=[
    Fires the event, triggering all Connections (callbacks)

    @param (...) T...
    @return nil
]=]
function Event.Fire<T...>(self: Event<T...>, ...:T...): nil
	for _, v in self.Connections do
		v(...)
	end
	
	return
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

	local connection = Event.Once(self, resumeCoroutine)

	if timeout then
		task.delay(timeout, function()
			resumeCoroutine()

			if connection then
				connection()
			end
		end)
	end

	return coroutine.yield()
end

--[=[
   Destroys Event, therefore clears all Connections

    @return nil
]=]
function Event.Destroy<T...>(self: Event<T...>): nil
	return table.clear(self.Connections)
end

return Event.new
