# Kingdom Progression and Combat MVP Specification

## Combat loop
1. The player enters the runner route with a starting squad.
2. Lane choice selects one of the visible army gates.
3. Gate rewards modify the squad count immediately.
4. Enemy raid and boss encounters compare current squad strength with encounter strength.
5. A successful encounter consumes the enemy strength from the squad; an insufficient squad loses the run.
6. Reaching the route end after surviving the boss awards a victory result.

## Current greybox encounter values
| Encounter | Distance marker | Strength |
|---|---:|---:|
| Raider group | 61 m | 4 |
| Warlord boss | 73 m | 6 |

These values are temporary tuning values for testing, not final balance.

## Kingdom progression target
The next hub milestone should add:
- Castle level and visual tier.
- Barracks: increases starting army.
- Archery Range: unlocks/strengthens ranged troops.
- Training Grounds: increases army durability or combat power.
- Resource Storage: raises the soft-cap for earned materials.

## Economy
- Gold: earned from completed runs and mission objectives.
- Materials: earned from boss victories and milestone rewards.
- Upgrades spend soft currency only during the MVP.
- No premium currency or real-money purchases in the prototype.

## Persistence requirements
Save locally:
- player gold and materials,
- castle and building levels,
- unlocked missions,
- best distance and completed mission count,
- audio and haptic preferences.

Use versioned save data and safe defaults when fields are missing. Do not treat a successful local save as cloud backup.

## Acceptance criteria
- Encounter resolution happens once per encounter.
- The player cannot continue moving after victory/defeat.
- Restart resets the route, gates, army and encounter state.
- A future kingdom hub must persist upgrades after app restart.
- All economy rewards are granted once per completed run.
