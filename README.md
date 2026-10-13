# StatLens

WoW: Forever addon that explains how your talents change your character stats.

MVP scope: Shaman (Enhancement tree), enUS client, Interface 16001 (beta build 1.60.1.70338).

## What it shows

- **Character panel** next to the character window: each stat with the talents that contribute to it, including chained effects (for example, Ancestral Knowledge raises Intellect, which Mental Dexterity turns into Attack Power).
- **Talent tooltips**: what the talent gives you now and what the next point would add, using your current stats.
- **Conditional talents** (Flurry, Maelstrom Weapon, Stormstrike, ...) are explained, not measured: they do not change the character sheet.

Values marked `*` use inferred per-rank numbers (only rank 1 and max rank were published). Verify them in game.

## Combat

WoW: Forever inherits Midnight's addon restrictions: in combat many values are secret. StatLens never computes on secret values; the panel freezes and dims in combat, and tooltips show `unavailable in combat`.

## How the math works

The client reports final totals, with talents already applied. StatLens inverts them:

- Percent talents: `base = total / (1 + p)`, contribution `= total - base`.
- Stat-from-stat talents: `ratio x source total`. The share coming from a percent talent on the source stat is shown as an `incl.` line.
- Flat talents (crit, dodge): the per-rank value.

Assumption: talent percentages multiply the buffed stat. If the client stacks them differently, numbers drift slightly.

## Commands

| Command | Effect |
| --- | --- |
| `/sl help` | List commands |
| `/sl talents` | Print detected talent ranks, missing and unmatched talents |
| `/sl panel` | Toggle the character panel |
| `/sl tooltip` | Toggle tooltip lines |
| `/sl debug` | Toggle debug output |

## Install (Linux / Wine)

```sh
ln -s ~/Projects/StatLens \
  "$HOME/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_classic_beta_/Interface/AddOns/StatLens"
```

## Development

```sh
lua5.1 tests/run.lua
```

Talent data lives in `Data/Shaman.lua`. Logic (`Calc.lua`, `Format.lua`) is pure and covered by tests; frames (`Panel.lua`, `Tooltip.lua`) are thin.

## In-game verification checklist

1. Addon loads with no Lua error (`/console scriptErrors 1`).
2. `/sl talents` lists your taken talents with correct ranks; `missing` and `unmatched` are empty.
3. Character window opens with the StatLens panel on its right.
4. Intellect: unequip or remove a buff and confirm the Ancestral Knowledge share changes as expected.
5. Mental Dexterity: Attack Power part equals the shown share of Intellect (confirms the rank-2 value if you are at 2/3).
6. Thundering Strikes: crit share matches ranks.
7. Hover a talent: `Now` and `Next point` lines appear once (not duplicated).
8. Spend a point: panel and tooltip refresh.
9. Enter combat: panel dims with `Frozen in combat`; leaving combat refreshes it.
