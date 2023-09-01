--!strict 

local Event = {}
Event.__index = Event
Event.__class = "Event"
Event.__mode  = "k"

export type Event = typeof(setmetatable({} :: {
	Name: string?,
	RBXScriptSignal: RBXScriptConnection?,
	CleanupConnection: RBXScriptConnection?,
	Connections: {[number]: Connection}	
}, Event))

local Connection = {}
Connection.__index = Connection
Connection.__mode  = "k"

export type Connection = typeof(setmetatable({} :: {
	Callback:(() -> nil)?,
}, Connection))

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

Connection.new = function(f:()->nil): Connection
	return setmetatable({
		Callback = f, 
	}, Connection)
end

function Connection:Disconnect()
	self.Callback = nil
	setmetatable(self, nil)
end

Event.new = function(name: string?): Event
	local self = setmetatable({
		Name = name and tostring(name) or 'Untitled',
		Connections = {},
	}, Event)
	
	return self :: Event
end

function Event:BindTo(signal: RBXScriptSignal, cleanupInstance: Instance)
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

function Event:Connect(f:()->nil): Connection
	local newConnection = Connection.new(f)
	table.insert(self.Connections, newConnection)
	
	return newConnection
end

function Event:Once(f:()->nil): Connection
	
	local newConnection
	newConnection = self:Connect(function(...)
		f(...)
		newConnection:Disconnect()
	end)

	return newConnection
end

function Event:Wait()
	local yield = coroutine.running()

	self:Once(function(...)
		task.spawn(yield, ...)
	end)

	return coroutine.yield()
end

function Event:Fire(...: any)
	for _,v in (self.Connections)::{Connection} do 
		if v.Callback then 
			v.Callback(...) 
		end
	end
end

function Event:DisconnectAll()
	for _,v in (self.Connections)::{Connection} do 
		v:Disconnect()
	end
end

function Event:Destroy()
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

return Event
