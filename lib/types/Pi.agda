{-# OPTIONS --without-K #-}

open import lib.Basics
open import lib.types.Paths

module lib.types.Pi where

Π-level : ∀ {i j} {A : Type i} {B : A → Type j} {n : ℕ₋₂}
  → (((x : A) → has-level n (B x)) → has-level n (Π A B))
Π-level {n = ⟨-2⟩} p =
  ((λ x → fst (p x)) , (λ f → λ= (λ x → snd (p x) (f x))))
Π-level {n = S n} p = λ f g →
  equiv-preserves-level λ=-equiv
    (Π-level (λ x → p x (f x) (g x)))

module _ {i j} {A : Type i} {B : A → Type j} where
  abstract
    Π-is-prop : ((x : A) → is-prop (B x)) → is-prop (Π A B)
    Π-is-prop = Π-level

    Π-is-set : ((x : A) → is-set (B x)) → is-set (Π A B)
    Π-is-set = Π-level

module _ {i j} {A : Type i} {B : Type j} where
  abstract
    →-level : {n : ℕ₋₂} → (has-level n B → has-level n (A → B))
    →-level p = Π-level (λ _ → p)

    →-is-set : is-set B → is-set (A → B)
    →-is-set = →-level

    →-is-prop : is-prop B → is-prop (A → B)
    →-is-prop = →-level

-- Equivalences in a Π-type
equiv-Π-r : ∀ {i j k} {A : Type i} {B : A → Type j} {C : A → Type k}
  → (∀ x → B x ≃ C x) → Π A B ≃ Π A C
equiv-Π-r {A = A} {B = B} {C = C} k = equiv f g f-g g-f
  where f : Π A B → Π A C
        f c x = –> (k x) (c x)

        g : Π A C → Π A B
        g d x = <– (k x) (d x)

        f-g : ∀ d → f (g d) == d
        f-g d = λ= (λ x →  <–-inv-r (k x) (d x)) 

        g-f : ∀ c → g (f c) == c
        g-f c = λ= (λ x → <–-inv-l (k x) (c x))

-- Dependent paths in a Π-type
module _ {i j k} {A : Type i} {B : A → Type j} {C : (a : A) → B a → Type k}
  where

  ↓-Π-in : {x x' : A} {p : x == x'} {u : Π (B x) (C x)} {u' : Π (B x') (C x')}
    → ({t : B x} {t' : B x'} (q : t == t' [ B ↓ p ])
        → u t == u' t' [ uncurry C ↓ pair= p q ])
    → (u == u' [ (λ x → Π (B x) (C x)) ↓ p ])
  ↓-Π-in {p = idp} f = λ= (λ x → f (idp {a = x}))

  ↓-Π-out : {x x' : A} {p : x == x'} {u : Π (B x) (C x)} {u' : Π (B x') (C x')}
    → (u == u' [ (λ x → Π (B x) (C x)) ↓ p ])
    → ({t : B x} {t' : B x'} (q : t == t' [ B ↓ p ])
        → u t == u' t' [ uncurry C ↓ pair= p q ])
  ↓-Π-out {p = idp} q idp = app= q _

  ↓-Π-β : {x x' : A} {p : x == x'} {u : Π (B x) (C x)} {u' : Π (B x') (C x')}
    → (f : {t : B x} {t' : B x'} (q : t == t' [ B ↓ p ])
            → u t == u' t' [ uncurry C ↓ pair= p q ])
    → {t : B x} {t' : B x'} (q : t == t' [ B ↓ p ])
    → ↓-Π-out (↓-Π-in f) q == f q
  ↓-Π-β {p = idp} f idp = app=-β (λ x → f (idp {a = x})) _

-- Dependent paths in a Π-type where the codomain is not dependent on anything
module _ {i j k} {A : Type i} {B : A → Type j} {C : Type k} {x x' : A}
  {p : x == x'} {u : B x → C} {u' : B x' → C} where

  ↓-app→cst-in :
    ({t : B x} {t' : B x'} (q : t == t' [ B ↓ p ])
      → u t == u' t')
    → (u == u' [ (λ x → B x → C) ↓ p ])
  ↓-app→cst-in f = ↓-Π-in (λ q → ↓-cst-in (f q))

  ↓-app→cst-out :
    (u == u' [ (λ x → B x → C) ↓ p ])
    → ({t : B x} {t' : B x'} (q : t == t' [ B ↓ p ])
        → u t == u' t')
  ↓-app→cst-out r q = ↓-cst-out (↓-Π-out r q)

  ↓-app→cst-β :
    (f : ({t : B x} {t' : B x'} (q : t == t' [ B ↓ p ])
           → u t == u' t'))
    → {t : B x} {t' : B x'} (q : t == t' [ B ↓ p ])
    → ↓-app→cst-out (↓-app→cst-in f) q == f q
  ↓-app→cst-β f q =
    ↓-app→cst-out (↓-app→cst-in f) q
             =⟨ idp ⟩
    ↓-cst-out (↓-Π-out (↓-Π-in (λ qq → ↓-cst-in (f qq))) q)
             =⟨ ↓-Π-β (λ qq → ↓-cst-in (f qq)) q |in-ctx
                      ↓-cst-out ⟩
    ↓-cst-out (↓-cst-in {p = pair= p q} (f q))
             =⟨ ↓-cst-β (pair= p q) (f q) ⟩
    f q ∎

-- Dependent paths in an arrow type
module _ {i j k} {A : Type i} {B : A → Type j} {C : A → Type k}
  {x x' : A} {p : x == x'} {u : B x → C x} {u' : B x' → C x'} where

  ↓-→-in :
    ({t : B x} {t' : B x'} (q : t == t' [ B ↓ p ])
      → u t == u' t' [ C ↓ p ])
    → (u == u' [ (λ x → B x → C x) ↓ p ])
  ↓-→-in f = ↓-Π-in (λ q → ↓-cst2-in p q (f q))

  ↓-→-out :
    (u == u' [ (λ x → B x → C x) ↓ p ])
    → ({t : B x} {t' : B x'} (q : t == t' [ B ↓ p ])
      → u t == u' t' [ C ↓ p ])
  ↓-→-out r q = ↓-cst2-out p q (↓-Π-out r q)

-- Dependent paths in a Π-type where the domain is constant
module _ {i j k} {A : Type i} {B : Type j} {C : A → B → Type k}
  {x x' : A} {p : x == x'}
  {u : (b : B) → C x b} {u' : (b : B) → C x' b} where

  postulate
    ↓-cst→app-in :
      ((b : B) → u b == u' b [ (λ x → C x b) ↓ p ])
      → (u == u' [ (λ x → (b : B) → C x b) ↓ p ])

  postulate
    ↓-cst→app-out :
      (u == u' [ (λ x → (b : B) → C x b) ↓ p ])
      → ((b : B) → u b == u' b [ (λ x → C x b) ↓ p ])

split-ap2 : ∀ {i j k} {A : Type i} {B : A → Type j} {C : Type k} (f : Σ A B → C)
  {x y : A} (p : x == y)
  {u : B x} {v : B y} (q : u == v [ B ↓ p ])
  → ap f (pair= p q) == ↓-app→cst-out (apd (curry f) p) q
split-ap2 f idp idp = idp

apdi2 : ∀ {i j k} {A : Type i} {B : A → Type j} {C : (a : A) → B a → Type k}
  (g : {a : A} → Π (B a) (C a)) {x y : A} {p : x == y}
  {u : B x} {v : B y} (q : u == v [ B ↓ p ])
  → g u == g v [ uncurry C ↓ pair= p q ]
apdi2 g {p = idp} idp = idp

apd-∘ : ∀ {i j k} {A : Type i} {B : A → Type j} {C : (a : A) → B a → Type k}
  (g : {a : A} → Π (B a) (C a)) (f : Π A B) {x y : A} (p : x == y)
  {q : f x == f y [ B ↓ p ]} (r : apd f p == q)
  → apd (g ∘ f) p == ↓-apd-out C r (apdi2 g q)
apd-∘ g f idp idp = idp

apd-∘' : ∀ {i j k} {A : Type i} {B : A → Type j} {C : A → Type k}
  (g : {a : A} → B a → C a) (f : Π A B) {x y : A} (p : x == y)
  → apd (g ∘ f) p == ap↓ g (apd f p)
apd-∘' g f idp = idp

postulate
 lhs :
  ∀ {i j k} {A : Type i} {B : A → Type j} {C : A → Type k} {f g : Π A B}
  {x y : A} {p : x == y} {u : f x == g x} {v : f y == g y}
  (k : (u ◃ apd g p) == (apd f p ▹ v))
  (h : {a : A} → B a → C a)
  → ap h u ◃ apd (h ∘ g) p == ap↓ h (u ◃ apd g p)

 rhs :
  ∀ {i j k} {A : Type i} {B : A → Type j} {C : A → Type k} {f g : Π A B}
  {x y : A} {p : x == y} {u : f x == g x} {v : f y == g y}
  (k : (u ◃ apd g p) == (apd f p ▹ v))
  (h : {a : A} → B a → C a)
  → ap↓ h (apd f p ▹ v) == apd (h ∘ f) p ▹ ap h v

 ap↓-↓-=-in :
  ∀ {i j k} {A : Type i} {B : A → Type j} {C : A → Type k} {f g : Π A B}
  {x y : A} {p : x == y} {u : f x == g x} {v : f y == g y}
  (k : (u ◃ apd g p) == (apd f p ▹ v))
  (h : {a : A} → B a → C a)
  → ap↓ (λ {a} → ap (h {a = a})) (↓-=-in {p = p} {u = u} {v = v} k)
  == ↓-=-in (lhs {f = f} {g = g} k h ∙ ap (ap↓ (λ {a} → h {a = a})) k 
                                     ∙ rhs {f = f} {g = g} k h)

--h (f x) == h (g y) [ C ↓ p ]


-- api2-swap! : ∀ {i j k ℓ} {A : Type i} {B : Type j} {C : Type k}
--   (f : A → C) (g : B → C)
--   {a a' : A} {p : a == a'} {b b' : B} {q : b == b'}
--   (r : f a == g b') (s : f a' == g b)
--   (t : r == s ∙ ap g q  [ (λ x → f x == g b') ↓ p ])
--   {D : Type ℓ}
--   (h : C → D)
--   → api2 (ap h) (↓-swap! f g r s t) == (ap-∙' h (ap f p) s ∙ ∘-ap h f p ∙'2 (idp :> (ap h s == ap h s))) ◃ --(∘-ap h f p ∙'2 (idp :> (ap h s == ap h s)))) ◃
--                                        ↓-swap! (h ∘ f) (h ∘ g) (ap h r) (ap h s)
--                                          (api2 (ap h) t ▹ (ap-∙ h s (ap g q) ∙ (idp :> (ap h s == ap h s)) ∙2 ∘-ap h g q))
-- api2-swap! = {!!}