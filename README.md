<div align="center">
	<h1 style="color:blue;text-align:center">Event</h1>
	<p> Fast & Lightweight Luau scriptevent </p>
  
  ![Luau](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
  <br><br>
  
  <img src="https://img.shields.io/github/forks/rT0mmy/Event?style=for-the-badge">

  <img src="https://img.shields.io/github/stars/rT0mmy/Event?style=for-the-badge">

  <img src="https://img.shields.io/github/issues/rT0mmy/Event?style=for-the-badge">

  <img src="https://img.shields.io/github/issues-pr/rT0mmy/Event?style=for-the-badge">

  <img src="https://img.shields.io/github/license/rT0mmy/Event?style=for-the-badge">
</div>

<br><br><br><br>

> **Warning** <br>
> Event is under development

<br><br>

## Why Event?
Event is an API meticulously crafted to simplify event management, making your code more readable, maintainable, and responsive;
It's lightweight and straightforward structure makes it extremly easy to implement into your workflow.

Event offers intuitive and clean API structure, designed to minimize complexity while maximizing functionality.

_Empower your projects with the blazing fast **Event**_

<br><br><br>

## API

```lua
local Event = require(...)
```

<br><br>

> Creating a new ```EventObject```
```lua
Event(EventName: string?) -> EventObject
```
```lua
local newEvent = Event "EventName"
```

<br><br>

> Creates a new ```Connection``` for the specified ```EventObject```

```lua
EventObject:Connect(Callback: ()) -> Connection
```
```lua
local newConnection = EventObject:Connect(function(...)
	print(...)
end)
```

<br><br>

> Creates a new single-use ```Connection``` for the specified ```EventObject```

```lua
EventObject:Once(Callback: ()) -> Connection
```
```lua
local newConnection = EventObject:Once(function(...)
	print(...)
end)

print(newConnection) --> nil
```

<br><br>

> Creates a new asynchronous ```Connection``` for the specified ```EventObject```, thus yielding the runtime code until the event is triggered.
> An optional argument ```t``` defines how long the code will yield until the Wait method is terminated and fails.

```lua
EventObject:Wait(t: number?) -> Connection
```
```lua
local success, result = EventObject:Wait(2)

print(success, result)
```

<br><br>

> Disconnects and collects the ```Connection``` from Event

```lua
ConnectionObject:Disconnect() -> nil
```
```lua
newConnection:Disconnect()
```

<br><br>

> Fires the event, triggering all ```Connection```s (Callbacks)

```lua
EventObject:Fire(...) -> nil
```
```lua
EventObject:Fire("Hello World!", "\n Luau is great!")
```

<br><br>

> Terminates all ```Connection```s from the ```EventObject```
> 
```lua
EventObject:DisconnectAll() -> nil
```
```lua
EventObject:DisconnectAll()
```

<br><br>

> Destroys ```EventObject```, thus also destroying and collecting all ```Connection```s

```lua
EventObject:Destroy() -> nil
```
```lua
EventObject:Destroy()
```

<br><br><br>

## API Sample Demo


```lua
local Event = require(...)

local newEvent = Event "newEvent"
local newEventConnection = newEvent:Connect(function(...)
    print(...)
end)

newEvent:Fire("Hello", "World") -- // -> Hello World

newEventConnection:Disconnect()
newEvent:Fire("Hello", "World 2") -- // Doesn't print "Hell World 2", because the ConnectionObject "newEventConnection" was disconnected beforehand.

```
<br>

```lua
local Event = require(...)

local EventProcessAB = Event "ProcessAB"

function ProcessAB()
	local success, result = EventProcessAB:Wait(4)
	
	if success then
		print('A + B = '..result)
	else
		print('Server failed to deliver :(')
	end
end


```

<br>

```lua

-- Script A

local Event = require(...)

local ClientEvents = {
	onClientDead = Event 'onClientDeath',
	onClientDamaged = Event 'onClientDamaged',
	onClientStatusChanged = Event 'onClientStatusChanged'
}

return ClientEvents

-- Script B

local ClientEvents = require(ScriptA...)

local function TakeDamage(n)
	...
	ClientEvents.onClientDamaged:Fire(n)
	if Client.Health <= 0 then
		ClientEvents.onClientDead:Fire()
	end
	...
end

```


