// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
import {console} from "forge-std/Script.sol";

/**
 * What can this contract do:
 * 1. User register using their wallet address
 * 2. Only register user can create todo
 * 3. Register user can only view their own todo
 * 4. Register user can check or uncheck their own todo
 * 5. Only owner can see list of register user address
 * 6. Owner can't see or perform any action on register user todo
 */
contract TodoContract {
  error Todo_Already_Registered();
  error Todo_Unregistered();
  error Todo_Empty_Content_Not_Allowed();
  error Todo_Not_Exist();
  error Todo_Only_Owner();

  struct Todo {
    uint256 id;
    string content;
    uint256 createAt;
    bool isComplete;
  }

  address public immutable i_owner;

  mapping(address user => bool isRegistered) public registeredUsers;
  // @dev - To store a list of todo IDs for each user
  mapping(address user => uint256[] ids) private userTodoIds;
  mapping(address user => mapping(uint256 id => Todo) todo) private todoList;

  event UserRegistered(address indexed user);
  event TodoCreated(address indexed user, uint256 todoId);
  event TodoChecked(address indexed user, uint256 todoId);
  event TodoUnchecked(address indexed user, uint256 todoId);

  modifier onlyOwner() {
    if (msg.sender != i_owner) {
      revert Todo_Only_Owner();
    }
    _;
  }

  modifier onlyRegistered() {
    if (!registeredUsers[msg.sender]) {
      revert Todo_Unregistered();
    }
    _;
  }

  modifier OnlyExistTodo(uint256 _todoId) {
    if (todoList[msg.sender][_todoId].createAt == 0) {
      revert Todo_Not_Exist();
    }
    _;
  }

  constructor(address _owner) {
    i_owner = _owner;
  }

  function registerUser() external {
    if (registeredUsers[msg.sender]) {
      revert Todo_Already_Registered();
    }

    registeredUsers[msg.sender] = true;
    emit UserRegistered(msg.sender);
  }

  function createTodo(
    string calldata _content
  ) external onlyRegistered returns (Todo memory) {
    if (bytes(_content).length == 0) {
      revert Todo_Empty_Content_Not_Allowed();
    }

    uint256 newId = userTodoIds[msg.sender].length + 1;
    Todo memory newTodo = Todo({
      content: _content,
      createAt: block.timestamp,
      isComplete: false,
      id: newId
    });

    todoList[msg.sender][newId] = newTodo;
    userTodoIds[msg.sender].push(newId);
    emit TodoCreated(msg.sender, newId);

    return newTodo;
  }

  function checkTodoById(
    uint256 _todoId
  ) external onlyRegistered OnlyExistTodo(_todoId) {
    todoList[msg.sender][_todoId].isComplete = true;
    emit TodoChecked(msg.sender, _todoId);
  }

  function uncheckTodoById(
    uint256 _todoId
  ) external onlyRegistered OnlyExistTodo(_todoId) {
    todoList[msg.sender][_todoId].isComplete = false;
    emit TodoUnchecked(msg.sender, _todoId);
  }

  function getTodoById(
    uint256 _todoId
  )
    external
    view
    onlyRegistered
    OnlyExistTodo(_todoId)
    returns (Todo memory todo)
  {
    todo = todoList[msg.sender][_todoId];
  }

  function getAllTodo() external view onlyRegistered returns (Todo[] memory) {
    uint256[] memory ids = userTodoIds[msg.sender];
    Todo[] memory todos = new Todo[](ids.length);

    for (uint256 i = 0; i < ids.length; i++) {
      todos[i] = todoList[msg.sender][ids[i]];
    }

    return todos;
  }
}
