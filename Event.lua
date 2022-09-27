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

local Events = {Events = {}}
Events.__index = Events
Events.__type = "Event"

local Connections = {}
Connections.__index = Connections
Connections.__type = "Connection"


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

function Connections:Trigger(...:any)
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

function Events.new(name: string):Event
	local self = {
		Name = name,
		Id = #Events.Events+1,

		Connections = {},
	}

	local self = setmetatable(self :: any, Events)
	Events.Events[self.Id] = self

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
	Events.Events[self.Id] = nil

	setmetatable(self, nil)
end

function Events:GetEvents()
	return Events.Events
end

function Events:GetActiveEvents()
	local t = {}

	for _,v in Events.Events do
		if #v.Connections > 0 then t[v.Id] = v end
	end

	return t
end


return setmetatable({},{
	__call = function(_,s)
		return Events.new(s)
	end,

	__index = function(_,k)
		if type(rawget(Events,k)) == 'function' and (k~='GetEvents' and k~='GetActiveEvents') then return end
		return Events[k]
	end,
})
