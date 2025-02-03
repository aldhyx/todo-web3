// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Script.sol";
import {TodoContract} from "src/TodoContract.sol";

contract TodoTest is Test {
  TodoContract todoContract;

  event UserRegistered(address indexed user);

  uint256 public constant FIRST_TODO_ID = 1;

  address public USER_REGISTERED = makeAddr("user_registered");
  address public USER_REGISTERED_2 = makeAddr("user_registered_2");
  address public USER_UNREGISTERED = makeAddr("user_unregistered");

  function setUp() public {
    vm.startBroadcast();
    todoContract = new TodoContract();
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
  function testRegisterNewUser() public withRegisteredUser {
    // perform an action
    bool isExist = todoContract.checkUserExist(USER_REGISTERED);
    // we expect that user has been registered successfully
    assertTrue(isExist);
  }

  function testRegisterNewUserEmitUserRegisteredEvent() public {
    // the next action will be performed by USER_REGISTERED
    vm.prank(USER_REGISTERED);
    // we expect the todoContract to emit an event
    vm.expectEmit(address(todoContract));

    // the event that we expect to see
    emit UserRegistered(USER_REGISTERED);
    // perform an action (will emit event above)
    todoContract.registerUser();
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

  function testGetUserByOwner() public {}

  function testGetUserByNotOwner() public {}

  function testGetAllUserByOwner() public {}

  function testGetAllUserByNotOwner() public {}

  /*//////////////////////////////////////////////////////////
                              Todo
  //////////////////////////////////////////////////////////*/
  function testCreateTodo() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");

    vm.prank(USER_REGISTERED);
    TodoContract.Todo memory todo = todoContract.getTodoById(FIRST_TODO_ID);
    assertEq(todo.id, FIRST_TODO_ID);
    assertEq(todo.isComplete, false);
  }

  function testCreateTodoWithEmptyContent() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    vm.expectRevert(TodoContract.Todo_Empty_Content_Not_Allowed.selector);

    todoContract.createTodo("");
  }

  function testCreateTodoByUnregisteredAddress() public withRegisteredUser {
    vm.prank(USER_UNREGISTERED);
    vm.expectRevert(TodoContract.Todo_Unregistered.selector);

    todoContract.createTodo("hello world");
  }

  function testCheckTodo() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");

    vm.prank(USER_REGISTERED);
    todoContract.checkTodoById(FIRST_TODO_ID);

    vm.prank(USER_REGISTERED);
    TodoContract.Todo memory todo = todoContract.getTodoById(FIRST_TODO_ID);
    assertEq(todo.isComplete, true);
  }

  function testCheckTodoByUnregisteredAddress() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");

    vm.prank(USER_UNREGISTERED);
    vm.expectRevert(TodoContract.Todo_Unregistered.selector);
    todoContract.checkTodoById(FIRST_TODO_ID);
  }

  function testCheckTodoByDifferentRegisteredAddress()
    public
    withRegisteredUser
  {
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");

    vm.prank(USER_REGISTERED_2);
    todoContract.registerUser();
    vm.prank(USER_REGISTERED_2);
    vm.expectRevert(TodoContract.Todo_Not_Exist.selector);

    todoContract.checkTodoById(FIRST_TODO_ID);
  }

  function testUnCheckTodo() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");

    vm.prank(USER_REGISTERED);
    todoContract.checkTodoById(FIRST_TODO_ID);
    vm.prank(USER_REGISTERED);
    todoContract.uncheckTodoById(FIRST_TODO_ID);

    vm.prank(USER_REGISTERED);
    TodoContract.Todo memory todo = todoContract.getTodoById(FIRST_TODO_ID);
    assertEq(todo.isComplete, false);
  }

  function testUnCheckTodoByUnregisteredAddress() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");

    vm.prank(USER_UNREGISTERED);
    vm.expectRevert(TodoContract.Todo_Unregistered.selector);
    todoContract.uncheckTodoById(FIRST_TODO_ID);
  }

  function testUnCheckTodoByDifferentRegisteredAddress()
    public
    withRegisteredUser
  {
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");

    vm.prank(USER_REGISTERED_2);
    todoContract.registerUser();
    vm.prank(USER_REGISTERED_2);
    vm.expectRevert(TodoContract.Todo_Not_Exist.selector);

    todoContract.uncheckTodoById(FIRST_TODO_ID);
  }

  function testGetTodoByUnregisteredAddress() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");
    vm.expectRevert(TodoContract.Todo_Unregistered.selector);
    vm.prank(USER_UNREGISTERED);

    todoContract.getTodoById(FIRST_TODO_ID);
  }

  function testGetTodoNotExist() public withRegisteredUser {
    vm.prank(USER_REGISTERED);
    todoContract.createTodo("hello world");

    vm.prank(USER_REGISTERED);
    vm.expectRevert(TodoContract.Todo_Not_Exist.selector);
    todoContract.getTodoById(2);
  }

  function testGetAllTodo() public {}

  function testGetAllTodoByUnregisteredAddress() public {}

  function testGetAllTodoByDifferentRegisteredAddress() public {}

  function testGetAllTodoByOwner() public {}
}
