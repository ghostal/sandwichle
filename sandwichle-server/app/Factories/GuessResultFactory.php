<?php

namespace App\Factories;

use App\ValueObjects\GuessResult;
use App\ValueObjects\LetterResult;

class GuessResultFactory
{
    public function make(string $puzzleWord, string $guess)
    {
        if (($length = strlen($guess)) != strlen($puzzleWord)) {
            throw new \InvalidArgumentException('Wrong number of letters!');
        }

        $puzzleWord = str_split(strtolower($puzzleWord));
        $guess = str_split(strtolower($guess));
        $result = array_fill(0, $length, null);

        // Check for right letters in the right place
        for ($i = 0; $i < $length; $i++) {
            if ($guess[$i] === $puzzleWord[$i]) {
                $result[$i] = LetterResult::rightLetterRightSpot($guess[$i]);
                $guess[$i] = $puzzleWord[$i] = null;
            }
        }

        // Check for right letters in the wrong place
        for ($i = 0; $i < $length; $i++) {
            if (is_null($guess[$i])) {
                // Already done
                continue;
            }

            $otherPosition = array_search($guess[$i], $puzzleWord);

            if ($otherPosition === false) {
                $result[$i] = LetterResult::wrongLetter($guess[$i]);
            } else {
                $result[$i] = LetterResult::rightLetterWrongSpot($guess[$i]);
                $puzzleWord[$otherPosition] = null;
            }
        }

        return new GuessResult($result);
    }
}
