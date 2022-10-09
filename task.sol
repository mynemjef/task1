//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./contracts/2_Owner.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Library is Owner{

    struct Book{
        uint id;
        uint availability;
    }

    Book[]public books;

    mapping (address => Book[]) userToBooks;
    mapping (address => uint) userToBorrowedBooksCount;
    mapping(uint => address[]) bookIdToAllBorrowers;

    event ShowBook(uint id, uint availability);
    event ShowAddr(address addr);

    function addNewBook(uint _id, uint _availability) public isOwner() {
        books.push(Book(_id, _availability));
    }

    function showAvailableBooks() public {
        for(uint i = 0; i < books.length; i++){
            emit ShowBook(books[i].id, books[i].availability);
        }
    }

    function findBookById(Book[] memory _books, uint _id) private pure returns(Book memory) {
        Book memory book;
        for(uint i = 0; i < _books.length; i++){
            if(_books[i].id == _id){
                book = _books[i];
                return book;
            }
        }
        return book;
    }

    function borrowBook(uint _id) public {
        address user = msg.sender;
        Book memory book = findBookById(books, _id);

        require(!checkIfUserHasBook(user, _id));
        require(book.availability > 0);

        userToBooks[user].push(book);
        bookIdToAllBorrowers[book.id].push(user);
        book.availability--;
    }

    function returnBook(uint _id) public {
        address user = msg.sender;

        require(checkIfUserHasBook(user, _id));

        Book memory book = findBookById(userToBooks[user], _id);
        deleteBook(userToBooks[user], _id);
        book.availability++;
    }

    function checkIfUserHasBook(address _user, uint _id) private view returns(bool) {
        for(uint i = 0; i < userToBooks[_user].length; i++){
            if(userToBooks[_user][i].id == _id){
                return true;
            }
        }
        return false;
    }

    function deleteBook(Book[] storage _books, uint _id) private {
        Book storage book;
        for(uint i = 0; i < _books.length; i++){
            if(_books[i].id == _id){
                book = _books[i];
            }
        }
        
        for(uint i = 0; i < _books.length; i++){
            if(_books[i].id == _id){
                _books[i] = _books[_books.length - 1];
                _books.pop();
            }
        }
    }

    function seeAllAddressesBorrowed(uint _id) public {
        for(uint i = 0; i < bookIdToAllBorrowers[_id].length; i++){
            emit ShowAddr(bookIdToAllBorrowers[_id][i]); 
        }
    }
}
