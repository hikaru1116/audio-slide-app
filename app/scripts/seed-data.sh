#!/bin/bash

echo "Starting to seed initial data into DynamoDB..."

DYNAMODB_ENDPOINT="http://localhost:8000"
TIMESTAMP="2025-07-04T13:00:00Z"

echo "Seeding flags category data..."

# アルゼンチン
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#flags"},"SK":{"S":"QUIZ#quiz_flag_001"},"id":{"S":"quiz_flag_001"},"questionImageUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/images/flags/ar.png"},"questionAudioUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/audio/flags/ar.mp3"},"correctAnswer":{"S":"アルゼンチン"},"choices":{"L":[{"S":"アルゼンチン"},{"S":"ブラジル"},{"S":"メキシコ"},{"S":"コロンビア"}]},"category":{"S":"flags"},"explanation":{"S":"アルゼンチンの国旗は白地に青いスパイクと黄色い太陽があります。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# イギリス
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#flags"},"SK":{"S":"QUIZ#quiz_flag_002"},"id":{"S":"quiz_flag_002"},"questionImageUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/images/flags/gb.png"},"questionAudioUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/audio/flags/gb.mp3"},"correctAnswer":{"S":"イギリス"},"choices":{"L":[{"S":"イギリス"},{"S":"フランス"},{"S":"ドイツ"},{"S":"スペイン"}]},"category":{"S":"flags"},"explanation":{"S":"イギリスの国旗は白地に赤い十字架があります。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# 日本
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#flags"},"SK":{"S":"QUIZ#quiz_flag_003"},"id":{"S":"quiz_flag_003"},"questionImageUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/images/flags/jp.png"},"questionAudioUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/audio/flags/jp.mp3"},"correctAnswer":{"S":"日本"},"choices":{"L":[{"S":"日本"},{"S":"韓国"},{"S":"中国"},{"S":"タイ"}]},"category":{"S":"flags"},"explanation":{"S":"日本の国旗は白地に赤い丸（日の丸）です。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# アメリカ
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#flags"},"SK":{"S":"QUIZ#quiz_flag_004"},"id":{"S":"quiz_flag_004"},"questionImageUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/images/flags/us.png"},"questionAudioUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/audio/flags/us.mp3"},"correctAnswer":{"S":"アメリカ"},"choices":{"L":[{"S":"アメリカ"},{"S":"カナダ"},{"S":"イギリス"},{"S":"オーストラリア"}]},"category":{"S":"flags"},"explanation":{"S":"アメリカの国旗は星条旗と呼ばれ、50の星と13の縞模様があります。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# ブラジル
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#flags"},"SK":{"S":"QUIZ#quiz_flag_005"},"id":{"S":"quiz_flag_005"},"questionImageUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/images/flags/br.png"},"questionAudioUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/audio/flags/br.mp3"},"correctAnswer":{"S":"ブラジル"},"choices":{"L":[{"S":"ブラジル"},{"S":"アルゼンチン"},{"S":"メキシコ"},{"S":"コロンビア"}]},"category":{"S":"flags"},"explanation":{"S":"ブラジルの国旗は緑地に黄色い菱形と青い円があります。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# パプアニューギニア
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#flags"},"SK":{"S":"QUIZ#quiz_flag_006"},"id":{"S":"quiz_flag_006"},"questionImageUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/images/flags/pg.png"},"questionAudioUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/audio/flags/pg.mp3"},"correctAnswer":{"S":"パプアニューギニア"},"choices":{"L":[{"S":"パプアニューギニア"},{"S":"オーストラリア"},{"S":"ニュージーランド"},{"S":"フィジー"}]},"category":{"S":"flags"},"explanation":{"S":"パプアニューギニアの国旗は青地に白い十字架と赤い星があります。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# インドネシア
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#flags"},"SK":{"S":"QUIZ#quiz_flag_007"},"id":{"S":"quiz_flag_007"},"questionImageUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/images/flags/id.png"},"questionAudioUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/audio/flags/id.mp3"},"correctAnswer":{"S":"インドネシア"},"choices":{"L":[{"S":"インドネシア"},{"S":"マレーシア"},{"S":"フィリピン"},{"S":"シンガポール"}]},"category":{"S":"flags"},"explanation":{"S":"インドネシアの国旗は白地に赤いスパイクと青い円があります。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# 韓国
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#flags"},"SK":{"S":"QUIZ#quiz_flag_008"},"id":{"S":"quiz_flag_008"},"questionImageUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/images/flags/kr.png"},"questionAudioUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/audio/flags/kr.mp3"},"correctAnswer":{"S":"韓国"},"choices":{"L":[{"S":"韓国"},{"S":"日本"},{"S":"中国"},{"S":"タイ"}]},"category":{"S":"flags"},"explanation":{"S":"韓国の国旗は白地に赤い太陽と青い太陽があります。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# スウェーデン
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#flags"},"SK":{"S":"QUIZ#quiz_flag_009"},"id":{"S":"quiz_flag_009"},"questionImageUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/images/flags/se.png"},"questionAudioUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/audio/flags/se.mp3"},"correctAnswer":{"S":"スウェーデン"},"choices":{"L":[{"S":"スウェーデン"},{"S":"ノルウェー"},{"S":"デンマーク"},{"S":"スペイン"}]},"category":{"S":"flags"},"explanation":{"S":"スウェーデンの国旗は白地に青い十字架があります。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# インド
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#flags"},"SK":{"S":"QUIZ#quiz_flag_010"},"id":{"S":"quiz_flag_010"},"questionImageUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/images/flags/in.png"},"questionAudioUrl":{"S":"https://audio-slide-app-assets.s3.ap-northeast-1.amazonaws.com/audio/flags/in.mp3"},"correctAnswer":{"S":"インド"},"choices":{"L":[{"S":"インド"},{"S":"パキスタン"},{"S":"バングラデシュ"},{"S":"ネパール"}]},"category":{"S":"flags"},"explanation":{"S":"インドの国旗は黄、橙、白、緑、青、赤の6色のパターンがあります。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

