// Testing

import 'package:flutter/material.dart';

const users = [
  userShania,
  userCheryl,
  userTom,
  userJohn,
];

const userShania = ChatUser(
  id: 'shania',
  name: 'Shania',
  image: 'https://i.pinimg.com/736x/8b/57/0c/8b570c0676a1dabc40c88e214b2079d1.jpg',
);

const userCheryl = ChatUser(
  id: 'cheryl',
  name: 'Cheryl',
  image: 'https://i.pinimg.com/736x/8b/57/0c/8b570c0676a1dabc40c88e214b2079d1.jpg',
);

const userTom = ChatUser(
  id: 'tom',
  name: 'Tom',
  image: 'https://www.shutterstock.com/image-photo/side-profile-dachshund-basic-flat-600nw-2511636641.jpg',
);

const userJohn = ChatUser(
  id: 'john',
  name: 'John',
  image: 'https://images.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg?cs=srgb&dl=pexels-pixabay-104827.jpg&fm=jpg',
);

@immutable
class ChatUser {
  final String id;
  final String name;
  final String image;

  const ChatUser({
    required this.id,
    required this.name,
    required this.image,
  });
}