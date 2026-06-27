# HarmonyPuzzle

HarmonyPuzzle is a local HarmonyOS sliding tile puzzle game built with ArkUI and Stage model project structure.

## Features

- 3x3, 4x4, and 5x5 puzzle difficulties
- Tap-to-move sliding puzzle gameplay
- Timer and step counter
- Hint overlay with the original image
- Local leaderboard stored with relationalStore
- Solvable shuffles generated from valid moves

## Project Structure

- `AppScope/app.json5`
- `entry/src/main/module.json5`
- `entry/src/main/ets/entryability/EntryAbility.ets`
- `entry/src/main/ets/pages/IndexPage.ets`
- `entry/src/main/ets/pages/GamePage.ets`
- `entry/src/main/ets/pages/ResultPage.ets`
- `entry/src/main/ets/components/PuzzleGrid.ets`
- `entry/src/main/ets/components/TimerDisplay.ets`
- `entry/src/main/ets/components/StepCounter.ets`
- `entry/src/main/ets/database/GameDatabase.ets`
- `entry/src/main/ets/model/GameRecord.ets`
- `entry/src/main/ets/utils/GameLogic.ets`
- `entry/src/main/resources/base/profile/main_pages.json`

## Notes

The puzzle images currently use the app icon resource as a placeholder for all built-in image choices.