echo "Seeding animals category data..."

# ライオン
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#animals"},"SK":{"S":"QUIZ#quiz_animal_001"},"id":{"S":"quiz_animal_001"},"questionImageUrl":{"S":"https://cdn.example.com/animals/lion.jpg"},"questionAudioUrl":{"S":"https://cdn.example.com/audio/lion.mp3"},"correctAnswer":{"S":"ライオン"},"choices":{"L":[{"S":"ライオン"},{"S":"トラ"},{"S":"ヒョウ"},{"S":"チーター"}]},"category":{"S":"animals"},"explanation":{"S":"ライオンは百獣の王と呼ばれる大型の肉食動物です。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# 象
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#animals"},"SK":{"S":"QUIZ#quiz_animal_002"},"id":{"S":"quiz_animal_002"},"questionImageUrl":{"S":"https://cdn.example.com/animals/elephant.jpg"},"questionAudioUrl":{"S":"https://cdn.example.com/audio/elephant.mp3"},"correctAnswer":{"S":"象"},"choices":{"L":[{"S":"象"},{"S":"サイ"},{"S":"カバ"},{"S":"キリン"}]},"category":{"S":"animals"},"explanation":{"S":"象は陸上で最大の哺乳類で、長い鼻が特徴です。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# ペンギン
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#animals"},"SK":{"S":"QUIZ#quiz_animal_003"},"id":{"S":"quiz_animal_003"},"questionImageUrl":{"S":"https://cdn.example.com/animals/penguin.jpg"},"questionAudioUrl":{"S":"https://cdn.example.com/audio/penguin.mp3"},"correctAnswer":{"S":"ペンギン"},"choices":{"L":[{"S":"ペンギン"},{"S":"アザラシ"},{"S":"イルカ"},{"S":"クジラ"}]},"category":{"S":"animals"},"explanation":{"S":"ペンギンは泳ぎが得意な鳥で、主に南極に住んでいます。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# パンダ
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#animals"},"SK":{"S":"QUIZ#quiz_animal_004"},"id":{"S":"quiz_animal_004"},"questionImageUrl":{"S":"https://cdn.example.com/animals/panda.jpg"},"questionAudioUrl":{"S":"https://cdn.example.com/audio/panda.mp3"},"correctAnswer":{"S":"パンダ"},"choices":{"L":[{"S":"パンダ"},{"S":"コアラ"},{"S":"アライグマ"},{"S":"レッサーパンダ"}]},"category":{"S":"animals"},"explanation":{"S":"パンダは白と黒の毛色が特徴的で、竹を食べます。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# カンガルー
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#animals"},"SK":{"S":"QUIZ#quiz_animal_005"},"id":{"S":"quiz_animal_005"},"questionImageUrl":{"S":"https://cdn.example.com/animals/kangaroo.jpg"},"questionAudioUrl":{"S":"https://cdn.example.com/audio/kangaroo.mp3"},"correctAnswer":{"S":"カンガルー"},"choices":{"L":[{"S":"カンガルー"},{"S":"コアラ"},{"S":"ウォンバット"},{"S":"タスマニアデビル"}]},"category":{"S":"animals"},"explanation":{"S":"カンガルーはオーストラリアの代表的な動物で、ジャンプが得意です。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

