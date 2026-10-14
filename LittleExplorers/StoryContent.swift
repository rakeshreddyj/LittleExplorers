import Foundation

/// Short picture stories for read-along. Simple sentences built from sight words and 3-letter words.
/// The classic fables (Thirsty Crow, Lion and Mouse, Tortoise and Hare) are retold in our own words.
struct StoryPage: Hashable { let scene: String; let text: String }
struct StoryQuestion: Hashable { let q: String; let answer: String; let wrong: [String] }

struct Story: Identifiable, Hashable {
    let id: String
    let title: String
    let cover: String
    let classOne: Bool          // false = right for UKG
    let pages: [StoryPage]
    let questions: [StoryQuestion]
}

let stories: [Story] = [
    Story(id: "red_ball", title: "Ria and the Red Ball", cover: "⚽", classOne: false, pages: [
        .init(scene: "👧⚽", text: "Ria has a red ball."),
        .init(scene: "⚽⬆️", text: "The ball goes up, up, up!"),
        .init(scene: "🌳⚽", text: "Oh no! The ball is in the tree."),
        .init(scene: "🐒", text: "A monkey sees the ball."),
        .init(scene: "🐒⚽👧", text: "The monkey gives the ball to Ria."),
        .init(scene: "👧😊", text: "Thank you, monkey!"),
    ], questions: [
        .init(q: "What colour is the ball?", answer: "red", wrong: ["blue", "green"]),
        .init(q: "Who gave the ball back?", answer: "the monkey", wrong: ["the cat", "the dog"]),
    ]),
    Story(id: "thirsty_crow", title: "The Thirsty Crow", cover: "🐦‍⬛", classOne: false, pages: [
        .init(scene: "☀️🐦‍⬛", text: "It is a hot day. The crow is thirsty."),
        .init(scene: "🏺", text: "The crow sees a pot. There is a little water in it."),
        .init(scene: "🐦‍⬛🪨", text: "The crow drops small stones in the pot."),
        .init(scene: "🏺💧", text: "The water comes up, up, up!"),
        .init(scene: "🐦‍⬛💧😊", text: "The crow drinks the water. Clever crow!"),
    ], questions: [
        .init(q: "What did the crow drop in the pot?", answer: "stones", wrong: ["leaves", "sticks"]),
        .init(q: "Why did the crow want water?", answer: "it was thirsty", wrong: ["it was cold", "it was sleepy"]),
    ]),
    Story(id: "garden", title: "Arjun's Seed", cover: "🌻", classOne: false, pages: [
        .init(scene: "👦🌱", text: "Arjun puts a little seed in the soil."),
        .init(scene: "👦💧", text: "He gives it water every day."),
        .init(scene: "☀️🌱", text: "The sun is warm. The seed grows."),
        .init(scene: "🌻", text: "Look! A big yellow flower!"),
        .init(scene: "🐝🌻", text: "A bee comes to say hello."),
    ], questions: [
        .init(q: "What did Arjun put in the soil?", answer: "a seed", wrong: ["a stone", "a toy"]),
        .init(q: "What came to the flower?", answer: "a bee", wrong: ["a fish", "a car"]),
    ]),
    Story(id: "birthday", title: "Meera's Birthday", cover: "🎂", classOne: false, pages: [
        .init(scene: "👧🎂", text: "Today is Meera's birthday."),
        .init(scene: "🎈🎈", text: "Her friends bring red and blue balloons."),
        .init(scene: "👵🎁", text: "Dadi gives her a big box."),
        .init(scene: "🎁🐶", text: "In the box is a little puppy!"),
        .init(scene: "👧🐶🥰", text: "Meera hugs the puppy. What a happy day!"),
    ], questions: [
        .init(q: "Whose birthday is it?", answer: "Meera", wrong: ["Ria", "Dev"]),
        .init(q: "What was in the box?", answer: "a puppy", wrong: ["a ball", "a book"]),
    ]),
    Story(id: "rain", title: "Pit, Pat, Rain!", cover: "🌧️", classOne: false, pages: [
        .init(scene: "☁️☁️", text: "Grey clouds come in the sky."),
        .init(scene: "🌧️", text: "Pit, pat, pit, pat! It is raining."),
        .init(scene: "👦☂️", text: "Kabir takes his umbrella."),
        .init(scene: "🐸💦", text: "A frog jumps in the water. Splash!"),
        .init(scene: "🌈", text: "The rain stops. Look, a rainbow!"),
    ], questions: [
        .init(q: "What did Kabir take?", answer: "an umbrella", wrong: ["a cap", "a bag"]),
        .init(q: "What came after the rain?", answer: "a rainbow", wrong: ["the moon", "snow"]),
    ]),
    Story(id: "school", title: "Dev Goes to School", cover: "🎒", classOne: false, pages: [
        .init(scene: "🌅👦", text: "Dev wakes up in the morning."),
        .init(scene: "🪥", text: "He brushes his teeth."),
        .init(scene: "🥣", text: "He eats his breakfast."),
        .init(scene: "🎒", text: "He takes his school bag."),
        .init(scene: "🚌👋", text: "He gets on the yellow bus. Bye, Amma!"),
    ], questions: [
        .init(q: "What did Dev do after he woke up?", answer: "brushed his teeth", wrong: ["went to sleep", "played cricket"]),
        .init(q: "What colour is the bus?", answer: "yellow", wrong: ["red", "green"]),
    ]),
    Story(id: "night", title: "Good Night, Moon", cover: "🌙", classOne: false, pages: [
        .init(scene: "🌙", text: "It is night. The moon is up."),
        .init(scene: "⭐✨", text: "Little stars shine in the sky."),
        .init(scene: "🦉", text: "An owl says, hoo, hoo!"),
        .init(scene: "👧🛏️", text: "Anaya gets into her bed."),
        .init(scene: "😴🌙", text: "Good night, moon. Good night, Anaya."),
    ], questions: [
        .init(q: "Who says hoo, hoo?", answer: "the owl", wrong: ["the cow", "the dog"]),
        .init(q: "When does this story happen?", answer: "at night", wrong: ["in the morning", "at lunch time"]),
    ]),
    Story(id: "ant", title: "The Little Ant", cover: "🐜", classOne: true, pages: [
        .init(scene: "🐜", text: "A little ant is looking for food."),
        .init(scene: "🐜🍪", text: "She finds a big biscuit near the door."),
        .init(scene: "🐜😓", text: "It is too heavy for one little ant."),
        .init(scene: "🐜🐜🐜", text: "Her friends come running to help."),
        .init(scene: "🐜🍪🏠", text: "Together, they carry it home. That is teamwork!"),
    ], questions: [
        .init(q: "What did the ant find?", answer: "a biscuit", wrong: ["an apple", "a leaf"]),
        .init(q: "Who helped the ant?", answer: "her friends", wrong: ["a bird", "a dog"]),
    ]),
    Story(id: "lion_mouse", title: "The Lion and the Mouse", cover: "🦁", classOne: true, pages: [
        .init(scene: "🦁😴🌳", text: "A big lion is sleeping under a tree."),
        .init(scene: "🐭🦁", text: "A little mouse runs over the lion's nose."),
        .init(scene: "🦁🐭", text: "The lion catches the mouse. Please let me go, says the mouse."),
        .init(scene: "🦁🕸️", text: "One day, the lion is caught in a net."),
        .init(scene: "🐭🕸️", text: "The little mouse cuts the net with his teeth."),
        .init(scene: "🦁🤝🐭", text: "Now the lion and the mouse are good friends."),
    ], questions: [
        .init(q: "Who helped the lion?", answer: "the mouse", wrong: ["the elephant", "the monkey"]),
        .init(q: "How did the mouse cut the net?", answer: "with his teeth", wrong: ["with a knife", "with a stone"]),
    ]),
    Story(id: "race", title: "The Tortoise and the Hare", cover: "🐢", classOne: true, pages: [
        .init(scene: "🐇🐢", text: "A hare and a tortoise have a race."),
        .init(scene: "🐇💨", text: "The hare runs very fast."),
        .init(scene: "🐇😴", text: "He thinks, I can sleep for a little while."),
        .init(scene: "🐢", text: "The tortoise walks slowly, but he does not stop."),
        .init(scene: "🐢🏁", text: "The tortoise wins the race! Slow and steady wins."),
    ], questions: [
        .init(q: "Who won the race?", answer: "the tortoise", wrong: ["the hare", "the dog"]),
        .init(q: "What did the hare do in the race?", answer: "he slept", wrong: ["he swam", "he sang"]),
    ]),
]

extension Story {
    /// Story questions as normal quiz questions (read aloud, so pre-readers can answer).
    func quizQuestions() -> [Question] {
        questions.map { sq in
            Question(skill: "story_time", prompt: sq.q, say: [.en(sq.q)],
                     options: ([sq.answer] + sq.wrong).shuffled().map { Option(id: $0, face: .text($0), spoken: .en($0)) },
                     answer: sq.answer, explain: "The answer is \(sq.answer).", readOptions: true)
        }
    }
}
