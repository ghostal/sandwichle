<?php

namespace App\ValueObjects;

class Puzzle
{
    protected int $id;
    protected int $wordLength;

    public function __construct(int $id, int $wordLength)
    {
        $this->id = $id;
        $this->wordLength = $wordLength;
    }

    public function toArray(): array
    {
        return [
            'puzzleId' => $this->id,
            'wordLength' => $this->wordLength,
        ];
    }

    public function getPuzzleId(): int
    {
        return $this->id;
    }

    public function getWordLength(): int
    {
        return $this->wordLength;
    }
}
