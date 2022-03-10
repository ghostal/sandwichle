<?php

namespace App\Data;

use App\ValueObjects\Puzzle;
use Illuminate\Support\Arr;
use JetBrains\PhpStorm\Pure;

class PuzzleList
{
    protected static array $puzzles = [
        'lettuce',
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
