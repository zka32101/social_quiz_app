# Firestore Data Structure Reference

## Overview

The app uses two main collections in Firestore:

- **`prefectures`** — 47 documents representing Japanese prefectures
- **`quizzes`** — 92+ documents representing quiz questions

---

## prefectures Collection

Each prefecture document contains geographic, cultural, and economic information.

### Schema Example (Hokkaido)

```json
{
  "id": "hokkaido",
  "name": "北海道",
  "kanji": "北海道",
  "capital": "札幌",
  "latitude": 43.0642,
  "longitude": 141.3469,
  "region": "北海道",
  "mainIndustry": "農業",
  "specialtyProduct": "じゃがいも、メロン、ラッキョウ",
  "description": "日本最北端の広大な土地。冷たい気候が特徴。",
  "whyDescription": "冷たい気候なので、じゃがいもやメロンなどの冷涼地作物が育ちやすい。開拓時代から農業が中心産業。",
  "howDescription": "広大な土地を使い、機械化農業で大規模栽培。特にじゃがいもは日本最大の産地（約68%の生産量）。",
  "relatedTopics": ["開拓", "農業", "酪農"],
  "imageUrl": null,
  "videoUrl": null
}
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier (lowercase, e.g., "hokkaido") |
| `name` | string | Prefecture name in hiragana/katakana (e.g., "北海道") |
| `kanji` | string | Prefecture name in kanji + suffix (e.g., "北海道") |
| `capital` | string | Capital city name (e.g., "札幌") |
| `latitude` | number | Geographic latitude |
| `longitude` | number | Geographic longitude |
| `region` | string | Region category (e.g., "北海道", "東北", "関東") |
| `mainIndustry` | string | Primary industry (e.g., "農業", "漁業") |
| `specialtyProduct` | string | Specialty products (comma-separated) |
| `description` | string | Short description (1-2 sentences) |
| `whyDescription` | string | Why this prefecture is known for its industry/product |
| `howDescription` | string | How the product is made or industry operates |
| `relatedTopics` | array | Related topics/keywords (e.g., ["農業", "酪農"]) |
| `imageUrl` | string\|null | URL to prefecture image (for future use) |
| `videoUrl` | string\|null | URL to educational video (for future use) |

### Usage in App

```dart
// Example: Fetch prefecture for map display
final prefecture = await FirestoreService.getPrefecture('hokkaido');

// Use in UI
Text(prefecture.name)  // "北海道"
Text(prefecture.capital)  // "札幌"
```

---

## quizzes Collection

Each quiz document contains a question, answer options, and explanation.

### Schema Example (Multiple Choice)

```json
{
  "id": "q001",
  "prefectureId": "hokkaido",
  "question": "北海道の主な産業は何でしょう？",
  "type": "multipleChoice",
  "options": [
    "農業（じゃがいも）",
    "漁業",
    "工業",
    "観光業"
  ],
  "correctAnswer": "農業（じゃがいも）",
  "explanation": "北海道は冷たい気候なので、じゃがいもやメロンなどの農業が盛んです。",
  "gradeLevel": 3
}
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier (e.g., "q001") |
| `prefectureId` | string | Reference to prefecture (e.g., "hokkaido") |
| `question` | string | Question text in Japanese |
| `type` | string | Question type: "multipleChoice", "fillInBlank", "tapOnMap" |
| `options` | array | Array of answer options (4 items typical) |
| `correctAnswer` | string | The correct answer text (must match one option exactly) |
| `explanation` | string | Explanation of the correct answer |
| `gradeLevel` | number | Grade level (1-6): 1-2 (low), 3-4 (middle), 5-6 (high) |

### Usage in App

```dart
// Example: Load quizzes for a prefecture
final quizzes = await FirestoreService.getQuizzesByPrefecture('hokkaido');

// Check if answer is correct
bool isCorrect = quiz.isCorrect(userAnswer);  // Uses trim() + lowercase comparison

// Display explanation
if (isCorrect) {
  showMessage("正解！\n${quiz.explanation}");
}
```

---

## Data Statistics

### Prefectures
- **Total**: 47 documents (one for each prefecture)
- **Regions**: 北海道, 東北 (5), 関東 (7), 中部 (8), 関西 (5), 中国 (5), 四国 (4), 九州 (7), 沖縄 (1)

### Quizzes
- **Total**: 92 questions (as of initial upload)
- **Grade Levels**: 
  - Grade 1-2 (Low): ~15 questions
  - Grade 3-4 (Middle): ~50 questions
  - Grade 5-6 (High): ~27 questions
- **Distribution**: 2-4 questions per prefecture (varies by complexity)

### Distribution by Prefecture

