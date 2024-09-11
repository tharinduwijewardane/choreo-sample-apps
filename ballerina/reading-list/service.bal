// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com/) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/graphql;

# A service representing a network-accessible GraphQL API
service graphql:Service / on new graphql:Listener(8090) {

    # Returns all reading list items with optionally filtered from the reading status.
    # + status - Optional filter to list the reading list items by reading status.
    # + return - The list of books.
    resource function get allBooks(string? status) returns Book[] {
        lock {
            Book[] books;
            if status is Status {
                books = from var book in readingList
                    where book.status == status
                    select book;
            } else {
                books = from var book in readingList
                    select book;
            }
            return books.cloneReadOnly();
        }
    }

    # Returns a book item from a given Id.
    # + id - Id of the required book item.
    # + return - Book item for the given Id if it exists or else returns null.
    resource function get book(int id) returns Book? {
        lock {
            if readingList[id] is Book {
                return readingList[id].cloneReadOnly();
            }
            return;
        }
    }

    # Add a book item to the reading list.
    # + book - User input for the new book item.
    # + return - Newly created book item.
    remote function addBook(CreateBookInput book) returns Book {
        lock {
            int id = readingList.length() + 1;
            Book newBook = {
                id: id,
                title: book.title,
                author: book.author,
                status: to_read
            };
            readingList.add(newBook);
            return newBook.cloneReadOnly();
        }
    }

    # Update the reading status of a book item.
    # + id - Id of the updating book item.
    # + status - Flag indicating the reading status.
    # + return - updated book item.
    remote function setStatus(int id, string status) returns Book? {
        lock {
            Book? book = readingList[id];
            if (book is ()) {
                return;
            }
            book.status = <Status>status;
            // TODO: do we need to update the reading list?
            return book.cloneReadOnly();
        }
    }

    # Delete the book item from the reading list.
    # + id - Id of the deleting book item.
    # + return - deleted book item.
    remote function deleteBook(int id) returns Book? {
        lock {
            Book? book = readingList[id];
            if (book is ()) {
                return;
            }
            Book removedBook = readingList.remove(id);
            return removedBook.cloneReadOnly();
        }
    }
}

# A service representing a network-accessible GraphQL API
service graphql:Service / on new graphql:Listener(8091) {

    # Returns all reading list items with optionally filtered from the reading status.
    # + status - Optional filter to list the reading list items by reading status.
    # + return - The list of books.
    resource function get allBooks(string? status) returns Book[] {
        lock {
            Book[] books;
            if status is Status {
                books = from var book in readingList
                    where book.status == status
                    select book;
            } else {
                books = from var book in readingList
                    select book;
            }
            return books.cloneReadOnly();
        }
    }

    # Returns a book item from a given Id.
    # + id - Id of the required book item.
    # + return - Book item for the given Id if it exists or else returns null.
    resource function get book(int id) returns Book? {
        lock {
            if readingList[id] is Book {
                return readingList[id].cloneReadOnly();
            }
            return;
        }
    }

    # Add a book item to the reading list.
    # + book - User input for the new book item.
    # + return - Newly created book item.
    remote function addBook(CreateBookInput book) returns Book {
        lock {
            int id = readingList.length() + 1;
            Book newBook = {
                id: id,
                title: book.title,
                author: book.author,
                status: to_read
            };
            readingList.add(newBook);
            return newBook.cloneReadOnly();
        }
    }

    # Update the reading status of a book item.
    # + id - Id of the updating book item.
    # + status - Flag indicating the reading status.
    # + return - updated book item.
    remote function setStatus(int id, string status) returns Book? {
        lock {
            Book? book = readingList[id];
            if (book is ()) {
                return;
            }
            book.status = <Status>status;
            // TODO: do we need to update the reading list?
            return book.cloneReadOnly();
        }
    }

    # Delete the book item from the reading list.
    # + id - Id of the deleting book item.
    # + return - deleted book item.
    remote function deleteBook(int id) returns Book? {
        lock {
            Book? book = readingList[id];
            if (book is ()) {
                return;
            }
            Book removedBook = readingList.remove(id);
            return removedBook.cloneReadOnly();
        }
    }
}

public enum Status {
    reading = "reading",
    read = "read",
    to_read = "to_read"
}

# Record that represents book item
#
# + id - Autogenerated unique id for the book item  
# + title - Title of the book 
# + author - Author of the book
# + status - Indicates the reading status of the book
public type Book record {|
    readonly int id;
    string title;
    string author;
    Status status;
|};

# User input record for addBook GQL mutation
#
# + title - Title of the book 
# + author - Author of the book
public type CreateBookInput record {
    string title;
    string author;
};

# Table for storing reading list items in memory
isolated table<Book> key(id) readingList = table [];
