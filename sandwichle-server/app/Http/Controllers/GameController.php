<?php

namespace App\Http\Controllers;

use App\Data\PuzzleList;
use App\Factories\GuessResultFactory;
use App\ValueObjects\GuessResult;
use App\ValueObjects\Puzzle;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;

class GameController extends Controller
{
    protected PuzzleList $puzzleList;
    protected GuessResultFactory $guessResultFactory;

    public function __construct(
        PuzzleList $puzzleList,
        GuessResultFactory $guessResultFactory,
    ) {
        $this->puzzleList = $puzzleList;
        $this->guessResultFactory = $guessResultFactory;
    }

    public function start(int $puzzleId = null)
    {
        if (is_null($puzzleId)) {
            $puzzle = $this->puzzleList->getRandom();
        } else {
            $puzzle = $this->getPuzzle($puzzleId);
        }

        return new JsonResponse($puzzle->toArray());
    }

    public function guess(int $puzzleId, Request $request)
    {
        $guess = $request->get('guess', '');

        $puzzle = $this->getPuzzle($puzzleId);

        $guessResult = $this->getGuessResult($puzzle, $guess);

        return new JsonResponse($guessResult->toArray());
    }

    protected function getPuzzle(int $puzzleId): Puzzle
    {
        try {
            return $this->puzzleList->getSpecific($puzzleId);
        } catch (\InvalidArgumentException $exception) {
            throw new HttpResponseException(
                new JsonResponse(
                    ['error' => $exception->getMessage()],
                    Response::HTTP_BAD_REQUEST,
                ),
            );
        }
    }

    protected function getGuessResult(
        Puzzle $puzzle,
        string $guess,
    ): GuessResult {
        sleep(3);

        try {
            return $this
                ->guessResultFactory
                ->make(
                    $this->puzzleList->getWord($puzzle),
                    $guess,
                );
        } catch (\InvalidArgumentException $exception) {
            throw new HttpResponseException(
                new JsonResponse(
                    ['error' => $exception->getMessage()],
                    Response::HTTP_BAD_REQUEST,
                ),
            );
        }
    }
}
