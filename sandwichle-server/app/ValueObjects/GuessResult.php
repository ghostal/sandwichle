<?php

namespace App\ValueObjects;

class GuessResult
{
    /** @var array<LetterResult> */
    protected array $letterResults;

    /**
     * @param array<LetterResult> $letterResults
     */
    public function __construct(array $letterResults)
    {
        $this->letterResults = $letterResults;
    }

    public function toArray(): array
    {
        return array_map(
            function (LetterResult $letterResult) {
                return $letterResult->toArray();
            },
            $this->letterResults,
        );
    }
}
