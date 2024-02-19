--!strict
--!native
--!optimize 2

type Callback<T...> = (T...) -> ()
type Connection = ()->nil

export type Event<T...> = {
	Connections: {[number]: Callback<T...>},
	
	Connect: (self: Event<T...>, callback: Callback<T...>) -> Connection,
	Once: (self: Event<T...>, callback: Callback<T...>) -> Connection,

	Fire: (self: Event<T...>, T...) -> (),
	Wait: (self: Event<T...>, timeout: number?) -> T...,

	Destroy: (self: Event<T...>) -> (),
}

local Event = {}
Event.__index = Event

function Event:Connect<T...>(callback)
	local n = #self.Connections+1
	self.Connections[n] = callback
	
	return function()
		self.Connections[n] = nil
	end
end

function Event:Once<T...>(callback)
	local c
	
	c = self:Connect(function(...)
		callback(...)
		c()
	end)

	return c
end

function Event:Fire<T...>(...)
	for _, v in self.Connections do
		v(...)
	end
end

function Event:Wait<T...>(timeout)
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

function Event:Destroy<T...>()
	table.clear(self.Connections)
	setmetatable(self, nil)
end

return function<T...>(): Event<T...>
	return setmetatable({
		Connections = {}
	}, Event) :: any
end
