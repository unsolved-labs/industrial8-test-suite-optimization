import Mathlib.Data.Nat.Bitwise
import Mathlib.Algebra.Order.BigOperators.Group.Finset

namespace R003

/-- The coordinate sets whose local interactions of arity `r` must be covered. -/
def coordSets : Nat → List (List Nat)
  | 1 => [[0], [1], [2], [3]]
  | 2 => [[0,1], [0,2], [0,3], [1,2], [1,3], [2,3]]
  | 3 => [[0,1,2], [0,1,3], [0,2,3], [1,2,3]]
  | 4 => [[0,1,2,3]]
  | _ => []

/-- Whether two encoded four-bit words agree on every coordinate in `coords`. -/
def agreesOn (word target : Nat) (coords : List Nat) : Bool :=
  coords.all fun c => word.testBit c == target.testBit c

/-- Whether the listed local rows cover every interaction of arity `r`. -/
def coversWords (r : Nat) (words : List Nat) : Bool :=
  (List.range 16).all fun target =>
    (coordSets r).all fun coords =>
      words.any fun word => agreesOn word target coords

/-- Exhaustive certificate that no four distinct local rows cover all binary pairs. -/
def noFourDistinctRowsCoverPairs : Bool :=
  (List.range 16).all fun a =>
    (List.range 16).all fun b =>
      (List.range 16).all fun c =>
        (List.range 16).all fun d =>
          if a < b ∧ b < c ∧ c < d then !(coversWords 2 [a,b,c,d]) else true

/-- The five-row pairwise covering array used by the R003 construction. -/
def pairwiseWitness : List Nat := [0, 7, 11, 13, 14]

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Kernel-checked finite obstruction underlying the strength-3 local lower bound. -/
theorem pairwiseFourRowObstruction : noFourDistinctRowsCoverPairs = true := by
  decide

/-- Kernel-checked explicit five-row local pairwise witness. -/
theorem pairwiseFiveRowWitness : coversWords 2 pairwiseWitness = true := by
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
