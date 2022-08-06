--[[
Fast and lightweight custom Luau scriptevent implementation

Made by TommyLuau (TommyRBLX)
--]]

--!strict

local Events = {Events = {}}
Events.__index = Events

local Connections = {}
Connections.__index = Connections

local format = string.format

--// Luau Typechecking

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
        f = f::()->any,
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

function Connections:Disconnect():nil
    self.f = nil

    return
end

--// Event object

function Events.new(name: string):Event|nil
	if Events.Events[name] then return warn(format('[EVENT:] Event with name %q already exists.', name)) end

    local self = {
        Name = name or (tonumber(tick())),
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
end

Events.__call = Events.new

return setmetatable(Events,Events)
