// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Script.sol";
import {TodoContract} from "src/TodoContract.sol";

contract TodoTest is Test {
  TodoContract todoContract;

  event UserRegistered(address indexed user);

  uint256 public constant FIRST_TODO_ID = 1;

  address public USER_A = makeAddr("user_a");
  address public USER_B = makeAddr("user_b");

  function setUp() public {
    vm.startBroadcast();
    todoContract = new TodoContract();
    vm.stopBroadcast();
  }

  /*//////////////////////////////////////////////////////////
                          Register User
  //////////////////////////////////////////////////////////*/
  function testRegisterNewUser() public {
    // the next action will be performed by USER_A
    vm.prank(USER_A);
    // perform an action
    todoContract.registerUser();

    // perform an action
    bool isExist = todoContract.checkUserExist(USER_A);
    // we expect that user has been registered successfully
    assertTrue(isExist);
  }

  function testRegisterNewUserEmitUserRegisteredEvent() public {
    // the next action will be performed by USER_A
    vm.prank(USER_A);
    // we expect the todoContract to emit an event
    vm.expectEmit(address(todoContract));

    // the event that we expect to see
    emit UserRegistered(USER_A);
    // perform an action (will emit event above)
    todoContract.registerUser();
  }

  function testRegisterNewUserWhenAlreadyRegistered() public {
    // the next action will be performed by USER_A
    vm.prank(USER_A);
    // perform an action
    todoContract.registerUser();

    // the next action will be performed by USER_A
    vm.prank(USER_A);
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
  function testCreateTodo() public {
    vm.prank(USER_A);
    todoContract.createTodo("hello world");

    vm.prank(USER_A);
    TodoContract.Todo memory todo = todoContract.getTodoById(FIRST_TODO_ID);
    assertEq(todo.id, FIRST_TODO_ID);
  }

  function testCreateTodoWithEmptyContent() public {
    vm.prank(USER_A);
    vm.expectRevert(TodoContract.Todo_Empty_Content_Not_Allowed.selector);

    todoContract.createTodo("");
  }

  function testCreateTodoByUnregisteredAddress() public {}

  function testCheckTodo() public {}

  function testCheckTodoByUnregisteredAddress() public {}

  function testCheckTodoByDifferentRegisteredAddress() public {}

  function testUnCheckTodo() public {}

  function testUnCheckTodoByUnregisteredAddress() public {}

  function testUnCheckTodoByDifferentRegisteredAddress() public {}

  function testGetTodo() public {}

  function testGetTodoByUnregisteredAddress() public {}

  function testGetAllTodo() public {}

  function testGetAllTodoByUnregisteredAddress() public {}

  function testGetAllTodoByDifferentRegisteredAddress() public {}

  function testGetAllTodoByOwner() public {}
}
