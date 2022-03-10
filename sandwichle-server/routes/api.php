<?php

use App\Http\Controllers\GameController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::get('/puzzle/random', [GameController::class, 'start']);
Route::get('/puzzle/{puzzleId}', [GameController::class, 'start']);
Route::post('/puzzle/{puzzleId}/guess', [GameController::class, 'guess']);
