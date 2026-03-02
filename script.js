// Function to add a new task
function addTask() {
    const taskInput = document.getElementById('new-task');
    const taskText = taskInput.value.trim();

    if (taskText !== '') {
        const taskList = document.getElementById('task-list');
        const newTaskItem = document.createElement('li');

        // Create span for the task text
        const taskSpan = document.createElement('span');
        taskSpan.textContent = taskText;

        // Create button to delete the task
        const deleteButton = document.createElement('button');
        deleteButton.textContent = 'Delete';
        deleteButton.className = 'delete-btn';
        deleteButton.onclick = function () {
            taskList.removeChild(newTaskItem);
        };

        // Append text and button to the list item
        newTaskItem.appendChild(taskSpan);
        newTaskItem.appendChild(deleteButton);

        // Append the new task item to the list
        taskList.appendChild(newTaskItem);

        // Clear the input field
        taskInput.value = '';
    }
}
