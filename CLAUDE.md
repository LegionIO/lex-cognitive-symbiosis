# lex-cognitive-symbiosis

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-symbiosis`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::CognitiveSymbiosis`

## Purpose

Models cognitive symbiosis — the interplay between cognitive subsystems as mutualistic, parasitic, or commensal bonds. Bonds between named subsystems strengthen when activated and decay over time. Ecosystem health is computed as the ratio of mutualistic to parasitic active bonds. This models how different cognitive processes (e.g., memory and emotion, focus and creativity) support or compete with each other.

## Gem Info

- **Gemspec**: `lex-cognitive-symbiosis.gemspec`
- **Require**: `lex-cognitive-symbiosis`
- **Ruby**: >= 3.4
- **License**: MIT
- **Homepage**: https://github.com/LegionIO/lex-cognitive-symbiosis

## File Structure

```
lib/legion/extensions/cognitive_symbiosis/
  version.rb
  helpers/
    constants.rb          # Relationship types, strength/health labels, bounds, decay rate
    symbiotic_bond.rb     # SymbioticBond class — one directional or bidirectional relationship
    symbiosis_engine.rb   # SymbiosisEngine — top-level coordinator
    ecosystem.rb          # Ecosystem class — bond registry and aggregate health metrics
  runners/
    cognitive_symbiosis.rb  # Runner module — public API (extend self)
  client.rb
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MAX_BONDS` | 200 | Hard cap on registered bonds (enforced in Ecosystem) |
| `BOND_DECAY` | 0.02 | Strength reduction per `decay!` call |
| `STRONG_THRESHOLD` | 0.6 | Strength >= this = strong bond |
| `DORMANT_THRESHOLD` | 0.05 | Strength <= this = dormant (excluded from health) |
| `DEFAULT_STRENGTH` | 0.3 | Starting strength for new bonds |

`RELATIONSHIP_TYPES`: `[:mutualistic, :parasitic, :commensal]`

Default benefit ratios (midpoint of each range):
- `:mutualistic` range `(0.1..1.0)` -> default ~0.55
- `:parasitic` range `(-1.0..-0.1)` -> default ~-0.55
- `:commensal` range `(-0.05..0.05)` -> default 0.0

Interaction strength labels: `0.0..0.2` = `:dormant`, `0.2..0.4` = `:weak`, `0.4..0.6` = `:moderate`, `0.6..0.8` = `:strong`, `0.8..1.0` = `:dominant`

Ecosystem health labels: `0.0..0.2` = `:critical`, `0.2..0.4` = `:stressed`, `0.4..0.6` = `:balanced`, `0.6..0.8` = `:thriving`, `0.8..1.0` = `:flourishing`

## Key Classes

### `Helpers::SymbioticBond`

A bond between two named subsystems (`subsystem_a`, `subsystem_b`) with a type, strength, and benefit ratio.

- `activate!(amount: 0.05)` — increases strength, increments `activation_count`, sets `last_activated_at`
- `decay!(rate:)` — reduces strength by `BOND_DECAY` (or provided rate)
- `dormant?` — strength <= `DORMANT_THRESHOLD`
- `strong?` — strength >= `STRONG_THRESHOLD`
- `strength_label` — one of the `INTERACTION_STRENGTHS` labels
- `involves?(subsystem_id)` — true if either end of the bond
- `partner_of(subsystem_id)` — returns the other end of the bond

Invalid `relationship_type` raises `ArgumentError`. Bond ID is a UUID string.

### `Helpers::Ecosystem`

Registry and health analytics for all bonds.

- `register_bond(bond)` — adds bond; raises if at `MAX_BONDS`
- `activate_bond(bond_id, amount:)` — delegates to bond's `activate!`
- `measure_health` — `mutualistic_ratio - parasitic_penalty(0.5x)`; range `[0.0, 1.0]`
- `health_label` — from `ECOSYSTEM_HEALTH_LABELS`
- `most_beneficial` — mutualistic bond with highest `benefit_ratio * strength`
- `most_parasitic` — parasitic bond with lowest `benefit_ratio * strength`
- `decay_all!` — calls `decay!` on every bond; returns count
- `network_density` — mean strength of active bonds
- `symbiotic_web(subsystem_id)` — all bonds involving a given subsystem
- `find_bond(a, b)` — bidirectional lookup (order-independent)
- `active_bonds` — bonds not dormant

### `Helpers::SymbiosisEngine`

Thin coordinator wrapping `Ecosystem`.

- `create_bond(...)` — checks for existing bond first; returns `{ created: false, reason: :already_exists }` if duplicate
- `activate_interaction(subsystem_a:, subsystem_b:, amount:)` — finds bond by subsystem pair, delegates
- `measure_ecosystem_health` — delegates + adds density and counts
- `find_partners(subsystem_id, min_benefit_ratio:)` — non-dormant bonds involving the subsystem, filtered by benefit ratio, sorted by strength descending
- `detect_parasites(strength_threshold:)` — active parasitic bonds above threshold, sorted by `benefit_ratio` ascending
- `ecosystem_report` — full report with health, bonds by type, most beneficial/parasitic, dormant count
- `decay_all` — delegates to ecosystem

## Runners

Module: `Legion::Extensions::CognitiveSymbiosis::Runners::CognitiveSymbiosis` (uses `extend self`)

| Runner | Key Args | Returns |
|---|---|---|
| `create_bond` | `subsystem_a:`, `subsystem_b:`, `relationship_type:`, `strength:`, `benefit_ratio:` | `{ success:, created:, bond: }` |
| `activate` | `subsystem_a:`, `subsystem_b:`, `amount:` | `{ success:, found:, bond_id:, strength:, activation_count: }` |
| `health_status` | — | `{ success:, score:, label:, bond_count:, active_bonds:, network_density: }` |
| `list_bonds` | `subsystem_id:`, `relationship_type:` (both optional) | `{ success:, bonds:, count: }` |
| `detect_parasites` | `strength_threshold:` | `{ success:, parasites:, count: }` |
| `ecosystem_report` | — | full report with health, bonds by type, most beneficial/parasitic |

All runners accept optional `engine:` keyword. The runner module uses `extend self`, so all methods are available at both module and instance level.

## Integration Points

- No actors defined; decay must be triggered externally (e.g., via `lex-tick` or a scheduler)
- Subsystem identifiers are caller-defined strings or symbols representing cognitive subsystems
- Can model interdependencies between extensions: e.g., bonds between `:memory` and `:emotion`, or `:focus` and `:creativity`
- `detect_parasites` is useful for identifying cognitive load drains to address via `lex-conflict` or `lex-tick` gating
- All state is in-memory per `SymbiosisEngine` instance

## Development Notes

- `find_bond` is bidirectional — order of `subsystem_a` and `subsystem_b` does not matter for lookup
- `extend self` on the runner means the module itself is also an object; runners work without a Client wrapper
- `ecosystem_report` calls `measure_ecosystem_health` twice (once directly, once via `SymbiosisEngine`)
- `decay_all` applies to ALL bonds including dormant ones (dormancy is a result of decay, not a prerequisite to skip it)
- Health formula: `mutualistic_count / total_active - (parasitic_count / total_active) * 0.5`; commensal bonds contribute neither benefit nor penalty
