// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Script.sol";
import {TodoContract} from "src/TodoContract.sol";

contract TodoTest is Test {
  TodoContract todoContract;

  event UserRegistered(address indexed user);
  event TodoCreated(address indexed user, uint256 todoId);
  event TodoChecked(address indexed user, uint256 todoId);
  event TodoUnchecked(address indexed user, uint256 todoId);

  uint256 public constant FIRST_TODO_ID = 1;
  uint256 public constant SECOND_TODO_ID = 2;

  address public USER_REGISTERED = makeAddr("user_registered");
  address public USER_REGISTERED_2 = makeAddr("user_registered_2");
  address public USER_UNREGISTERED = makeAddr("user_unregistered");

  function setUp() public {
    vm.startBroadcast();
    todoContract = new TodoContract(msg.sender);
    vm.stopBroadcast();
  }

  modifier withRegisteredUser() {
    // the next action will be performed by USER_REGISTERED
    vm.prank(USER_REGISTERED);
    // perform an action
    todoContract.registerUser();
    _;
  }

  /*//////////////////////////////////////////////////////////
                          Register User
  //////////////////////////////////////////////////////////*/
  function testRegisterNewUser() public {
    // the next action will be performed by USER_REGISTERED
    vm.prank(USER_REGISTERED);
    // we expect the todoContract to emit an event
    vm.expectEmit(address(todoContract));
    // the event that we expect to see
    emit UserRegistered(USER_REGISTERED);

    // perform an action
    todoContract.registerUser();
    // perform an action
    bool isExist = todoContract.registeredUsers(USER_REGISTERED);
    // we expect that user has been registered successfully
    assertTrue(isExist);
  }

  function testRegisterNewUserWhenAlreadyRegistered()
    public
    withRegisteredUser
  {
    // the next action will be performed by USER_REGISTERED
    vm.prank(USER_REGISTERED);
    // we expect to see an error revert when perform next action
    vm.expectRevert(TodoContract.Todo_Already_Registered.selector);
    // perform action
    todoContract.registerUser();
  }

  /*//////////////////////////////////////////////////////////
                              Todo
  //////////////////////////////////////////////////////////*/
  function testCreateTodo() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    vm.expectEmit(address(todoContract));
    emit TodoCreated(USER_REGISTERED, FIRST_TODO_ID);

    TodoContract.Todo memory todo = todoContract.createTodo("hello world");

    assertEq(todo.id, FIRST_TODO_ID);
    assertEq(todo.isComplete, false);
  }

  function testCreateTodoWithEmptyContent() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    vm.expectRevert(TodoContract.Todo_Empty_Content_Not_Allowed.selector);

    todoContract.createTodo("");
  }

  function testCreateTodoByUnregisteredAddress() public {
    vm.prank(USER_UNREGISTERED);
    vm.expectRevert(TodoContract.Todo_Unregistered.selector);

    todoContract.createTodo("hello world");
  }

  function testCheckTodo() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");

    // On the next action, we expect to see TodoChecked event emitted
    vm.expectEmit(address(todoContract));
    emit TodoChecked(USER_REGISTERED, FIRST_TODO_ID);

    vm.prank(USER_REGISTERED);
    // perform action that will check todo & emit TodoChecked event
    todoContract.checkTodoById(FIRST_TODO_ID);

    vm.prank(USER_REGISTERED);
    TodoContract.Todo memory todo = todoContract.getTodoById(FIRST_TODO_ID);

    assertEq(todo.isComplete, true);
    assertEq(todo.id, FIRST_TODO_ID);
  }

  function testCheckTodoByUnregisteredAddress() public {
    vm.prank(USER_UNREGISTERED);
    vm.expectRevert(TodoContract.Todo_Unregistered.selector);
    todoContract.checkTodoById(FIRST_TODO_ID);
  }

  function testUnCheckTodo() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");

    // We expect to see TodoUncheck event emitted on next action call
    vm.expectEmit(address(todoContract));
    emit TodoUnchecked(USER_REGISTERED, FIRST_TODO_ID);

    vm.prank(USER_REGISTERED);
    todoContract.uncheckTodoById(FIRST_TODO_ID);

    vm.prank(USER_REGISTERED);
    TodoContract.Todo memory todo = todoContract.getTodoById(FIRST_TODO_ID);

    // We also expect to see is complete false
    assertEq(todo.isComplete, false);
    assertEq(todo.id, FIRST_TODO_ID);
  }

  function testUnCheckTodoByUnregisteredAddress() public {
    vm.prank(USER_UNREGISTERED);
    vm.expectRevert(TodoContract.Todo_Unregistered.selector);
    todoContract.uncheckTodoById(FIRST_TODO_ID);
  }

  function testGetTodoByUnregisteredAddress() public {
    vm.expectRevert(TodoContract.Todo_Unregistered.selector);
    vm.prank(USER_UNREGISTERED);

    todoContract.getTodoById(FIRST_TODO_ID);
  }

  function testGetTodoNotExist() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    vm.expectRevert(TodoContract.Todo_Not_Exist.selector);
    todoContract.getTodoById(FIRST_TODO_ID);
  }

  function testGetAllTodo() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");

    vm.prank(USER_REGISTERED);
    TodoContract.Todo[] memory todos = todoContract.getAllTodo();

    assertEq(todos.length, 2);
    assertEq(todos[0].id, FIRST_TODO_ID);
    assertEq(todos[1].id, SECOND_TODO_ID);
  }

  function testGetAllTodoByUnregisteredAddress() public {
    vm.expectRevert(TodoContract.Todo_Unregistered.selector);
    vm.prank(USER_UNREGISTERED);
    todoContract.getAllTodo();
  }
}
