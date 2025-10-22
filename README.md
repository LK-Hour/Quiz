# Console Quiz (Dart)

A simple interactive console quiz app written in Dart. Questions are loaded from a JSON file, parsed into typed models, and played in the terminal. Multiple players can take turns; scores are shown in percentage and total points.

School base-project — created for coursework and learning purposes.

Owner: Hour

## Features

- Load questions from `lib/data/questions.json`
- Strongly typed domain models: `Question`, `Answer`, `Quiz`
- Auto-generated UUID for each `Question` (or use an `id` from JSON)
- Case-insensitive answer checking
- Percentage score and total points
- Console UI for multiple players with a running scoreboard
- Unit tests covering core behavior

## Project structure

```
lib/
	main.dart                 # Entry point: loads JSON, starts the console UI
	data/
		quiz_file_provider.dart # JSON file reading helper
		questions.json          # Quiz data (editable)
	domain/
		quiz.dart               # Question, Answer, Quiz models + logic
	ui/
		quiz_console.dart       # Console interaction loop

test/
	quiz_test.dart            # Unit tests for models and data loading
pubspec.yaml                # Dependencies: uuid, test
```

## Requirements

- Dart SDK 3.x

## Setup

```bash
# From the project root
dart pub get
```

## Run

```bash
# From the project root
dart lib/main.dart
```

The app is interactive:
- Enter a player name (press Enter on an empty name to finish)
- Answer each question
- See your percentage and total point score
- The scoreboard prints all players’ scores

## Test

```bash
# From the project root
dart test
```

## JSON format

`lib/data/questions.json` should contain an object with a `questions` array. Each question supports the following fields:

```json
{
	"questions": [
		{
			"id": "optional-string-id",             // optional; if omitted, a UUID is generated
			"title": "Capital of France?",          // required
			"choices": ["Paris", "London", "Rome"], // required: array of strings
			"goodChoice": "Paris",                   // required: must match one of choices
			"point": 10                               // required: integer points
		}
	]
}
```

Notes:
- `id` is optional. If not provided, the app assigns a UUID v4 automatically.
- `goodChoice` comparisons are case-insensitive during answer checks.

## Implementation details

- `Question`
	- Fields: `id`, `title`, `choices`, `goodChoice`, `point`
	- Constructor generates `id` with `uuid.v4()` when not provided
	- `factory Question.fromJson(Map<String, dynamic>)` parses a JSON object into a `Question`
- `Answer`
	- Binds a `Question` to a user’s `answerChoice`
	- `isGood()` does a case-insensitive comparison to the question’s `goodChoice`
- `Quiz`
	- Holds `questions` and collected `answers`
	- `getScoreInPercentage()` returns truncated integer percentage (e.g., 1/3 → 33)
	- `getTotalPoint()` sums points for correct answers by index alignment with questions

## Important behavior

- Multiple players: `ui/quiz_console.dart` clears previous answers between players so scoring is per-player.
- Order of answers: `getTotalPoint()` assumes answers are recorded in the same order as the questions list (the console UI enforces this). If you later collect answers out of order (e.g., by question id), consider changing the logic to sum based on the `Answer.question` instead of index alignment.

## Customizing

- Add or edit questions in `lib/data/questions.json`
- To show the question id during play, you can log `question.id` in `quiz_console.dart`
- If you want to load JSON from another path, update the path in `lib/main.dart`:
	```dart
	final data = await loadJsonFromFile('lib/data/questions.json');
	```

## Troubleshooting

- Path errors when reading JSON: make sure you run from the project root and the file exists at `lib/data/questions.json`.
- Type errors on JSON parse: ensure numeric fields like `point` are numbers, and `choices` is an array of strings.
- Interactive input hangs: the app waits for input in the terminal; type your answers and press Enter.

## License

This project is for educational/demonstration purposes.

## Ownership and status

- Owner: Hour
- Project type: School base-project

