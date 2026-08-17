import Mathlib

namespace R003

/-- A row of the four free Boolean coordinates inside one mandatory class. -/
abbrev Word := Fin 4 → Bool

/-- Every one-coordinate binary interaction is represented. -/
def covers1 (s : Finset Word) : Bool :=
  (Finset.univ : Finset Word).all fun target =>
    (Finset.univ : Finset (Fin 4)).all fun i =>
      s.any fun w => w i == target i

/-- Every two-coordinate binary interaction on distinct coordinates is represented. -/
def covers2 (s : Finset Word) : Bool :=
  (Finset.univ : Finset Word).all fun target =>
    (Finset.univ : Finset (Fin 4)).all fun i =>
      (Finset.univ : Finset (Fin 4)).all fun j =>
        if i = j then true
        else s.any fun w => (w i == target i) && (w j == target j)

/-- Every three-coordinate binary interaction on distinct coordinates is represented. -/
def covers3 (s : Finset Word) : Bool :=
  (Finset.univ : Finset Word).all fun target =>
    (Finset.univ : Finset (Fin 4)).all fun i =>
      (Finset.univ : Finset (Fin 4)).all fun j =>
        (Finset.univ : Finset (Fin 4)).all fun k =>
          if i = j ∨ i = k ∨ j = k then true
          else
            s.any fun w =>
              (w i == target i) && (w j == target j) && (w k == target k)

/-- Every assignment on all four free Boolean coordinates is represented. -/
def covers4 (s : Finset Word) : Bool :=
  (Finset.univ : Finset Word).all fun target => decide (target ∈ s)

/-- There is no covering set of cardinality strictly below `n`. -/
def noSmallerCover (covers : Finset Word → Bool) (n : Nat) : Bool :=
  (Finset.range n).all fun k =>
    ((Finset.univ : Finset Word).powersetCard k).all fun s => ! covers s

/-- At least one covering set of cardinality exactly `n` exists. -/
def coverOfSizeExists (covers : Finset Word → Bool) (n : Nat) : Bool :=
  ((Finset.univ : Finset Word).powersetCard n).any covers

/-- Finite certificate that `n` is the exact covering minimum. -/
def exactMinimum (covers : Finset Word → Bool) (n : Nat) : Bool :=
  noSmallerCover covers n && coverOfSizeExists covers n

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Exact local minimum used by the global strength-2 lower bound. -/
theorem localOneWayMinimum : exactMinimum covers1 2 = true := by
  decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Exact local minimum used by the global strength-3 lower bound. -/
theorem localPairwiseMinimum : exactMinimum covers2 5 = true := by
  decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Exact local minimum used by the global strength-4 lower bound. -/
theorem localThreeWayMinimum : exactMinimum covers3 8 = true := by
  decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Exact local minimum used by the global strength-5/6 lower bounds. -/
theorem localFourWayMinimum : exactMinimum covers4 16 = true := by
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
