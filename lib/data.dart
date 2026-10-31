/// The palace: nine rooms on a 3×3 floor plan, walked in a snake route.
class Room {
  const Room(this.name, this.emoji, this.col, this.row, this.spots);

  final String name;
  final String emoji;
  final int col;
  final int row;

  /// Places inside the room, phrased to finish a sentence ("…inside the fridge").
  final List<String> spots;
}

class Item {
  const Item(this.emoji, this.name, this.phrase);

  final String emoji;
  final String name;

  /// The name with its article, e.g. "an elephant".
  final String phrase;
}

const rooms = <Room>[
  Room('Front Garden', '🌷', 0, 0, ['by the gate', 'in the flower bed', 'on the bench']),
  Room('Hallway', '🚪', 1, 0, ['on the doormat', 'on the coat hook', 'under the stairs']),
  Room('Living Room', '🛋️', 2, 0, ['on the sofa', 'on top of the TV', 'behind the curtains']),
  Room('Dining Room', '🍽️', 2, 1, ['on the table', 'under a chair', 'in the fruit bowl']),
  Room('Kitchen', '🍳', 1, 1, ['inside the fridge', 'on the stove', 'in the sink']),
  Room('Bathroom', '🛁', 0, 1, ['in the bathtub', 'on the mirror', 'next to the toilet']),
  Room('Bedroom', '🛏️', 0, 2, ['on the pillow', 'under the bed', 'in the wardrobe']),
  Room('Study', '📚', 1, 2, ['on the desk', 'on the bookshelf', 'in the waste bin']),
  Room('Rooftop', '🌙', 2, 2, ['on the chimney', 'by the water tank', 'on the satellite dish']),
];

const allItems = <Item>[
  Item('🦒', 'Giraffe', 'a giraffe'),
  Item('🐘', 'Elephant', 'an elephant'),
  Item('🐙', 'Octopus', 'an octopus'),
  Item('🦆', 'Duck', 'a duck'),
  Item('🐧', 'Penguin', 'a penguin'),
  Item('🦁', 'Lion', 'a lion'),
  Item('🐸', 'Frog', 'a frog'),
  Item('🐝', 'Bee', 'a giant bee'),
  Item('🦖', 'Dinosaur', 'a dinosaur'),
  Item('🐌', 'Snail', 'a snail'),
  Item('🦀', 'Crab', 'a crab'),
  Item('🐒', 'Monkey', 'a monkey'),
  Item('🍕', 'Pizza', 'a pizza'),
  Item('🍌', 'Banana', 'a banana'),
  Item('🍉', 'Watermelon', 'a watermelon'),
  Item('🍩', 'Donut', 'a donut'),
  Item('🧀', 'Cheese', 'a block of cheese'),
  Item('🥕', 'Carrot', 'a carrot'),
  Item('🥥', 'Coconut', 'a coconut'),
  Item('🍦', 'Ice cream', 'an ice cream'),
  Item('🎸', 'Guitar', 'a guitar'),
  Item('🥁', 'Drum', 'a drum'),
  Item('🎺', 'Trumpet', 'a trumpet'),
  Item('⚽', 'Football', 'a football'),
  Item('🏀', 'Basketball', 'a basketball'),
  Item('🪁', 'Kite', 'a kite'),
  Item('🎈', 'Balloon', 'a red balloon'),
  Item('🔑', 'Key', 'a golden key'),
  Item('⏰', 'Alarm clock', 'an alarm clock'),
  Item('💡', 'Light bulb', 'a light bulb'),
  Item('🌂', 'Umbrella', 'an umbrella'),
  Item('🧲', 'Magnet', 'a magnet'),
  Item('🚀', 'Rocket', 'a rocket'),
  Item('🚲', 'Bicycle', 'a bicycle'),
  Item('👑', 'Crown', 'a crown'),
  Item('🎩', 'Top hat', 'a top hat'),
  Item('🧦', 'Sock', 'a smelly sock'),
  Item('🪥', 'Toothbrush', 'a toothbrush'),
  Item('🧸', 'Teddy bear', 'a teddy bear'),
  Item('🎁', 'Gift', 'a gift box'),
  Item('🌵', 'Cactus', 'a cactus'),
  Item('🌻', 'Sunflower', 'a sunflower'),
  Item('⛄', 'Snowman', 'a snowman'),
  Item('🧁', 'Cupcake', 'a cupcake'),
];

/// What each item is doing. Strange, loud and moving pictures stick best.
const actions = <String>[
  'is dancing',
  'is fast asleep',
  'is singing loudly',
  'is spinning around',
  'is juggling oranges',
  'is doing push-ups',
  'is bouncing up and down',
  'has been painted bright pink',
  'is ten times bigger than normal',
  'is crying like a baby',
  'is wearing sunglasses',
  'is throwing a tiny party',
  'is sneezing non-stop',
  'is reading a newspaper',
  'is stuck and shouting for help',
  'is glowing like a lamp',
  'is playing hide and seek',
  'is eating spaghetti',
  'is covered in glitter',
  'is wobbling like jelly',
];
