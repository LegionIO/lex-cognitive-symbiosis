# lex-cognitive-symbiosis

A LegionIO cognitive architecture extension that models the interdependencies between cognitive subsystems as symbiotic bonds. Bonds can be mutualistic (both benefit), parasitic (one drains the other), or commensal (one benefits, the other is unaffected). Ecosystem health reflects the balance of these relationships.

## What It Does

Tracks a network of **bonds** between named cognitive subsystems. Each bond has:

- A relationship type (`:mutualistic`, `:parasitic`, or `:commensal`)
- A strength (0.0 to 1.0) that grows when activated and decays over time
- A benefit ratio (positive for mutualism, negative for parasitism)

Ecosystem health is computed from the ratio of mutualistic to parasitic active bonds.

## Usage

```ruby
require 'lex-cognitive-symbiosis'

client = Legion::Extensions::CognitiveSymbiosis::Client.new

# Create a mutualistic bond between memory and emotion
client.create_bond(subsystem_a: :memory, subsystem_b: :emotion, relationship_type: :mutualistic)
# => { success: true, created: true, bond: { bond_id: "uuid...", strength: 0.3, strength_label: :weak, ... } }

# Create a parasitic bond (anxiety draining focus)
client.create_bond(subsystem_a: :anxiety, subsystem_b: :focus, relationship_type: :parasitic, strength: 0.5)
# => { success: true, created: true, bond: { bond_id: "uuid...", relationship_type: :parasitic, ... } }

# Activate an interaction — increases bond strength
client.activate(subsystem_a: :memory, subsystem_b: :emotion, amount: 0.1)
# => { success: true, found: true, bond_id: "uuid...", strength: 0.4, activation_count: 1 }

# Check ecosystem health
client.health_status
# => { success: true, score: 0.33, label: :stressed, bond_count: 2, active_bonds: 2, network_density: 0.45 }

# List all bonds for a given subsystem
client.list_bonds(subsystem_id: :memory)
# => { success: true, bonds: [...], count: 1 }

# List bonds by type
client.list_bonds(relationship_type: :parasitic)
# => { success: true, bonds: [...], count: 1 }

# Find active parasites
client.detect_parasites(strength_threshold: 0.3)
# => { success: true, parasites: [...], count: 1 }

# Full ecosystem report
client.ecosystem_report
# => { success: true, health: {...}, bonds_by_type: { mutualistic: 1, parasitic: 1, commensal: 0 }, ... }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
