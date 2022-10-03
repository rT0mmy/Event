--!strict

--[[
	Event - Blazing-fast and lightweight Luau scriptevent implementation
	Learn the about Event and it's API here: https://github.com/rT0mmy/Event

	Made by Tommy (Twitter: TommyRBLX, Roblox: thenitropl, Github: rT0mmy)

	Copyright (c) 2022 TommyRBLX

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so.
--]]

local Event = {Events = {}}
Event.__index = Event
Event.__type = "Event"

local Connection = {}
Connection.__index = Connection
Connection.__type = "Connection"

--// Luau Typechecking
type Primitive = number|string|boolean|{}

export type Event = typeof(setmetatable({}, {})) & {
	Connect:()->Connection,
	TerminateConnections:()->nil,
	Fire:()->nil,

	Connections:{},
	Name:string
}

export type WrappedEvent = typeof(setmetatable({}, {})) & {
	Connect:()->Connection,
	TerminateConnections:()->nil,
	Fire:()->nil,

	Connections:{},
	Name:string,

	Event:RBXScriptSignal,
	WrappedConnection:RBXScriptConnection
}


export type Connection = typeof(setmetatable({}, {})) & {
	Trigger:()->nil,
	Disconnect:()->nil,

	f:()->any,
	Event:Event,
	Id:number
}

--// Connection Object

function Connection.new(event:Event, f:()->any):Connection
	local self = {
		f = f::(any)->any,
		Event = event
	}
	self.Id = #self.Event.Connections+1

	local self = setmetatable(self :: any, Connection)
	return self
end


function Connection:Trigger(...:any)
	local args = {...}
	task.spawn(function()self.f(unpack(args))end)
end

function Connection:Disconnect()
	self.f = nil
	self.Event = nil

	setmetatable(self, nil)
end

--// Event object

function Event.new(name: string):Event
	if Event.Events[name] then name = name..math.floor(tick()) end

	local self = {
		Name = name,
		Id = #Event.Events+1,

		Connections = {},
	}

	local self = setmetatable(self :: any, Event)
	Event.Events[self.Id] = self

	return self
end

--// Event instance wrapper and maid
function Event.wrap(EventObject:(BindableEvent|RBXScriptSignal)|string, name:string):WrappedEvent|nil
	if not EventObject or type(EventObject) == 'string' then
		EventObject = Instance.new('BindableEvent')
	end

	if typeof(EventObject) == 'Instance' and EventObject:IsA('BindableEvent') then
		EventObject = EventObject.Event
	end

	if typeof(EventObject) == "RBXScriptSignal" then
		local self = {
			Name = name,
			Id = #Event.Events+1,

			Connections = {},

			Event = EventObject,
		}

		local self = setmetatable(self :: any, Event)
		Event.Events[self.Id] = self

		self.WrappedConnection = self.Event:Connect(function(...)
			self:Fire(...)
		end)

		return self
	end

	return error("[Event]: Could not wrap '"..tostring(EventObject).."'")
end

Event.wrapped = Event.wrap

function Event:Connect(f:()->any):Connection
	if not f then error('[Event]: Could not connect, function cannot be false or nil') end
	
	local c = Connection.new(self :: Event, f)
	
	self.Connections[#self.Connections+1] = c
	return c
end

function Event:Fire(...)
	for _,v in self.Connections do v.f(...) end
end

function Event:FireOnce(...)
	for _,v in self.Connections do v.f(...) end
	self:Destroy()
end

function Event:TerminateConnections():nil
	for _,v in self.Connections do
		v:Disconnect()
	end

	self.Connections = {}

	return
end

function Event:Destroy()
	if self.Event then
		self.WrappedConnection:Disconnect()
		self.Event:Destroy()
	end

	self:TerminateConnections()
	Event.Events[self.Id] = nil

	setmetatable(self, nil)
end

--

function Event.GetEvents()
	return Event.Events
end

function Event.GetActiveEvents()
	local t = {}

	for _,v in Event.Events do
		if #v.Connections > 0 then t[v.Id] = v end
	end

	return t
end


return setmetatable({},{
	__index = Event,
	__call = Event.new
})
