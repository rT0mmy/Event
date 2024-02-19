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
 <img src="https://cdn.discordapp.com/attachments/1110985524786761854/1209198313392312440/image.png?ex=65e60caf&is=65d397af&hm=4e82f1ebeddc1e8f148376832a4dc4f2d7aa6daa00ff2779faa01f6c6178093f&">


<br><br><br>

## API

```lua
local Event = require(...)
```

<br><br>

> Creating a new ```EventObject```
```lua
Event() -> Event
```
```lua
local newEvent = Event()
```

<br><br>

> Creating a new ```Connection``` for the specified ```Event```

```lua
EventObject:Connect(Callback: (T...)) -> Connection
```
```lua
local newConnection = EventObject:Connect(function(a: number, b: number)
	print(a + b)
end)
```

<br><br>

> Creating a new single-use ```Connection``` for the specified ```Event```

```lua
EventObject:Once(Callback: (T...)) -> Connection
```
```lua
local newConnection = EventObject:Once(function(a: number, b: number)
	print(a + b)
end)
```

<br><br>

> Creating a new asynchronous ```Connection``` for the specified ```Event```, thus yielding the runtime code until the event is triggered.
> An optional  ```timeout``` argument defines how long the code will yield until the Wait method is terminated and therefore fails.

```lua
EventObject:Wait(timeout: number?) -> Connection
```
```lua
local success = EventObject:Wait(2)
print(success)
```

<br><br>

> Disconnects the ```Connection``` from Event

```lua
ConnectionObject()
```
```lua
newConnection()
```

<br><br>

> Fires the event, triggering all ```Connection```s (Callbacks)

```lua
EventObject:Fire(T...) -> nil
```
```lua
EventObject:Fire("Hello World!", "\n Luau is great!")
```

<br><br>

> Terminates all ```Connection```s from the ```Event```
> 
```lua
EventObject:DisconnectAll() -> nil
```
```lua
EventObject:DisconnectAll()
```

<br><br>

> Destroys ```Event```, therefore also disconnects all ```Connection```s

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

local newEvent = Event()
local newEventConnection = newEvent:Connect(function(...string)
    print(...)
end)

newEvent:Fire("Hello", "World") -- // -> Hello World

newEventConnection()
newEvent:Fire("Hello", "World 2") -- // Doesn't print "Hell World 2", because the ConnectionObject "newEventConnection" was disconnected beforehand.

```
<br>

```lua
local Event = require(...)

local EventProcessAB = Event()

function ProcessAB()
	local v = EventProcessAB:Wait(4)
	
	if v then
		print('A + B = '..v)
	else
		print('failed to deliver :(')
	end
end


```

<br>

```lua

-- Script A

local Event = require(...)

local ClientEvents = {
	onClientDead = Event(),
	onClientDamaged = Event(),
	onClientStatusChanged = Event()
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


