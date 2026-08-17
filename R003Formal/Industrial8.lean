import Mathlib

namespace R003

abbrev Bit := Fin 2
abbrev Col := Fin 4
abbrev Row := Col → Bit

/-- Every ordered pair of distinct columns realizes every binary value pair. -/
def PairwiseCovers {n : Nat} (suite : Fin n → Row) : Prop :=
  ∀ c₁ c₂ : Col, c₁ ≠ c₂ → ∀ a b : Bit,
    ∃ r : Fin n, suite r c₁ = a ∧ suite r c₂ = b

/-- `PairwiseCovers` is a computable finite proposition for every finite suite. -/
instance pairwiseCoversDecidable {n : Nat} (suite : Fin n → Row) :
    Decidable (PairwiseCovers suite) := by
  unfold PairwiseCovers
  infer_instance

/-- The five-row block used in each mandatory class of the strength-3 construction. -/
def baseFive : Fin 5 → Row :=
  ![
    ![0, 0, 0, 0],
    ![0, 1, 1, 1],
    ![1, 0, 1, 1],
    ![1, 1, 0, 1],
    ![1, 1, 1, 0]
  ]

/-- Four rows cannot pairwise cover four binary columns. -/
theorem noFourRowPairwiseCover :
    ∀ suite : Fin 4 → Row, ¬ PairwiseCovers suite := by
  decide

/-- The explicit five-row block does pairwise cover four binary columns. -/
theorem baseFivePairwiseCovers : PairwiseCovers baseFive := by
  decide

#print axioms noFourRowPairwiseCover
#print axioms baseFivePairwiseCovers

end R003