```
hokkaido:  4 quizzes (grades 3-5)
aomori:    2 quizzes (grades 3-5)
iwate:     2 quizzes (grades 4-5)
miyagi:    2 quizzes (grades 3-5)
akita:     2 quizzes (grades 3-4)
yamagata:  2 quizzes (grades 3-5)
fukushima: 2 quizzes (grades 3-5)
ibaraki:   2 quizzes (grades 3-4)
tochigi:   2 quizzes (grades 3)
gunma:     2 quizzes (grades 3-4)
saitama:   2 quizzes (grades 3)
chiba:     2 quizzes (grades 3-4)
tokyo:     2 quizzes (grades 2-5)
kanagawa:  2 quizzes (grades 3-4)
niigata:   2 quizzes (grades 3-4)
toyama:    2 quizzes (grades 4)
ishikawa:  2 quizzes (grades 5)
fukui:     2 quizzes (grades 4-5)
yamanashi: 2 quizzes (grades 3-4)
nagano:    2 quizzes (grades 3-4)
gifu:      2 quizzes (grades 5-4)
aichi:     2 quizzes (grades 4-5)
mie:       2 quizzes (grades 4-5)
shiga:     2 quizzes (grades 3-4)
kyoto:     2 quizzes (grades 5)
osaka:     2 quizzes (grades 2-5)
hyogo:     2 quizzes (grades 5)
nara:      2 quizzes (grades 2-5)
wakayama:  2 quizzes (grades 3-4)
tottori:   2 quizzes (grades 4)
shimane:   2 quizzes (grades 4)
okayama:   2 quizzes (grades 3-5)
hiroshima: 2 quizzes (grades 3-5)
yamaguchi: 2 quizzes (grades 4)
tokushima: 2 quizzes (grades 5-4)
kagawa:    2 quizzes (grades 3-5)
ehime:     2 quizzes (grades 3-4)
kochi:     2 quizzes (grades 5-4)
fukuoka:   2 quizzes (grades 5-4)
saga:      2 quizzes (grades 4-5)
nagasaki:  2 quizzes (grades 5-4)
kumamoto:  2 quizzes (grades 4-3)
oita:      2 quizzes (grades 4-5)
miyazaki:  2 quizzes (grades 4)
kagoshima: 2 quizzes (grades 3-5)
okinawa:   2 quizzes (grades 4-3)
```

---

## Content Examples

### Prefecture: Hokkaido (北海道)
- **Main Industry**: Agriculture (Potatoes)
- **Why**: Cold climate suitable for cool-climate crops
- **How**: Large-scale mechanized farming (68% of Japan's potatoes)
- **Related Topics**: Colonization, agriculture, dairy farming

### Quiz: Multiple Choice (Grade 3)
```
Q: 北海道の主な産業は何でしょう？
A: 農業（じゃがいも）
Options: [農業, 漁業, 工業, 観光業]
```

### Quiz: Multiple Choice (Grade 5)
```
Q: 北海道でメロンが有名な理由は何ですか？
A: 昼夜の気温差が大きい
Options: [雨が多い, 昼夜の気温差が大きい, 火山が多い, 海が近い]
```

---

## Future Enhancements

### To be added after initial setup:

1. **User Progress Documents** (collection: `users`)
   ```json
   {
     "userId": "user_123",
     "visitedPrefectures": ["hokkaido", "osaka"],
     "completedQuizzes": ["q001", "q002"],
     "points": 150,
     "badges": ["hokkaido_master"],
     "lastUpdated": "2026-05-15T10:30:00Z"
   }
   ```

2. **Character Collections** (new collection: `characters`)
   - One per prefecture or theme
   - Includes illustration URL, backstory, related prefecture

3. **Educational Links** (new collection: `resources`)
   - YouTube video links
   - Wikipedia/educational site references
   - Organized by prefecture and topic

4. **Images** (Firestore Storage)
   - Prefecture images
   - Product/industry images
   - Character illustrations

---

## How to Extend Data

### Adding More Quizzes

1. Edit `data/quizzes.json`
2. Add new quiz object:
   ```json
   {
     "id": "q093",
     "prefectureId": "hokkaido",
     "question": "Your question here?",
     "type": "multipleChoice",
     "options": ["Option A", "Option B", "Option C", "Option D"],
     "correctAnswer": "Option A",
     "explanation": "Explanation of the answer",
     "gradeLevel": 3
   }
   ```
3. Run upload script again:
   ```bash
   python scripts/upload_to_firestore.py --credentials /path/to/key.json --verify
   ```

### Updating Prefecture Data

1. Edit the specific document in `data/prefectures.json`
2. Run upload script to update
3. Or manually edit in Firestore Console

---

## Firestore Best Practices

1. **Read Cost**: Each document read = 1 billing unit
   - Fetching all 47 prefectures = 47 reads
   - Cache prefectures locally when possible

2. **Query Patterns**:
   - Get quizzes by prefecture: `quizzes.where('prefectureId', '==', 'hokkaido')`
   - Get quizzes by grade: `quizzes.where('gradeLevel', '==', 3)`

3. **Indexing**: For filters, create composite indexes in Firestore Console if needed

---

For more details, see [FIREBASE_SETUP.md](./FIREBASE_SETUP.md)
