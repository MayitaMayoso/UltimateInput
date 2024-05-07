![Ultimate Input Logo](images/UltimateInputLogo.png)
***
***Input Manager for GameMaker:***

Bind Actions with multiple Keys, Redefine your Inputs, and Multiplayer Support.
***

***Getting Started***

You can download the latest release through the following link.

- [Get the latest release](https://github.com/MayitaMayoso/UltimateInput/releases)

You can either get the package (.yymps) and import it on your project dragging the file into the IDE or clicking at (
***Tools > Import Local Package***) or importing the whole project (.yyz) with ***Import*** on the Start Page of game
maker.

***

***Asset Overview***

Once you find yourself with a project with the Ultimate Input Asset you will see two folders: *UltimateInput by
MayitaMayoso* and *UltimateInput Using Example*.

The first folder contains the essentials to make Ultimate Input work in your project. If you know how to use the asset
this is the only elements that you need to import.

- **InputManager** (Script): Contains the InputManager struct, Macros and all the logic of UltimateInput.
- **ConfigurationOfInputs** (Script): Here is where you define the keys that you will use in your game.
- **ComponentParent** (Script): This asset is part of a bigger setup I use for my games where I have other managers such
  as CameraManager, TimeManager, GeometryManager, etc... Including this file is just for compatibility in case of
  publishing my other assets.

UltimateInput Using Example is a very basic game to show how to set up teh asset to make it work. At the day I'm writing
this readme, this just consists on a blob moving around. Use the space key to switch between a WASD movement to an
Arrows movement. Take care of the following elements.

- **System** (Object): This is your System/Controller/Game/Manager/Everything object that just uses its own events to
  call the InputManager. This Object needs to create the InputManager, call StepBegin() and call DrawGuiEnd() of the
  Input in
  order to update the status of this.
- **TestRoom** (Room): Not a lot to say about this asset. Just to make very clear that the System object has to be
  created before any other object that you might want to use the Inputs with.
- **TestObject and TestSprite** (Object, Sprite): The blob that moves around. Press space to change which keys are used
  to control it.

***

***What does it do?***

The main objective of this asset is to avoid hardcoding the keys used on your logic. Let's say your character can jump
and it can happen with either W, Space or the Up Arrow. On regular gamemaker to check if the player wants the character
to jump we should do something like:

```c
if (keyboad_check_pressed(ord("W")) || keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_space))
{
  Jump();
}
```

We want to avoid this for two reasons. First this is less maintainable, given the moment you decide you dont want to
jump anymore with space you will have to change everywhere on the code where you control if you should jump. Second the
system I propose makes it easier to implement configurable inputs in your game.

With UltimateInput the previous code would turn into just:

```c
if (Input.CheckPressed("Jump"))
{
    Jump()
}
```

Ultimate Input binds N keys into a string that is more related to what the code is doing.

![Ultimate Input Logo](images/What's%20an%20Input.png)

Apart from this, you have a series of extended ***input types***.

***

***Different Input Types***

Base gamemaker can check regular inputs, pressed inputs and released inputs. On Ultimate Input we can check the
following events for an input:

- Regular check: The check is true for every frame the key is hold down.
- Pressed: True only for the very first frame is hold.
- Released: True for the frame **after** the moment we stop holding the key.
- Double: True if we double tap the key (the time between taps is configurable).
- Repeated: While the key is down it will return true every N milliseconds. Can be used for example to move on menu
  items.
- Long: While the key is down first it will be false until N milliseconds where it will be true for the rest of the time
  that the key being held down.
- LongPressed: Like before when you press you have to wait for a bit before its true but here only for a frame.
- LongReleased: Like before you have to hold for a while before releasing. If you tap and release very fast it won't
  count.
- RepeatedLong: Again a check with some Ms of buffer before it starts behaving like Repeated.
- Value: For analog keys that can range between 0 and 1 (Gamepad sticks) this returns the value. 