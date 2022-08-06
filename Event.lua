--!strict

--[[
	Event - Blazing-fast and lightweight Luau scriptevent implementation
	Learn the about Event and it's API here: https://github.com/rT0mmy/Event

	Made by Tommy (Twitter: TommyRBLX, Roblox: thenitropl, Github: rT0mmy)
--]]

local Events = {Events = {}}
Events.__index = Events
Events.__class = "Event"

local Connections = {}
Connections.__index = Connections
Connections.__class = "Connection"


local format = string.format

--// Luau Typechecking

type Primitive = number|string|boolean|{}

export type Event = typeof(setmetatable({}, {})) & {
    Connect:()->Connection,
    TerminateConnections:()->nil,
    Fire:()->nil,

    Connections:{},
    Name:string
}


export type Connection = typeof(setmetatable({}, {})) & {
    Trigger:()->nil,
    Disconnect:()->nil,

    f:()->any,
    Event:Event,
    Id:number
}

--// Connection Object

function Connections.new(event:Event, f:()->any):Connection
    local self = {
        f = f::(any)->any,
        Event = event
    }
    self.Id = #self.Event.Connections+1

    local self = setmetatable(self :: any, Connections)

    return self
end

function Connections:Trigger(...:any):nil
    local args = {...}
    task.spawn(function()self.f(unpack(args))end)

    return
end

function Connections:Disconnect()
    self.f = nil
	self.Event = nil

	setmetatable(self, nil)
end

--// Event object

function Events.new(name: string):Event|nil
	if Events.Events[name] then return warn(format('[EVENT:] Event with name %q already exists.', name)) end

    local self = {
        Name = name or tostring(#Events.Events),
		Connections = {},
    }

	local self = setmetatable(self :: any, Events)
	Events.Events[self.Name] = self

    return self
end

function Events:Connect(f:()->any):Connection
    self.Connections[#self.Connections+1] = Connections.new(self :: Event, f)

    return self.Connections[#self.Connections+1]
end

function Events:Fire(...)
	for _,v in self.Connections do v.f(...) end
end

function Events:TerminateConnections():nil
    for _,v in self.Connections do
        v:Disconnect()
    end

    self.Connections = {}

    return
end

function Events:Terminate()
	self:TerminateConnections()
	Events.Events[self.Name] = nil

	setmetatable(self, nil)
end

return setmetatable({},{
	__call = function(_,s)
		return Events.new(s)
	end,

	__index = function(_,k)
		if type(rawget(Events,k)) == 'function' then return end
		return Events[k]
	end,
})
