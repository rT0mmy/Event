--[[
Fast and lightweight custom Luau scriptevent implementation

Made by Tommy (TommyRBLX, thenitropl)
--]]

--!strict

local format = string.format

local Events = {}
Events.__index = Events

local Connections = {}
Connections.__index = Connections

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

function Connections:Trigger(...:any)
    if self.f then
        local args = {...}
        task.spawn(function()self.f(unpack(args))end)
    else
        warn(format("[EVENT-%s]: %s has 0 active Connections.", self.Event.Name, self.Event.Name))
    end
end

function Connections:Disconnect()
    self.f = nil
    self.Event.Connections[self.Id] = nil
end

--// Event object

function Events.new(name: string):Event
    local self = {
        Name = name or (tostring(tick())),
        Connections = {}
    }

    local self = setmetatable(self :: any, {
        __index = Events,
        __tostring = function():string
            return format("[EVENT-%s]: (%i active connection(s))", self.Name, #self.Connections)
        end
    })

    return self
end

function Events:Connect(f:()->any):Connection
    local c = Connections.new(self :: Event, f)
    self.Connections[#self.Connections+1] = c

    return c
end

function Events:Fire(...:any)
    for _,v in self.Connections do v:Trigger(...) end
end

function Events:TerminateConnections()
    for _,v in self.Connections do v:Disconnect()end
    self.Connections = {}
end

return Events.new