echo "Seeding words category data..."

# りんご
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#words"},"SK":{"S":"QUIZ#quiz_word_001"},"id":{"S":"quiz_word_001"},"questionImageUrl":{"S":"https://cdn.example.com/words/apple.jpg"},"questionAudioUrl":{"S":"https://cdn.example.com/audio/apple.mp3"},"correctAnswer":{"S":"りんご"},"choices":{"L":[{"S":"りんご"},{"S":"みかん"},{"S":"ぶどう"},{"S":"いちご"}]},"category":{"S":"words"},"explanation":{"S":"りんごは赤い果物で、英語でappleと言います。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# 本
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#words"},"SK":{"S":"QUIZ#quiz_word_002"},"id":{"S":"quiz_word_002"},"questionImageUrl":{"S":"https://cdn.example.com/words/book.jpg"},"questionAudioUrl":{"S":"https://cdn.example.com/audio/book.mp3"},"correctAnswer":{"S":"本"},"choices":{"L":[{"S":"本"},{"S":"雑誌"},{"S":"新聞"},{"S":"手紙"}]},"category":{"S":"words"},"explanation":{"S":"本は知識を得るために読むもので、英語でbookと言います。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# 車
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#words"},"SK":{"S":"QUIZ#quiz_word_003"},"id":{"S":"quiz_word_003"},"questionImageUrl":{"S":"https://cdn.example.com/words/car.jpg"},"questionAudioUrl":{"S":"https://cdn.example.com/audio/car.mp3"},"correctAnswer":{"S":"車"},"choices":{"L":[{"S":"車"},{"S":"バス"},{"S":"電車"},{"S":"自転車"}]},"category":{"S":"words"},"explanation":{"S":"車は人や物を運ぶ乗り物で、英語でcarと言います。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# 家
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#words"},"SK":{"S":"QUIZ#quiz_word_004"},"id":{"S":"quiz_word_004"},"questionImageUrl":{"S":"https://cdn.example.com/words/house.jpg"},"questionAudioUrl":{"S":"https://cdn.example.com/audio/house.mp3"},"correctAnswer":{"S":"家"},"choices":{"L":[{"S":"家"},{"S":"学校"},{"S":"病院"},{"S":"店"}]},"category":{"S":"words"},"explanation":{"S":"家は人が住む建物で、英語でhouseと言います。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

# 水
aws dynamodb put-item --endpoint-url $DYNAMODB_ENDPOINT --table-name Quiz --item '{"PK":{"S":"CATEGORY#words"},"SK":{"S":"QUIZ#quiz_word_005"},"id":{"S":"quiz_word_005"},"questionImageUrl":{"S":"https://cdn.example.com/words/water.jpg"},"questionAudioUrl":{"S":"https://cdn.example.com/audio/water.mp3"},"correctAnswer":{"S":"水"},"choices":{"L":[{"S":"水"},{"S":"ジュース"},{"S":"お茶"},{"S":"コーヒー"}]},"category":{"S":"words"},"explanation":{"S":"水は生きるために必要な液体で、英語でwaterと言います。"},"createdAt":{"S":"'$TIMESTAMP'"},"updatedAt":{"S":"'$TIMESTAMP'"}}'

echo "Initial data seeding completed successfully!"
echo "Seeded 15 quiz items across 3 categories:"
echo "- Flags: 5 items"
echo "- Animals: 5 items"  
echo "- Words: 5 items"