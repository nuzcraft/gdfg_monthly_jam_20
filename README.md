# Game Dev Field Guide Monthly Jam #20

Potential submission for Game Dev Field Guide Monthly Jam

Theme: Interruption
Modifier: Storytelling

Rainy Hearts font by Camellina

## Overview and self-restrictions

I'm still new to game dev. This jam is a month long, and I will likely procrastinate. I'm also planning on participating in the Vim Jam this month, so making 2 small games in one month will be a big task for me.  
I'm going to use Godot. I'm still learning it, and I need the practice.  
I'm going to use my own art. This will make it difficult, but I'm looking forward to the challenge.  
I want this to be more like a 6 hour game.
The idea here is that scoping a 6 hour game will likely end up taking 12 hours, especially if I'm doing my own art.
I'm only going to be able to dev 1-2 hours a day when I have time, 6-12 hours is 6-12 days of dev for me :)

## Basic Gameplay Ideas

1. platformer/metroidvania w/ collectibles
2. platformer on slopes with rolling barrels
3. platformer where you have to hop to the top
4. top down puzzle game
5. top down dungeon crawler
6. top down shmupy thing

## Theme Ideas

1. Grandpa is reading a story and gets interrupted with questions
2. Gameplay gets interrupted with powerups
3. Boss keeps stopping you mid-attack
4. **Oops, all parries (aka interrupting their attacks)**

# Oops, all parries

What kinds of games have parry systems?

- **some 2d platformers w/ weapons (blasphemous)**
- 3rd person soulslikes
- top down dungeon crawly things
- infinity blade
- fencing/swordplay games
- gladiator/arena/bossfight games

I'm learning platformer controls and such w/ godot, so in an effort to keep scope down, I will pursue this option.

## Needs/Requirments

- [ ] small art style, 8x8 or 12x12
  - restricted to a small palette, currently dawnbringer 8
- [ ] player can jump, probably double jump
- [ ] player can attack
- [ ] one enemy
  - [ ] enemy always parries player attacks
  - [ ] if timed correctly, player parries enemy attacks
- [ ] a story

## Expanded TODO list

### Player Controller

- [x] #2 double jump - with ability to remove/add additional air jumps
- [x] #3 jump buffer - player can press jump before hitting the ground and still jump
- [x] #5 coyote time - player can press jump after running off a ledge and still jump
- [x] #1 horizontal flip for sprite
- [x] #4 running animation - dragging the cane
- [x] #6 particles from dragging the cane in run animation
- [x] #7 jumping animation
- [x] #8 double jump animation (spinning?)
- [x] #9 falling animation
- [x] #10 particles on jump
- [x] player flash on hit
- [x] player knockback on hit
- [x] player invulnerable for a bit on hit
- [x] #14 enemy attacks
- [x] #15 enemy flash before attack
- [x] #16 player parry enemy attack
- [x] #17 successful parry zooms in
- [x] #18 successful parry slows time
- [x] player can parry in direction they are facing

### Enemy

- [x] enemy design
- [x] enemy attack animation
- [x] enemy can pursue player
- [x] enemy can choose when to attack
- [x] enemy can attack the direction of the player

### I'm tired, what can we do to finish this quick?

- [x] player parry attack has new animation
- [x] player parry attack damages enemy (destroys it?)
- [x] player has health points and loses them when he gets hit
- [x] player death
- [x] player gets score when enemies die
- [x] health points and score shown on screen
- [x] new enemies spawn in at accellerating pace
- [x] title screen
- [x] end screen
- [x] sound effects
- [ ] music
- [ ] controls popup when in parry mode
- [ ] new icon
- [ ] windows and html5 builds
- [ ] screen shake
