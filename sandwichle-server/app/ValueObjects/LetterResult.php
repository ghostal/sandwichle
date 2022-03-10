<?php

namespace App\ValueObjects;

class LetterResult
{
    const GREY = 0;
    const YELLOW = 1;
    const GREEN = 2;

    const SLUGS = [
        self::GREY => 'wrong-letter',
        self::YELLOW => 'right-letter-wrong-spot',
        self::GREEN => 'right-letter-right-spot',
    ];

    protected string $letter;
    protected int $type;

    public static function wrongLetter(string $letter)
    {
        return new static($letter, static::GREY);
    }

    public static function rightLetterWrongSpot(string $letter)
    {
        return new static($letter, static::YELLOW);
    }

    public static function rightLetterRightSpot(string $letter)
    {
        return new static($letter, static::GREEN);
    }

    protected function __construct(string $letter, int $type)
    {
        $this->letter = $letter;
        $this->type = $type;
    }

    public function toArray(): array
    {
        return [
            'letter' => $this->letter,
            'result' => self::SLUGS[$this->type],
        ];
    }
}
