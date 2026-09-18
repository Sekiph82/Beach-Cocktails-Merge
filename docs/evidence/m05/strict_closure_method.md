# M05 Strict Closure Evidence Method

This evidence set is generated in two explicit phases.

1. `tools/m05_strict_closure_evidence.py` reads only the canonical `assets/cocktails/L01.png` through `L12.png` files. Before any production comparison, it hashes each PNG, records dimensions, applies an independently selected visual review window for the glass/container, and deterministically extracts alpha-positive body bounds with threshold 32. The review windows were selected from the artwork itself to exclude visible garnish and straw regions; they are not copied from production measurement constants or production hulls. Each record includes the body bounds, width/height, center offset, pixel count, transparency/garnish exclusion method, ambiguity note, and shape rationale.
2. `tools/m05_strict_closure_compare.py` runs only after the independent JSON exists. It then reads current production values for comparison, computes material differences and collider/body ratios, checks the protected symbols byte-for-byte against the R11 baseline commit, and generates the representative contact overlay.

Shape review follows the canonical artwork: L04/L06 are martini/coupe, L03/L07/L11 are highballs, L05/L08/L10 are rounded goblets, L09 is coconut, and L12 is pineapple. L01/L02 are short tumblers.

The red rectangle in `strict_closure_contact_overlays.png` is the independently measured body bound after the current production visual transform. The blue circle is the unchanged runtime collider. The yellow cross marks the independently measured body center.

The generator does not import `scripts/drink.gd`, read production constants, or call production helpers before writing the independent dataset.
