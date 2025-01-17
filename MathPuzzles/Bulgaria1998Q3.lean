import Mathlib.Algebra.Order.Archimedean
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Basic
import Mathlib.Analysis.SpecificLimits.Basic

/-
Bulgarian Mathematical Olympiad 1998, Problem 3

Let ℝ⁺ be the set of positive real numbers. Prove that there does not exist a function
f: ℝ⁺ → ℝ⁺ such that

                (f(x))² ≥ f(x + y) * (f(x) + y)

for every x,y ∈ ℝ⁺.

-/

open BigOperators

lemma geom_sum_bound (n : ℕ) : ∑ i in Finset.range n, (1:ℝ) / (2^i) < 3 :=
  calc ∑ i in Finset.range n, (1:ℝ) / ((2:ℝ)^i)
          = ∑ i in Finset.range n, ((1:ℝ) / 2)^i := by {congr; simp [div_eq_mul_inv]}
        _ ≤ 2 := sum_geometric_two_le n
        _ < 3 := by norm_num

theorem bulgaria1998_q3
    (f : ℝ → ℝ)
    (hpos : ∀ x : ℝ, 0 < x → 0 < f x)
    (hf : (∀ x y : ℝ, 0 < x → 0 < y → (f (x + y)) * (f x + y) ≤ (f x)^2)) :
    False := by
  have f_decr : ∀ x y : ℝ, 0 < x → 0 < y → f (x + y) < f x := by
    intros x y hx hy
    have h1 := hf x y hx hy
    have h2 : 0 < f x + y := add_pos (hpos x hx) hy
    have h4 : f x < f x + y := lt_add_of_pos_right (f x) hy
    have h5 : f x / (f x + y) < 1 := by rwa [div_lt_iff h2, one_mul]
    calc f (x + y)
         = f (x + y) * 1                       := (mul_one (f (x + y))).symm
       _ = f (x + y) * ((f x + y) / (f x + y)) := by rw[div_self (Ne.symm (ne_of_lt h2))]
       _ = (f (x + y) * (f x + y)) / (f x + y) := mul_div_assoc' _ _ _
       _ ≤ (f x)^2 / (f x + y)                 := (div_le_div_right h2).mpr h1
       _ = (f x) * (f x / (f x + y))           := by field_simp [pow_two]
       _ < f x                                 := (mul_lt_iff_lt_one_right (hpos x hx)).mpr h5

  have f_half : ∀ x : ℝ, 0 < x → f (x + f x) ≤ f x / 2 := by
    intros x hx
    have h0 := hpos x hx
    have h1 := hf x (f x) hx h0
    have h2 : 0 < f x + f x := add_pos h0 h0
    have h3 : 0 ≠ f x + f x := ne_of_lt h2
    have h6: 2 * f x ≠ 0 := by positivity
    have h7 : (f x / (2 * f x)) = 1 / 2 := by { rw [div_eq_iff h6]; ring }
    calc f (x + f x)
         = f (x + f x) * 1                   := (mul_one _).symm
       _ = f (x + f x) * ((f x + f x) / (f x + f x)) := by rw [div_self (Ne.symm h3)]
       _ = (f (x + f x) * (f x + f x)) / (f x + f x) := mul_div_assoc' _ _ _
       _ ≤ (f x)^2 / (f x + f x)                 := (div_le_div_right h2).mpr h1
       _ = (f x) * (f x / (f x + f x))           := by field_simp [pow_two]
       _ = (f x) * (f x / (2 * f x))             := by rw[two_mul]
       _ = f x / 2                               := by field_simp[h7]

  let x_seq : ℕ → ℝ := λ n : ℕ ↦ 1 + ∑ i in Finset.range n, (f 1) / (2^i)
  have hz : x_seq 0 = 1 := by simp only [add_right_eq_self, Finset.sum_empty, Finset.range_zero]
  have hf1 := hpos 1 zero_lt_one

  have x_seq_pos : ∀ n: ℕ, 0 < x_seq n := by
    intro n
    rw [show x_seq n = 1 + ∑ i in Finset.range n, (f 1) / (2^i) by rfl]
    have sum_nonneg : 0 ≤ ∑ i in Finset.range n, f 1 / 2 ^ i := by
      apply Finset.sum_nonneg
      intros i _
      have h2 : (0:ℝ) < 2 ^ i := pow_pos (by norm_num) i
      exact le_of_lt (div_pos_iff.mpr (Or.inl ⟨hf1, h2⟩))
    linarith

  have f_x_seq: ∀ n : ℕ, f (x_seq n) ≤ f 1 / 2^n := by
    intro n
    induction' n with pn hpn
    · rw[hz]; simp only [Nat.zero_eq, pow_zero, div_one, le_refl]
    have hpp : x_seq pn.succ = x_seq pn + f 1 / 2^pn := by
      rw [show x_seq _ = 1 + ∑ i in Finset.range _, (f 1) / (2^i) by rfl]
      have : ∑ i in Finset.range pn.succ, f 1 / 2 ^ i =
              f 1 / 2 ^ pn + ∑ i in Finset.range pn, f 1 / 2 ^ i :=
        Finset.sum_range_succ_comm (λ (x : ℕ) ↦ f 1 / 2 ^ x) pn
      rw [this]
      ring

    have h1 : f (x_seq pn.succ) ≤ f (x_seq pn + f (x_seq pn)) := by
     rw[hpp]
     obtain heq | hlt := eq_or_lt_of_le hpn
     · rw[heq]
     · have := le_of_lt (f_decr (x_seq pn + f (x_seq pn)) (f 1 / 2 ^ pn - f (x_seq pn))
                                (add_pos (x_seq_pos pn) (hpos (x_seq pn) (x_seq_pos pn)))
                                (sub_pos.mpr hlt))
       rw[add_add_sub_cancel] at this
       exact this

    calc f (x_seq pn.succ)
         ≤ f (x_seq pn + f (x_seq pn)) := h1
       _ ≤ f (x_seq pn) / 2 := f_half (x_seq pn) (x_seq_pos pn)
       _ ≤ (f 1 / 2 ^ pn) / 2 := (div_le_div_right two_pos).mpr hpn
       _ = f 1 / 2 ^ pn.succ := by {field_simp[ne_of_gt hf1]; rw[pow_succ]; ring_nf}

  have h1: ∀ n: ℕ, x_seq n < 1 + 3 * f 1 := by
    intro n
    norm_num
    calc ∑ i in Finset.range n, f 1 / (2:ℝ) ^ i
         = (∑ i in Finset.range n, 1 / (2:ℝ) ^ i) * f 1 := by {rw [Finset.sum_mul]; field_simp }
       _ < 3 * f 1 := (mul_lt_mul_right hf1).mpr (geom_sum_bound n)

  have h2 : ∀ n : ℕ, 0 < 1 + 3 * f 1 - x_seq n := by intro n; linarith [h1 n]

  have h3 : ∀ n : ℕ, f (1 + 3 * f 1) < f 1 / 2 ^ n := by
    intro n
    calc f (1 + 3 * f 1)
        = f (x_seq n + (1 + 3 * f 1 - x_seq n)) := by
             simp only [add_sub_add_left_eq_sub, add_add_sub_cancel]
      _ < f (x_seq n) := f_decr (x_seq n) _ (x_seq_pos n) (h2 n)
      _ ≤ f 1 / 2^n := f_x_seq n

  have he : ∃n : ℕ, f 1 / 2^n < f (1 + 3 * f 1) := by
    obtain ⟨N, hN⟩ := pow_unbounded_of_one_lt (f 1 / f (1 + 3 * f 1)) one_lt_two
    use N
    have hp : 0 < f (1 + 3 * f 1) :=
      hpos (1 + 3 * f 1) (lt_trans (x_seq_pos 0) (h1 0))

    have h2N : (0:ℝ) < 2^N := pow_pos (by norm_num) N
    exact (div_lt_iff h2N).mpr ((div_lt_iff' hp).mp hN)

  obtain ⟨N, hN⟩ := he
  exact lt_irrefl _ (lt_trans (h3 N) hN)
