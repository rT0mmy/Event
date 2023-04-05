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

local Event = {}
Event.__index = Event
Event.__type = "Event"
--Event.__mode = "vk"

local Connection = {}
Connection.__index = Connection
Connection.__type = "Connection"
--Connection.__mode = "vk"

--// Luau Typechecking
type Primitive = number|string|boolean|{}

export type Event = typeof(setmetatable({}, {})) & {
	Connect:()->Connection,
	TerminateConnections:()->nil,
	Fire:(self:Event, ...any)->any,

	Connections:{},
	Name:string
}

export type WrappedEvent = typeof(setmetatable({}, {})) & {
	Connect:()->Connection,
	TerminateConnections:()->nil,
	Fire:(self:WrappedEvent, ...any)->nil,

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
}

--// Connection Object

function Connection.new(event:Event, f:()->any):Connection
	local self = {
		f = f::(any)->any,
		Event = event
	}

	return setmetatable(self :: any, Connection)
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
	local self = {
		Name = name,

		Connections = {},
	}

	return setmetatable(self :: any, Event)
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

			Connections = {},

			Event = EventObject,
		}

		local self = setmetatable(self :: any, Event)
		self.WrappedConnection = self.Event:Connect(function(...)
			self:Fire(...)
		end)

		return self
	end

	return error("[Event]: Could not wrap '"..tostring(EventObject).."'")
end

function Event:BindToDestroy(Object: Instance)
	if not Object then return end

	local OnDestroy = Object.Destroying:Once(function()
		if not Object then return end

		warn('Object '..Object.Name..' destroyed, terminating events')
		self:Destroy()
	end)

	self.OnDestroyBind = OnDestroy

	return self
end

Event.wrapped = Event.wrap

function Event:Connect(f:()->any):Connection
	if not f then error('[Event]: Could not connect, function cannot be false or nil') end

	local c = Connection.new(self :: Event, f)

	self.Connections[#self.Connections+1] = c
	return c
end

function Event:Fire(...)
	for _,v in self.Connections do if v.f then v.f(...) end end

	return self
end

function Event:FireOnce(...)
	for _,v in self.Connections do v.f(...) end
	self:Destroy()
end

function Event:TerminateConnections()
	for _,v in self.Connections do
		v:Disconnect()
	end

	self.Connections = {}

	return
end

function Event:Destroy()
	if self.Event then
		self.WrappedConnection:Disconnect()

		if typeof(self.Event) == 'Instance' then
			self.Event:Destroy()
		end
	end

	if self.OnDestroyBind then
		self.OnDestroyBind:Disconnect()
	end

	self:TerminateConnections()

	setmetatable(self, nil)
end

return setmetatable({},{
	__index = Event,
	__call = function(_,...)
		return Event.new(...)
	end,
})
