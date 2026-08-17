import Mathlib

namespace R003

/-- A row of the four free Boolean coordinates inside one mandatory class. -/
abbrev Word := Fin 4 → Bool

/-- A candidate local test suite, represented as a Boolean selection of the 16 possible rows. -/
abbrev Selection := Word → Bool

/-- Number of selected rows. -/
def selectionCard (s : Selection) : Nat :=
  ∑ w : Word, if s w then 1 else 0

/-- Every one-coordinate binary interaction is represented. -/
def Covers1 (s : Selection) : Prop :=
  ∀ target : Word, ∀ i : Fin 4,
    ∃ w : Word, s w = true ∧ w i = target i

/-- Every two-coordinate binary interaction on distinct coordinates is represented. -/
def Covers2 (s : Selection) : Prop :=
  ∀ target : Word, ∀ i j : Fin 4, i ≠ j →
    ∃ w : Word, s w = true ∧ w i = target i ∧ w j = target j

/-- Every three-coordinate binary interaction on distinct coordinates is represented. -/
def Covers3 (s : Selection) : Prop :=
  ∀ target : Word, ∀ i j k : Fin 4,
    i ≠ j → i ≠ k → j ≠ k →
      ∃ w : Word,
        s w = true ∧ w i = target i ∧ w j = target j ∧ w k = target k

/-- Every assignment on all four free Boolean coordinates is represented. -/
def Covers4 (s : Selection) : Prop :=
  ∀ target : Word, s target = true

instance covers1Decidable (s : Selection) : Decidable (Covers1 s) := by
  unfold Covers1
  infer_instance

instance covers2Decidable (s : Selection) : Decidable (Covers2 s) := by
  unfold Covers2
  infer_instance

instance covers3Decidable (s : Selection) : Decidable (Covers3 s) := by
  unfold Covers3
  infer_instance

instance covers4Decidable (s : Selection) : Decidable (Covers4 s) := by
  unfold Covers4
  infer_instance

/-- `n` is the exact minimum size among all local selections satisfying `covers`. -/
def ExactMinimum (covers : Selection → Prop)
    [∀ s, Decidable (covers s)] (n : Nat) : Prop :=
  (∀ s : Selection, covers s → n ≤ selectionCard s) ∧
  (∃ s : Selection, selectionCard s = n ∧ covers s)

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Exact local minimum used by the global strength-2 lower bound. -/
theorem localOneWayMinimum : ExactMinimum Covers1 2 := by
  decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Exact local minimum used by the global strength-3 lower bound. -/
theorem localPairwiseMinimum : ExactMinimum Covers2 5 := by
  decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Exact local minimum used by the global strength-4 lower bound. -/
theorem localThreeWayMinimum : ExactMinimum Covers3 8 := by
  decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Exact local minimum used by the global strength-5/6 lower bounds. -/
theorem localFourWayMinimum : ExactMinimum Covers4 16 := by
  decide

/-- If nine disjoint classes each contribute at least `m` rows, their total contributes at least `9*m`. -/
theorem nineClassSumLower (m : Nat) (count : Fin 9 → Nat)
    (h : ∀ i, m ≤ count i) : 9 * m ≤ ∑ i, count i := by
  calc
    9 * m = ∑ _i : Fin 9, m := by simp [Nat.mul_comm]
    _ ≤ ∑ i : Fin 9, count i := by
      exact Finset.sum_le_sum fun i _hi => h i

/-- Arithmetic specialization for the strength-2 lower bound. -/
theorem nineClassesStrength2 (count : Fin 9 → Nat)
    (h : ∀ i, 2 ≤ count i) : 18 ≤ ∑ i, count i := by
  simpa using nineClassSumLower 2 count h

/-- Arithmetic specialization for the strength-3 lower bound. -/
theorem nineClassesStrength3 (count : Fin 9 → Nat)
    (h : ∀ i, 5 ≤ count i) : 45 ≤ ∑ i, count i := by
  simpa using nineClassSumLower 5 count h

/-- Arithmetic specialization for the strength-4 lower bound. -/
theorem nineClassesStrength4 (count : Fin 9 → Nat)
    (h : ∀ i, 8 ≤ count i) : 72 ≤ ∑ i, count i := by
  simpa using nineClassSumLower 8 count h

/-- Arithmetic specialization for the strength-5 and strength-6 lower bounds. -/
theorem nineClassesStrength5or6 (count : Fin 9 → Nat)
    (h : ∀ i, 16 ≤ count i) : 144 ≤ ∑ i, count i := by
  simpa using nineClassSumLower 16 count h

end R003
