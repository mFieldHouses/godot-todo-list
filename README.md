# godot-todo-list

I was tired of making a bunch of loose todo lists on my computer or making new Trello workspaces for projects over and over. This plugin moves the todo list into the Godot editor, allowing you to easily and quickly keep track of things you need to do.

## Installation

Installation is very easy. Just download this repo and drop the `addons` folder into your project folder root. Or, alternatively, if you already have an `addons` folder, drop the folder inside of it (`godot-todo`) into your already present `addons` folder.

## Using the plugin

### 1. Basic usage

Upon enabling it for the first time, you will be able to find the plugin window in the bottom left dock, together with File System and History. You are of course free to drop the plugin dock wherever you please.

The dock should look like this:

<img width="292" height="476" alt="image" src="https://github.com/user-attachments/assets/23766b9e-1981-4251-8e8c-7c42a1cba268" />

The `New task...` field is a LineEdit. You can select it and start typing a task. When you press enter, a new entry will be made with the text you just filled in:

<img width="288" height="476" alt="image" src="https://github.com/user-attachments/assets/0f987313-5ff8-4647-9fc4-3c313b5c060f" />

That's your first task!. You can create as many tasks as you need. You can mark the task finished by pressing on the checkbox to the left of the task text:

<img width="288" height="476" alt="image" src="https://github.com/user-attachments/assets/3a448586-132d-4660-9823-b95a9ac3b51d" />

Depending on the configuration, the task will either be removed when you close the project, save the project or when immediately when you mark the task as finished. You can read more about that under [**Configuration**](#configuration).

Dragging the handle on the outer left of an entry allows you to reorder your tasks.

### 2. Categories

To keep things organised, there is also the option to allocate a set of tasks to a specific category of tasks. Creating such a category is quite straightforward; just type something in the `New category...` field and press enter:

<img width="288" height="476" alt="image" src="https://github.com/user-attachments/assets/2fc917ca-e1c7-4159-ad49-71bdfa50c906" />

You can now drag tasks into this category using the handles on entries, or create new tasks directly inside of the category, using the `New task...` field in the same way as the main `New task...` field is.

## Configuration

The plugin sports a minimal set of configuration options, which can be found under the `Settings` button in the plugin dock.

### 1. `Discard completed tasks`
* This setting allows you to change at which moment completed tasks are removed. There are three options:
  * `When ticked off`: Discards completed tasks immediately after being marked as completed.
  * `When saving project`: Discards completed tasks when saving the project.
  * `When closing project`: Discards completed tasks when the project is closed. They will no longer appear upon reopening the project.

### 2. `New task field location`
* This setting allows you to decide where you want the `New task...` field to be located. There are two options:
  * `Bottom`: The `New task...` field will always be at the bottom of the list or a category. I have yet to find a solution for automatic scrolling when the used `New task...` field is located all the way at the bottom of the visible part of the list.
  * `Top`: The `New task...` field will always be at the top of the list or a category.

### 3. `Auto-delete empty tasks`
* This setting allows you to change whether empty tasks are immediately removed when they become empty.

## Planned features

* Per-scene todo list / support for multiple lists
