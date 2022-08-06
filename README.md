<div align="center">
	<h1>Event</h1>
	<p> Fast & Lightweight Luau scriptevent implementation. </p>
  
  ![Luau](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
  <br><br>
  Made by TommyRBLX
  
  <img src="https://img.shields.io/github/forks/rT0mmy/Event?style=for-the-badge">

  <img src="https://img.shields.io/github/stars/rT0mmy/Event?style=for-the-badge">

  <img src="https://img.shields.io/github/issues/rT0mmy/Event?style=for-the-badge">

  <img src="https://img.shields.io/github/issues-pr/rT0mmy/Event?style=for-the-badge">

  <img src="https://img.shields.io/github/license/rT0mmy/Event?style=for-the-badge">
</div>

<br><br><br><br>

> **Warning** <br>
> Event is still under development, major changes might occur.

<br><br>

> **Note** <br>
> Event is a instance of scriptevent, meaning that client - server and vice versa communication is not possible.

<br><br><br><br>

## Why Event?

Event allows easy and blazing fast setup of custom scriptevents, does not require any external dependencies. 
Straightforward and beginner friendly syntax that is suitable for everyone. 

<br><br><br><br>

## API

```lua
local Event = require(...)
```

<br><br>

```lua
Event(EventName: {}) -> EventObject
```
```lua
Event "EventName"
```

> Creates a new ```EventObject```

<br><br>

```lua
EventObject:Connect(Callback: ()) -> ConnectionObject
```
```lua
EventObject:Connect(function(...)
	print(...)
end)
```

> Creates a new ```ConnectionObject``` stored in ```EventObject.Connections```, rendering it connected to the Event.

<br><br>

```lua
ConnectionObject:Disconnect() -> nil
```
```lua
ConnectionObject:Disconnect()
```

> Disconnects ```ConnectionObject``` from Event, thus removing it from ```EventObject.Connections``` too

<br><br>

```lua
ConnectionObject:Trigger(...) -> nil
```
```lua
ConnectionObject:Trigger("Hello World!", "Luau is great!")
```

> Triggers the ```ConnectionObject``` - calling the connected callback function.

<br><br>

```lua
EventObject:Fire(...) -> nil
```
```lua
EventObject:Fire("Hello World!", "\n Luau is great!")
```

> Fires the event, triggering all ```ConnectionObject```s in ```EventObject.Connections``` and their corresponding callback functions.

<br><br>

```lua
EventObject:TerminateConnections() -> nil
```
```lua
EventObject:TerminateConnections()
```

> Terminates all Connections from ```EventObject.Connections```

<br><br>

```lua
EventObject:Terminate() -> nil
```
```lua
EventObject:Terminate()
```

> Destroys ```EventObject```, thus also destroying all ```EventConnection```s in ```EventObject.Connections```

## Demo


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


