<?php

namespace App\Data;

use App\ValueObjects\Puzzle;
use Illuminate\Support\Arr;
use JetBrains\PhpStorm\Pure;

class PuzzleList
{
    protected static array $puzzles = [
        'egg',
        'jam',
        'ham',
        'rye',
        'beef',
        'brie',
        'gyro',
        'corn',
        'feta',
        'lamb',
        'naan',
        'pork',
        'salt',
        'spam',
        'tuna',
        'wrap',
        'apple',
        'bacon',
        'bagel',
        'basel',
        'beans',
        'bread',
        'chili',
        'chips',
        'cress',
        'cumin',
        'dijon',
        'grape',
        'honey',
        'kebab',
        'olive',
        'onion',
        'pitta',
        'prawn',
        'salad',
        'steak',
        'butter',
        'capers',
        'carrot',
        'cheese',
        'chives',
        'crisps',
        'garlic',
        'panini',
        'pickle',
        'pepper',
        'potato',
        'raisin',
        'reuben',
        'rocket',
        'salami',
        'salmon',
        'tomato',
        'turkey',
        'avocado',
        'cheddar',
        'chorizo',
        'chicken',
        'chutney',
        'eggmayo',
        'falafel',
        'gherkin',
        'humous',
        'hummus',
        'lettuce',
        'ketchup',
        'marmite',
        'mustard',
        'nutella',
        'paprika',
        'sausage',
        'spinach',
        'baguette',
        'beetroot',
        'chickpea',
        'ciabatta',
        'coleslaw',
        'cucumber',
        'focaccia',
        'jalapeno',
        'meatball',
        'mushroom',
        'omelette',
        'pastrami',
        'redonion',
        'saltbeef',
        'marinara',
        'aubergine',
        'cranberry',
        'coriander',
        'courgette',
        'jackfruit',
        'flatbread',
        'pepperoni',
        'sweetcorn',
        'fishfillet',
        'bellpepper',
        'bluecheese',
        'pepperjack',
        'pulledpork',
        'prosciutto',
        'mayonnaise',
        'mozzarella',
        'redcabbage',
        'springonion',
        'peanutbutter',
    ];

    public function getRandom(): Puzzle
    {
        return $this->buildPuzzle(Arr::random(static::$puzzles));
    }

    public function getSpecific(int $puzzleId): Puzzle
    {
        if (!isset(static::$puzzles[$puzzleId])) {
            throw new \InvalidArgumentException('No such puzzle');
        }

        return $this->buildPuzzle(static::$puzzles[$puzzleId]);
    }

    public function getWord(Puzzle $puzzle)
    {
        return static::$puzzles[$puzzle->getPuzzleId()];
    }

    #[Pure]
    protected function buildPuzzle(string $word): Puzzle
    {
        return new Puzzle(
            array_search($word, static::$puzzles),
            strlen($word),
        );
    }
}
