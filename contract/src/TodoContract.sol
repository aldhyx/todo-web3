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

  struct Todo {
    uint256 id;
    string content;
    uint256 createAt;
    bool isComplete;
  }

  mapping(address user => bool) private registeredUsers;
  mapping(address user => uint256 count) private todoCount;
  mapping(address user => mapping(uint256 id => Todo) todo) private todoList;

  event UserRegistered(address indexed user);
  event TodoCreated(address indexed user, uint256 todoId);

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

  function registerUser() external {
    if (registeredUsers[msg.sender]) {
      revert Todo_Already_Registered();
    }

    registeredUsers[msg.sender] = true;
    emit UserRegistered(msg.sender);
  }

  function createTodo(string calldata _content) external onlyRegistered {
    if (bytes(_content).length == 0) {
      revert Todo_Empty_Content_Not_Allowed();
    }

    uint256 newId = todoCount[msg.sender] + 1;
    Todo memory newTodo = Todo({
      content: _content,
      createAt: block.timestamp,
      isComplete: false,
      id: newId
    });

    todoList[msg.sender][newId] = newTodo;
    todoCount[msg.sender]++;
  }

  function checkTodoById(
    uint256 _todoId
  ) external onlyRegistered OnlyExistTodo(_todoId) {
    todoList[msg.sender][_todoId].isComplete = true;
  }

  function checkUserExist(address _user) external view returns (bool) {
    return registeredUsers[_user];
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
}
