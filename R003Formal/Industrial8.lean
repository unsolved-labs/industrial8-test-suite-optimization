import Mathlib

namespace R003

abbrev Bit := Bool
abbrev Col := Fin 4
abbrev Row := Col → Bit

/-- Every ordered pair of distinct columns realizes every binary value pair. -/
def PairwiseCovers {n : Nat} (suite : Fin n → Row) : Prop :=
  ∀ c₁ c₂ : Col, c₁ ≠ c₂ → ∀ a b : Bit,
    ∃ r : Fin n, suite r c₁ = a ∧ suite r c₂ = b

/-- `PairwiseCovers` is decidable for every finite suite. -/
instance pairwiseCoversDecidable {n : Nat} (suite : Fin n → Row) :
    Decidable (PairwiseCovers suite) := by
  unfold PairwiseCovers
  infer_instance

/-- The row-to-pair map associated with two columns. -/
def pairMap {n : Nat} (suite : Fin n → Row) (c₁ c₂ : Col) :
    Fin n → Bit × Bit := fun r => (suite r c₁, suite r c₂)

lemma pairMap_surjective {n : Nat} {suite : Fin n → Row}
    (h : PairwiseCovers suite) {c₁ c₂ : Col} (hne : c₁ ≠ c₂) :
    Function.Surjective (pairMap suite c₁ c₂) := by
  rintro ⟨a, b⟩
  rcases h c₁ c₂ hne a b with ⟨r, hra, hrb⟩
  exact ⟨r, by simp [pairMap, hra, hrb]⟩

/-- With four rows, pairwise coverage on a pair of columns makes the pair map bijective. -/
lemma pairMap_injective_four {suite : Fin 4 → Row}
    (h : PairwiseCovers suite) {c₁ c₂ : Col} (hne : c₁ ≠ c₂) :
    Function.Injective (pairMap suite c₁ c₂) := by
  have hs : Function.Surjective (pairMap suite c₁ c₂) :=
    pairMap_surjective h hne
  exact ((Fintype.bijective_iff_surjective_and_card (pairMap suite c₁ c₂)).2
    ⟨hs, by decide⟩).1

lemma bool_eq_of_ne_same {a b c : Bool} (hab : a ≠ b) (hac : a ≠ c) : b = c := by
  cases a <;> cases b <;> cases c <;> simp_all

/-- The five-row block used in each mandatory class of the strength-3 construction. -/
def baseFive : Fin 5 → Row :=
  ![
    ![false, false, false, false],
    ![false, true,  true,  true ],
    ![true,  false, true,  true ],
    ![true,  true,  false, true ],
    ![true,  true,  true,  false]
  ]

/-- Four rows cannot pairwise cover four binary columns. -/
theorem noFourRowPairwiseCover :
    ∀ suite : Fin 4 → Row, ¬ PairwiseCovers suite := by
  intro suite h

  have inj02 := pairMap_injective_four h (c₁ := 0) (c₂ := 2) (by decide)
  have inj12 := pairMap_injective_four h (c₁ := 1) (c₂ := 2) (by decide)
  have inj03 := pairMap_injective_four h (c₁ := 0) (c₂ := 3) (by decide)
  have inj13 := pairMap_injective_four h (c₁ := 1) (c₂ := 3) (by decide)
  have inj23 := pairMap_injective_four h (c₁ := 2) (c₂ := 3) (by decide)

  rcases h 0 1 (by decide) false false with ⟨r00, hr00_0, hr00_1⟩
  rcases h 0 1 (by decide) false true  with ⟨r01, hr01_0, hr01_1⟩
  rcases h 0 1 (by decide) true  false with ⟨r10, hr10_0, hr10_1⟩
  rcases h 0 1 (by decide) true  true  with ⟨r11, hr11_0, hr11_1⟩

  have r00_ne_r01 : r00 ≠ r01 := by
    intro e
    subst r01
    simp_all
  have r00_ne_r10 : r00 ≠ r10 := by
    intro e
    subst r10
    simp_all
  have r00_ne_r11 : r00 ≠ r11 := by
    intro e
    subst r11
    simp_all
  have r10_ne_r11 : r10 ≠ r11 := by
    intro e
    subst r11
    simp_all

  have h2_00_ne_01 : suite r00 2 ≠ suite r01 2 := by
    intro heq
    apply r00_ne_r01
    apply inj02
    simp [pairMap, hr00_0, hr01_0, heq]
  have h2_00_ne_10 : suite r00 2 ≠ suite r10 2 := by
    intro heq
    apply r00_ne_r10
    apply inj12
    simp [pairMap, hr00_1, hr10_1, heq]
  have h2_10_ne_11 : suite r10 2 ≠ suite r11 2 := by
    intro heq
    apply r10_ne_r11
    apply inj02
    simp [pairMap, hr10_0, hr11_0, heq]
  have h2_11_eq_00 : suite r11 2 = suite r00 2 :=
    bool_eq_of_ne_same h2_10_ne_11 h2_00_ne_10.symm

  have h3_00_ne_01 : suite r00 3 ≠ suite r01 3 := by
    intro heq
    apply r00_ne_r01
    apply inj03
    simp [pairMap, hr00_0, hr01_0, heq]
  have h3_00_ne_10 : suite r00 3 ≠ suite r10 3 := by
    intro heq
    apply r00_ne_r10
    apply inj13
    simp [pairMap, hr00_1, hr10_1, heq]
  have h3_10_ne_11 : suite r10 3 ≠ suite r11 3 := by
    intro heq
    apply r10_ne_r11
    apply inj03
    simp [pairMap, hr10_0, hr11_0, heq]
  have h3_11_eq_00 : suite r11 3 = suite r00 3 :=
    bool_eq_of_ne_same h3_10_ne_11 h3_00_ne_10.symm

  apply r00_ne_r11
  apply inj23
  simp [pairMap, h2_11_eq_00, h3_11_eq_00]

/-- The explicit five-row block does pairwise cover four binary columns. -/
theorem baseFivePairwiseCovers : PairwiseCovers baseFive := by
  decide

#print axioms noFourRowPairwiseCover
#print axioms baseFivePairwiseCovers

end R003
