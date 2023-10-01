--!strict 

local Event = {}
Event.__index = Event
Event.__mode  = "k"

export type Event = typeof(setmetatable({} :: {
	Name: string?,
	Connections: {[number]: Connection}
}, Event))

local Connection = {}
Connection.__index = Connection
Connection.__mode  = "k"

export type Connection = typeof(setmetatable({} :: {
	Callback:(() -> nil)?,
}, Connection))

Connection.new = function(f:()->nil): Connection
	return setmetatable({
		Callback = f, 
	}, Connection)
end

function Connection:Disconnect()
	self.Callback = nil
	setmetatable(self, nil)
end

Event.new = function(name: string): Event
	local self = setmetatable({
		Name = tostring(name),
		Connections = {},
	}, Event)

	return self :: Event
end

function Event.BindTo(self: Event, signal: RBXScriptSignal, cleanupInstance: Instance)
	local signalConnection = signal:Connect(function(...)
		self:Fire(...)
	end)

	if cleanupInstance then
		self.CleanupConnection = cleanupInstance.Destroying:Once(function()
			signalConnection:Disconnect()
		end)
	end

	self.RBXScriptConnection = signalConnection

	return signalConnection
end

function Event.Connect(self: Event, f:()->nil): Connection
	local newConnection = Connection.new(f)
	table.insert(self.Connections, newConnection)

	return newConnection
end

function Event.Once(self: Event, f:()->nil): Connection

	local newConnection
	newConnection = self:Connect(function(...)
		f(...)
		newConnection:Disconnect()
	end)

	return newConnection
end

function Event.Wait(self: Event, t: number?)
	local yield = coroutine.running()

	local function resumeCoroutine(...)
		task.spawn(yield, ...)
	end

	local connection = Event.Once(self, resumeCoroutine)

	if t then
		task.delay(t, function()
			resumeCoroutine()

			if connection then
				connection:Disconnect()
			end
		end)
	end

	return coroutine.yield()
end

function Event.Fire(self: Event, ...: any)
	for _,v in (self.Connections)::{Connection} do 
		if v.Callback then 
			v.Callback(...) 
		end
	end
end

function Event.DisconnectAll(self: Event)
	for _,v in (self.Connections)::{Connection} do 
		v:Disconnect()
	end
end

function Event.Destroy(self: Event)
	if self.RBXScriptConnection then
		self.RBXScriptConnection:Disconnect()
	end

	if self.CleanupConnection then
		self.CleanupConnection:Disconnect()
	end

	self:DisconnectAll()

	table.clear(self.Connections)
	setmetatable(self, nil)
end

return Event.new
