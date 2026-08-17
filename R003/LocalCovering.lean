import Mathlib

namespace R003

/-- A local row is one of the 16 four-bit assignments, encoded by a natural number 0..15. -/
abbrev WordCode := Nat

/-- A local test suite is encoded by a 16-bit membership mask. -/
abbrev SuiteMask := Nat

/-- The four coordinate sets whose interactions of arity `r` must be covered. -/
def coordSets : Nat → List (List Nat)
  | 1 => [[0], [1], [2], [3]]
  | 2 => [[0,1], [0,2], [0,3], [1,2], [1,3], [2,3]]
  | 3 => [[0,1,2], [0,1,3], [0,2,3], [1,2,3]]
  | 4 => [[0,1,2,3]]
  | _ => []

/-- Whether a local row is selected by the suite mask. -/
def selected (mask : SuiteMask) (word : WordCode) : Bool :=
  mask.testBit word

/-- Number of selected local rows among the 16 possible four-bit assignments. -/
def selectedCount (mask : SuiteMask) : Nat :=
  (List.range 16).foldl (fun acc word => if selected mask word then acc + 1 else acc) 0

/-- Whether two encoded four-bit words agree on every coordinate in `coords`. -/
def agreesOn (word target : WordCode) (coords : List Nat) : Bool :=
  coords.all fun c => word.testBit c == target.testBit c

/-- Exact finite local coverage predicate for interactions of arity `r`. -/
def covers (r : Nat) (mask : SuiteMask) : Bool :=
  (List.range 16).all fun target =>
    (coordSets r).all fun coords =>
      (List.range 16).any fun word => selected mask word && agreesOn word target coords

/-- Kernel-checkable exhaustive certificate: no suite of cardinality `< n` covers all local interactions. -/
def noSmallerCover (r n : Nat) : Bool :=
  (List.range 65536).all fun mask =>
    if selectedCount mask < n then !(covers r mask) else true

/-- Kernel-checkable explicit witness certificate at cardinality exactly `n`. -/
def witnessCheck (r n : Nat) (mask : SuiteMask) : Bool :=
  selectedCount mask == n && covers r mask

/-- Combined exact-minimum certificate for a given explicit witness mask. -/
def exactMinimumCheck (r n : Nat) (witness : SuiteMask) : Bool :=
  noSmallerCover r n && witnessCheck r n witness

/-- Two complementary rows, 0000 and 1111. -/
def oneWayWitness : SuiteMask := 32769

/-- Five-row pairwise witness {0000,0111,1011,1101,1110}. -/
def pairwiseWitness : SuiteMask := 26753

/-- Eight even-parity rows. -/
def threeWayWitness : SuiteMask := 38505

/-- All sixteen rows. -/
def fourWayWitness : SuiteMask := 65535

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Exact local minimum used by the global strength-2 lower bound. -/
theorem localOneWayMinimum : exactMinimumCheck 1 2 oneWayWitness = true := by
  decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Exact local minimum used by the global strength-3 lower bound. -/
theorem localPairwiseMinimum : exactMinimumCheck 2 5 pairwiseWitness = true := by
  decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Exact local minimum used by the global strength-4 lower bound. -/
theorem localThreeWayMinimum : exactMinimumCheck 3 8 threeWayWitness = true := by
  decide

set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
/-- Exact local minimum used by the global strength-5/6 lower bounds. -/
theorem localFourWayMinimum : exactMinimumCheck 4 16 fourWayWitness = true := by
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
