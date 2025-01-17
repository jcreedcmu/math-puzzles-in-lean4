import Mathlib.Data.Nat.Basic
import Mathlib.Data.Nat.ModEq
import Mathlib.Data.Nat.Parity
import Mathlib.Algebra.GroupPower.Basic
import Mathlib.Algebra.Parity

import Mathlib.Tactic.LibrarySearch
import Mathlib.Tactic.ModCases
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Zify
/-
Bulgarian Mathematical Olympiad 1998, Problem 11

Let m,n be natural numbers such that

   A = ((m + 3)ⁿ + 1) / (3m)

is an integer. Prove that A is odd.
-/

namespace Bulgaria1998Q11

lemma mod_plus_pow (m n : ℕ) : (m + 3)^n % 3 = m^n % 3 := by
  induction' n with pn hpn
  · simp only [Nat.zero_eq, pow_zero, Nat.one_mod]
  · rw[pow_succ]
    have h1 : (m + 3) * (m + 3) ^ pn = m * (m + 3) ^ pn + 3 * (m + 3) ^ pn := by ring
    rw [h1]
    have h2 : 3 * (m + 3) ^ pn % 3 = 0 := Nat.mul_mod_right 3 _
    rw[Nat.add_mod, h2, add_zero, Nat.mod_mod, pow_succ]
    exact Nat.ModEq.mul rfl hpn

lemma foo1 (m n : ℕ) (ho : Odd m) : (m + 3) ^ n.succ % 2 = 0 := by
  cases' ho with w hw
  rw[hw, Nat.pow_succ, show 2 * w + 1 + 3 = 2 * (w + 2) by ring, Nat.mul_mod,
     Nat.mul_mod_right, mul_zero, Nat.zero_mod]

set_option maxHeartbeats 0
theorem bulgaria1998_q11
    (m n A : ℕ)
    (h : 3 * m * A = (m + 3)^n + 1) : Odd A := by
  -- First show that n must be positive.
  cases n with
  | zero => exfalso
            simp only [Nat.zero_eq, pow_zero] at h
            have h1 : (3 * m * A) % 3 = (1 + 1) % 3 := congrFun (congrArg HMod.hMod h) 3
            simp[Nat.mul_mod] at h1
  | succ n =>

  -- We prove by contradiction.
  -- Assume, on the contrary, that A is even.
  by_contra hno
  -- Then m is even.
  have hae : Even A := Iff.mpr Nat.even_iff_not_odd hno
  have hme : Even m := by
    cases' hae with k hk
    rw [hk, show k + k = 2 * k by ring] at h
    by_contra hmo
    rw[←Nat.odd_iff_not_even] at hmo
    have h1 : (3 * m * (2 * k)) % 2 = ((m + 3) ^ n.succ + 1) % 2 :=
      congrFun (congrArg HMod.hMod h) 2
    simp[Nat.mul_mod, Nat.add_mod, foo1 m n hmo] at h1

  -- Since A is an integer, 0 ≡ (m + 3)ⁿ + 1 ≡ mⁿ + 1 (mod 3)
  have h1 : 0 ≡ m ^ n.succ + 1 [MOD 3] := by
    calc 0 % 3
      = 3 * m * A % 3 := by rw[mul_assoc]; simp only [Nat.zero_mod, Nat.mul_mod_right]
    _ = ((m + 3) ^ n.succ + 1) % 3 := by rw[h];
    _ = (m ^ n.succ + 1) % 3 := Nat.ModEq.add_right _ (mod_plus_pow _ _)

  -- yields n = 2k + 1 and m = 3t + 2.
  have h2 := Nat.ModEq.add_right 2 h1
  rw[add_assoc, show 1 + 2 = 3 by rfl, zero_add] at h2
  have h5: 2 % 3 = (m ^ (Nat.succ n) + 3) % 3 := h2
  have h3 : m % 3 = 2 := by
    zify
    mod_cases hm : ↑m % 3
    · have h4: ↑m % 3 = (0:ℤ) % 3 := hm; norm_cast at h4
      simp[Nat.pow_mod, h4] at h5
    · have h4: ↑m % 3 = (1:ℤ) % 3 := hm; norm_cast at h4
      simp[Nat.pow_mod, h4] at h5
    · have h4: ↑m % 3 = (2:ℤ) % 3 := hm; norm_cast at h4

  have h6: Nat.succ n % 2 = 1 := by
    zify
    mod_cases hn : ↑(Nat.succ n) % 2
    · exfalso
      have h4: (↑(Nat.succ n)) % 2 = (0:ℤ) % 2 := hn
      norm_cast at h4
      have h9: Even (Nat.succ n) := Iff.mpr Nat.even_iff h4
      cases' h9 with k hk
      rw[hk] at h1
      have h1' : 0 % 3 = ( m ^ (k + k) + 1) % 3 := h1
      rw[Nat.add_mod, Nat.pow_mod, h3, ←Nat.two_mul, pow_mul, Nat.pow_mod,
         show 2 ^ 2 % 3 = 1 by rfl] at h1'
      simp at h1'
    · exact hn

  -- Let m = 2ˡm₁, where l ≥ 1 and m₁ is odd.
  -- In fact, l > 1, as otherwise m ≡ 2 (mod 4),
  --   (m + 3)ⁿ + 1 ≡ (2 + 3)ⁿ + 1 ≡ 2 (mod 4)
  -- and
  --   A = ((m + 3)ⁿ + 1) / (2m')
  -- is odd.
  -- ...
  sorry

