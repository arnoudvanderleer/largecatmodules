(*

In this file :

- Proof that HSET has effective epis

- Proof that given a category D with pushouts, if a natural transformation 
between two functors of codomain D is an epi, then it is pointwise an epi 
(Colims_pw_epi).


- Proof that a natural transformation which is an epi when the codomain of
considered functors is the hSet category has a lifting property similar
to the previously mentionned for surjections.

- Proof that if a natural transformation is pointwise epi, then
 any pre-whiskering of it is also an epi.



Section leftadjoint : 
Preuve d'André à traduire.

*)

Require Import UniMath.Foundations.PartD.
Require Import UniMath.Foundations.Propositions.
Require Import UniMath.Foundations.Sets.

Require Import UniMath.CategoryTheory.Categories.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.whiskering.

Require Import UniMath.CategoryTheory.Epis.
Require Import UniMath.CategoryTheory.EpiFacts.

Require Import UniMath.CategoryTheory.Monads.
Require Import UniMath.CategoryTheory.LModules. 


Require Import TypeTheory.Auxiliary.Auxiliary.
Require Import TypeTheory.Auxiliary.UnicodeNotations.
Require Import TypeTheory.Displayed_Cats.Auxiliary.
Require Import TypeTheory.Displayed_Cats.Core.
Require Import TypeTheory.Displayed_Cats.Constructions.
Require Import TypeTheory.Displayed_Cats.Fibrations.

Require Import UniMath.CategoryTheory.HorizontalComposition.

Require Import UniMath.CategoryTheory.categories.category_hset.
Require Import UniMath.CategoryTheory.categories.category_hset_structures.
Require Import UniMath.CategoryTheory.limits.graphs.pullbacks.
Require Import UniMath.CategoryTheory.limits.graphs.colimits.
Require Import UniMath.CategoryTheory.limits.graphs.limits.
Require Import UniMath.CategoryTheory.limits.graphs.pushouts.
Require Import UniMath.CategoryTheory.limits.graphs.coequalizers.
Require Import UniMath.CategoryTheory.limits.pushouts.
Require Import UniMath.CategoryTheory.limits.terminal.
Require Import UniMath.CategoryTheory.limits.kernels.
Require Import UniMath.CategoryTheory.limits.pullbacks.
Require Import UniMath.CategoryTheory.limits.coequalizers.

Require Import UniMath.CategoryTheory.CocontFunctors.
Require Import UniMath.CategoryTheory.SetValuedFunctors.



Local Notation "# F" := (functor_on_morphisms F)(at level 3).
Local Notation "G □ F" := (functor_composite F G) (at level 35).
Local Notation "F ;;; G" := (nat_trans_comp _ _ _ F G) (at level 35).
Local  Notation "α ∙∙ β" := (horcomp β α) (at level 20).

(* Trouvé dans SubstitutionsSystem/Notation *)
Notation "α 'ø' Z" := (pre_whisker Z α)  (at level 25).
Notation "Z ∘ α" := (post_whisker α Z) (at level 50, left associativity).



Require Import Modules.Prelims.arities.

Require Import Modules.Prelims.lib.
Require Import Modules.Prelims.modules.




    
Set Automatic Introduction.

  
  
(*
A morphism of arity F : a -> b induces a functor between representation Rep(b) -> Rep(a)

In this section we construct the left adjoint of this functor (which is defined whenever
F is an epimorphism)
 *)
Section leftadjoint.


Local Notation "'SET'" := hset_category.
Local Notation CAT_ARITY := (arity_category SET).
Local Notation REP := (rep_disp SET).

Variables (a b:CAT_ARITY) (R:REP a)
          (F:CAT_ARITY ⟦ a, b⟧).

Local Notation "## F" := (pr1 (pr1 (F)))(at level 3).

(* Section QuotientMonad. *)
  (* Definition R': functor SET SET := quot_functor (pr1 (pr1 R)) _ congr_equivc. *)


Section QuotientMonad.

Context {eqrel_equivc : ∏ c, eqrel ((## R c):hSet)}
  (congr_equivc : ∏ (x y:SET) (f:SET⟦x,y⟧),
                    iscomprelrelfun (eqrel_equivc x) (eqrel_equivc y) (# (## R) f)).

Let equivc {c:hSet} x y := eqrel_equivc c x y.
  
(* We define the quotient functor of R by these equivalence relations

The following comment may be outdated
----
I need to make it not convertible to quot_functor otherwise
Coq takes a long time to check or compute things.
For example :   R' ((R' □ R') c) = (R' □ R') (R' c) by reflexivity
is so slow when R' is definitely equal to quot_functor !
----

*)
Definition R': functor SET SET := quot_functor (pr1 (pr1 R)) _ congr_equivc.

Definition projR : (## R) ⟹ R':= pr_quot_functor _ _ congr_equivc.

Arguments projR : simpl never.
Arguments R' : simpl never.

Lemma isEpi_projR_pw : ∏ x, isEpi (projR x).
Proof.
  apply isEpi_pw_pr_quot_functor.
Qed.
  (* TODO: utiliser partout ce lemme où c'est nécessaire *)
Lemma isEpi_projR : isEpi (C:=functor_category _ _) projR.
Proof.
  apply isEpi_pr_quot_functor.
Qed.

Lemma isEpi_projR_projR : isEpi (C:=functor_category _ _) (projR ∙∙ projR).
Proof.
  apply isEpi_horcomp. 
  - apply isEpi_projR.
  - apply isEpi_projR_pw.
Qed.


Lemma eq_projR_rel X x y : projR X x = projR X y -> equivc x y.
Proof.
  use invmap.
  apply (weqpathsinpr_quot_functor (D:=SET) _ _ congr_equivc).
Qed.
Lemma rel_eq_projR X x y : equivc x y -> projR X x = projR X y.
Proof.
  apply (weqpathsinpr_quot_functor (D:=SET) _ _ congr_equivc).
Qed.

Definition R'_η : (functor_identity SET) ⟹ R' := η (## R) ;;; projR .

Lemma R'_η_def : ∏ x, R'_η x =  η (## R) x ;; projR x.
Proof.
  intro x.
  apply idpath.
Qed.

  (* R'_μ is defined by the following diagram :
<<
                  μ R
            R R  ----->   R
             |           |
 projR projR |     H     | projR
             v           v
            R' R' ---->  R'
                  R'_μ
>>
   *)
(* The following condition is required about the equivalence relation
to make a monad out of R' *)
Definition compat_μ_projR_def := ∏ (X : SET) (x y : pr1 ((pr1 (## R □ ## R)) X)),
                       (projR ∙∙ projR) X x = (projR ∙∙ projR) X y →
                       (μ ## R;;; projR) X x = (μ ## R;;; projR) X y.



Variable (compat_μ_projR:compat_μ_projR_def).
  
Definition R'_μ  : nat_trans ( R'□  R')  ( R').
Proof.
  apply (univ_surj_nt (A:= ##R □ ##R) (B:=functor_composite R' R')                    
                      ( projR ∙∙ projR)
                      (μ  (## R) ;;; projR)).
  (* asbtract these *)
  -  apply compat_μ_projR.
  - apply isEpi_projR_projR.
Defined.

Lemma R'_μ_def : ∏ (x:SET),
                 (projR ∙∙ projR) x ;; R'_μ x = μ (## R) x ;; projR x .
Proof.
  intro x.
  unfold R'_μ.
  apply univ_surj_nt_ax_pw.
Qed.

Definition R'_Monad_data : Monad_data SET := ((R' ,, R'_μ) ,, R'_η).

 

Lemma R'_Monad_law_η1 : ∏ c : SET, R'_η (R' c) ;; R'_μ c = identity (R' c).
Proof.
  intro c.
  use (is_pointwise_epi_from_set_nat_trans_epi _ _ _ (projR)).
  apply isEpi_projR.
  repeat rewrite assoc.
  etrans.
  apply (cancel_postcomposition (b:=R' (R' c))).
  
  unfold R'_η.
  etrans;[apply assoc|].
  apply cancel_postcomposition.
  apply (nat_trans_ax (η ## R)).
  
  rewrite <- assoc.
  rewrite <- assoc.
  etrans.
  apply (cancel_precomposition _ _ _ (R' c)).
  cbn.
  apply R'_μ_def.
  
  rewrite assoc, id_right.
  etrans.
  apply cancel_postcomposition.
  apply (Monad_law1 (T:=pr1 R)).
  apply id_left.
Qed.

Lemma R'_Monad_law_η2 : ∏ c : SET, # R' (R'_η c) ;; R'_μ c = identity (R' c).
Proof.
  intro c.
  etrans.
    apply cancel_postcomposition.
    etrans.
    { apply maponpaths.
      apply R'_η_def. }
    apply functor_comp.
    use (is_pointwise_epi_from_set_nat_trans_epi _ _ _ projR).
    apply isEpi_projR.
  repeat rewrite assoc.
  etrans.
    apply cancel_postcomposition.
    apply cancel_postcomposition.
    symmetry.
    apply (nat_trans_ax (projR)).
  rewrite <- assoc.
  rewrite <- assoc.
  etrans.
    apply cancel_precomposition.
    apply R'_μ_def.
  rewrite assoc, id_right.
  rewrite (Monad_law2 (T:=pr1 R)).
  now rewrite id_left.
Qed.

Lemma assoc_ppprojR c : (projR ∙∙ projR) (## R c) ;; # (R' □ R') (projR c)
                        = (projR ∙∙ (projR ∙∙ projR)) c.
Proof.
  apply (horcomp_assoc projR projR projR c).
Qed.

Lemma R'_Monad_law_μ :  ∏ c : SET,
                              # R' (R'_μ  c) ;; R'_μ c = R'_μ (R' c) ;; R'_μ c.
Proof.
  intro c.
 
      (* Note : 

If I write instead :
  assert (epi :isEpi (horcomp projR (horcomp projR projR)  c)).
(convertibly the same by associativity)

then 'apply epi' takes a huge amount of time for Coq !!
This is due to the fact that Coq takes a long time to show that
   ((R' □ R') □ R') c = R' ((R' □ R') c)
because it has a very bad computing strategy. He tries to evaluates R'
which is bad idea. Probably because somewhere there is a Defined instead of 
Qed for some proof, and I suspect somewhere in the section about
quotients in basics/Sets.v

       *)
  assert (epi :isEpi (horcomp (horcomp projR projR) projR c)).
  {
    apply Pushouts_pw_epi.
    apply PushoutsHSET_from_Colims.
    apply isEpi_horcomp.
    apply isEpi_projR_projR.
    apply isEpi_projR_pw.
  }
  apply epi.

      (* To understand the proof, see the string diagram muproof sent to
Benedikt.

Legend of the diagram :
- μ = μ R
- ν = R'_μ
- i = projR
*)      
  etrans.
  (* First equality *)
  etrans.
  apply (assoc (C:=SET)).
  rewrite horcomp_pre_post.
  
      
  
  etrans.
  apply (cancel_postcomposition (C:=SET)).
  
  etrans.
  apply (cancel_postcomposition (C:=SET)).
  unfold compose.
  cbn -[R' compose horcomp].
  reflexivity.

  
  rewrite <- assoc.
  
  apply (cancel_precomposition SET).
  rewrite <- (functor_comp (C:=SET) (C':=SET)).
  apply maponpaths.      
  apply R'_μ_def.
  
  rewrite functor_comp,assoc.
  apply (cancel_postcomposition (C:=SET)).
  symmetry.
  apply cancel_postcomposition.
  apply (nat_trans_ax (projR)).
  
  (* second equality *)
  etrans.
  rewrite <- assoc.
  rewrite <- assoc.
  apply (cancel_precomposition (SET)).     
  apply (R'_μ_def c).
  
  (* third equality *)
  etrans.
  rewrite assoc.
  
  etrans.
  apply cancel_postcomposition.
  apply (Monad_law3 (T:=pr1 R) c).
  
  (* Fourth equality *)
  rewrite <- assoc.
  
  etrans.
  apply cancel_precomposition.
  symmetry.
  apply R'_μ_def.
  
  rewrite assoc.      
  apply cancel_postcomposition.
  
  (* Fifth equality *)
  etrans.
  cbn -[projR compose].
  rewrite (assoc (C:=SET)).
  apply (cancel_postcomposition (C:=SET)).
  symmetry.
  apply R'_μ_def.
  
  
  (* Close to the end *)
  etrans.
  rewrite <- assoc.
  apply (cancel_precomposition SET).
  symmetry.
  apply (nat_trans_ax (R'_μ) (## R c)).
  
  rewrite assoc.
  reflexivity.
  
  etrans.
  rewrite <- assoc.
  reflexivity.
  
  
  apply cancel_postcomposition.
  
  (* association of horcomposition *)
  apply assoc_ppprojR.
Qed.

Lemma R'_Monad_laws : Monad_laws R'_Monad_data.
Proof.
  repeat split.
  -  apply R'_Monad_law_η1.
  -  apply R'_Monad_law_η2.
  - apply R'_Monad_law_μ.
Qed.

  (* Le QED précédent prend énormément de temps.. pourquoi ? *)

Definition R'_monad : Monad _ := (_ ,, R'_Monad_laws).

  (*

FIN DE LA PREMIERE ETAPE

   *)

Lemma projR_monad_laws: Monad_Mor_laws (T':= R'_monad) projR.
Proof.
  split.
  - intro X.
    symmetry.
    apply R'_μ_def.
  - intro X.
    symmetry.
    apply R'_η_def.
Qed.

Definition projR_monad : Monad_Mor (pr1 R) (R'_monad) :=
  (_ ,, projR_monad_laws).

Lemma isEpi_projR_monad : isEpi (C:=category_Monad _) projR_monad.
Proof.    
  apply (faithful_reflects_epis (forgetfunctor_Monad _));
  [ apply forgetMonad_faithful|apply isEpi_projR].
Qed.

  (* FIN DE LA SECONDE ETAPE *)

End QuotientMonad.
(*
On any set X we define the following equivalence relation on R X : 
   x ~ y
iff for any representation morphism f : R -> F*(S) (where S is a b-representation)
  f x = f y.
*)



Definition equivc   {X:ob SET} (x y:pr1 ( ## R X)) :=
                                  (∏ (S:REP b) ( f : R -->[F] S),
                                   pr1 (pr1 f) X x = ## f X y).

Lemma isaprop_equivc_xy (c:ob SET) x y : isaprop (equivc (X:=c) x y).
Proof.
  intros.
  apply impred_isaprop.
  intros S.
  apply impred_isaprop.
  intros f.
  apply setproperty.
Qed.

Definition equivc_xy_prop (c:ob SET) x y : hProp :=
  (equivc  (X:=c) x y ,, isaprop_equivc_xy c x y).

Definition hrel_equivc c : hrel _ := fun x y => equivc_xy_prop c x y.

Lemma iseqrel_equivc c : iseqrel (hrel_equivc c).
Proof.
  unfold hrel_equivc, equivc_xy_prop, equivc; simpl;
  repeat split.
  -  intros x y z. cbn.
     intros h1 h2 S f.
     now rewrite h1,h2.
  - intros x y; cbn.
    intros h S f.
    now symmetry.
Qed.


Definition eqrel_equivc c : eqrel _ := (_ ,, iseqrel_equivc c).

(* For any f : X -> Y, #R f is compatible with previous equivalence relation *)
Lemma congr_equivc (x y:SET) (f:SET⟦ x,  y⟧):
                    iscomprelrelfun (eqrel_equivc x) (eqrel_equivc y) (# (## R) f).
Proof.
  intros z z' eqz S g.
  assert (hg := nat_trans_ax (pr1 (pr1 g)) x y f).
  cbn in eqz.
  apply toforallpaths in hg.
  etrans;[apply hg|].
  apply pathsinv0.
  etrans;[apply hg|].
  unfold equivc in eqz.
  cbn.
  now rewrite eqz.
Qed.

Arguments R' : simpl never.
Arguments projR : simpl never.

Let R' := R' congr_equivc.
Let projR := projR congr_equivc.
Let eq_projR_rel := eq_projR_rel congr_equivc.


  (* R' est un pseudo objet initial au sens suivant :
     Quel que soit        g : R ---> S morphisme dans la catégorie des représentations de a
     il existe un unique  u : R'---> S tel que g = u o projR
C'est un pseudo objet car il reste à montrer que R' est bien dans la catégorie des représentations
de a et que u est un morphisme de modules.
   *)
Section CandidatU.

Context {S:REP b} (m:R -->[ F] S).
  
Definition u : nat_trans (pr1 R') (## S).
Proof.
  apply (univ_surj_nt projR (## m)) ; [| apply isEpi_projR].
  abstract(
      intros X x y eqpr;
        apply eq_projR_rel in eqpr;
      use eqpr).
Defined.

Lemma u_def : ∏ x, ## m x = projR x ;; u x.
Proof.
  symmetry.
  apply univ_surj_nt_ax_pw.
Qed.

End CandidatU.






Lemma compat_μ_projR :(compat_μ_projR_def congr_equivc).
Proof.
  intros X x y.
  intros hxy.
  apply rel_eq_projR.
  intros S f.
  rewrite comp_cat_comp.
  symmetry.
  rewrite comp_cat_comp.
  eapply changef_path.
  symmetry.
  etrans.
  apply (Monad_Mor_μ (pr1 f)).
   
  etrans.
  apply (cancel_postcomposition (C:=SET)).
  etrans.
  apply cancel_postcomposition.
  apply u_def.
  apply cancel_precomposition.
  apply maponpaths.
  apply u_def.
  
  etrans.
  apply (cancel_postcomposition (C:=SET)).
  etrans.
  symmetry.      
  apply  (assoc (C:=SET) (projR (## R X)) (u f (## R X))).
  apply cancel_precomposition.
  etrans.
  
  symmetry.
  apply nat_trans_ax.

  apply cancel_postcomposition.
  apply (functor_comp _ (projR X) (u f X)).
  repeat rewrite assoc.
  reflexivity.
  cbn.
  apply maponpaths.
  apply maponpaths.
  apply maponpaths.
  (* set (z:=(projR (## R X);; # (leftadjoint.R' congr_equivc) (projR X))). *)
  (* apply (maponpaths ( *)
  (* cbn. *)
  (* assert (h:=fun T2 f => maponpaths (T2:=T2) f hxy). *)
  apply pathsinv0.
  cbn.
  apply hxy.
Qed.
  
Let R'_monad  := R'_monad congr_equivc compat_μ_projR.
Let projR_monad  := projR_monad congr_equivc compat_μ_projR.
Section morphInitialU.

Context {S:REP b} (m:R -->[ F] S).

    

Lemma u_monad_laws : Monad_Mor_laws (T:= R'_monad) (T':=## S) (u m).
Proof.
  red.
  split.
  - intro X.
    assert (epi :isEpi ( (horcomp projR projR) X)).
    {
      apply Pushouts_pw_epi.
      apply PushoutsHSET_from_Colims.
      apply isEpi_projR_projR.
    }
    apply epi.
    

    (* Now the real work begins *)
    etrans.
    
    (* use the monadicity of μ *)
    apply cancel_postcomposition.
    apply (nat_trans_ax (projR)).
    etrans.
    
    
        
    rewrite assoc.        
    apply cancel_postcomposition.
    symmetry.
    apply (Monad_Mor_μ (projR_monad)).
    
    (* definition of u *)
    etrans.
    rewrite <- assoc.
    cpre _.
    symmetry.
    apply u_def.
    
    (* m is a morphism of monad *)
    etrans.
    apply (Monad_Mor_μ (pr1 m)).
    
    (* Definition of u *)
    etrans.
    
    cpost _.
    etrans.
    etrans.
    cpost _.
    apply u_def.        
    cpre _.
    etrans.
    apply maponpaths.
    apply u_def.
    apply functor_comp.
    
    (* il s'agit de rememmtre les termes dans l'ordre *)
    
    rewrite assoc.
    cpost _.
    rewrite <- assoc.
    cpre _.
    symmetry.
    apply (nat_trans_ax (u m)).
    rewrite assoc.
    cbn.
    reflexivity.
  - intro X.
    etrans.
    cpost _.
    apply R'_η_def.
    rewrite <- assoc.
    rewrite <- u_def.
    apply (Monad_Mor_η (pr1 m)).
Qed.

Definition u_monad : Monad_Mor ( R'_monad) (pr1 S) :=
      (_ ,, u_monad_laws).
    
End morphInitialU.

  (* FIN DE LA TROISIEME ETAPE *)

Notation "# F" := (ar_mor _ F)
                    (at level 3) : arity_scope.
Delimit Scope arity_scope with ar.


Section R'Representation.

  (* R'_μr is defined by the following diagram :
<<
                  μr R
            a R  ----->  R
             |           |
         F R |           | projR
             v           |
            b R          |
             |           |
     b projR |           |
             v           v
           b R' -------> R'
                R'_μr

>>
or rather the following one
<<
        μr R
            a R  ----->  R
             |           |
     a projR |           | projR
             v           |
            a R'         |
             |           |
        F R' |           |
             v           v
            b R' ------> R'
                R'_μr
>>

      *)

    

Section eq_mr.
   
Context {S:REP b} (m:R -->[ F] S).

      
Lemma eq_mr' X : μr _ R X ;; ## m X = 
                 (F`` (pr1 R))%ar X ;;
                          pr1 (# b (projR_monad))%ar X ;;
                          pr1 (# b (u_monad m))%ar X ;;
                          μr _ ( S) X.
Proof.
  etrans.
  (* 1. m est un morphisme de representation *)
  apply rep_ar_mor_ax.
  
  (* Définition de u *)
  apply pathsinv0.
  etrans.        
  cpost _.
  rewrite <- assoc.
  cpre _.
  assert (yop:= @disp_functor_comp_var _ _ _ _ _ b ).
  assert (yop2 := fun xx yy zz  =>yop _ _ _ xx yy zz projR_monad (u_monad m)).
  assert (yop3 := yop2 (tt) (tt) (tt) (tt) (tt)).
  
  apply LModule_Mor_equiv in yop3.
  match type of yop3 with ?x = _ => let x' := type of x in set (typ := x') end.
  cbn in typ.
  assert (yop4 := nat_trans_eq_pointwise yop3 X).
  apply pathsinv0 in yop4.
  apply yop4.
  apply homset_property.
  cpost _.
  
  etrans; cycle 1.
  symmetry.
  etrans.
  (* cbn in F. *)
  (* set (zo:=(nat_trans_id (C':=monadPrecategory SET) (functor_identity_data (precategory_Monad_data HSET)))). *)
  (* cbn in zo. *)
  
  
  (* rewrite compose_nat_trans. *)
  (* revert X. *)
  (* use nat_trans_eq_pointwise; cycle 1. *)
  assert (hF :=disp_nat_trans_ax  (f:=pr1 m) (xx:=tt) (xx':=tt) F (tt)).
  apply LModule_Mor_equiv in hF.
  eapply nat_trans_eq_pointwise in hF.
  apply hF.
  apply homset_property.
  (* match goal with |- ?x = _ => set (x:= *)
  (* apply transport_arity_mor. *)
  
  set (e:= nat_trans_ax _ _ _ _).
  unfold transportb.
  induction (!e).
  cbn -[compose].
  apply idpath.
  
  cpre _.
  cbn.
  unfold idfun; cbn.
  unfold disp_functor_on_morphisms.
  set (mor1 := Monad_composition _ _ ).
  set (mor2 := pr1 m).
  assert (heq:mor1 = mor2).
  {
          use (invmap (Monad_Mor_equiv _ _ _)).
          apply (homset_property SET).
          apply nat_trans_eq.
          apply (homset_property SET).
          intro X'.
          apply pathsinv0.
          apply (u_def m).
  }
  now destruct heq.
  Qed.

      (* Peut etre(surement! TODO) il y a une preuve plus rapide qu'en passant
par eq_mr', mais vu que je viens de le démontrer autant l'utiliser
Le lien entre les deux se fait grâce à la naturalité de F *)
Lemma eq_mr X : μr _ R X ;; ## m X =
                pr1 (# a (projR_monad))%ar X ;;
                    (F`` ( R'_monad))%ar X ;;
                    (*    pr1 (# b (projR_monad))%ar X ;; *)
                    pr1 (# b (u_monad m))%ar X ;;
                    μr _ ( S) X.
Proof.
  etrans.
  apply eq_mr'.
  cpost _.
  cpost _.
  symmetry.
  etrans.
  
  assert( hf:=
            (disp_nat_trans_ax (F)(x':=pr1 R)(x:=R'_monad) (f:=projR_monad) (xx':= tt) (xx:=tt)
                               (tt)                                     
            )).
(*  
  assert( hf:=
            (disp_nat_trans_ax (F) (xx':= ttp (pr1 R)) (xx:=ttp R'_monad)
                               (ttp (projR_monad))                                     
            )).
*)
  apply LModule_Mor_equiv in hf.
  eapply nat_trans_eq_pointwise in hf.
  apply hf.        
  apply homset_property.
  unfold transportb.
  set (e:= ! nat_trans_ax  _ _ _ _).
  induction e.
  reflexivity.
Qed.

  

      
End eq_mr.

Open Scope arity_scope.
Lemma compat_μr_projR :
      ∏ (X : SET) x y,
      ( pr1 (# a projR_monad )%ar X ;;  (F `` R'_monad) X) x
      =       ( pr1 (# a projR_monad )%ar X ;; (F `` R'_monad) X) y
      (* (( armor_ob _ F (pr1 R) X ) ;; pr1 (# b projR_monad )%ar X) x *)
      (* = (( armor_ob _ F (pr1 R) X ) ;; pr1 (# b projR_monad )%ar X) y *)
      ->
            ((μr _ R X ;; projR X) ) x = (μr _ R X;; projR X)  y.
Proof.
  intros X x y comp.
  
  apply rel_eq_projR.
  intros S m.
  assert (h:= eq_mr m X).
  apply toforallpaths in h.
  etrans.
  apply h.
  apply pathsinv0.
  etrans.
  apply h.
  apply pathsinv0.
  cbn. 
  (* cbn in comp. *)
  apply maponpaths.
  apply maponpaths.
  (* apply maponpaths *)
  apply comp.
Qed.

    

(* F preserve the epis *)
Definition FpreserveR' := isEpi (C:=functor_precategory HSET HSET has_homsets_HSET)
                             (pr1 (F `` R'_monad)).
(* a preserve les epis *)
Definition apreserveepi := ∏ M N (f:category_Monad _⟦M,N⟧),
                              isEpi f -> isEpi
                                          (C:= functor_category _ _) (pr1 ( # a f)%ar).

Context (Fepi:FpreserveR') (aepi:apreserveepi).


Lemma isEpi_def_R'_μr : isEpi
                          (compose (C:=functor_category _ _)
                                   (pr1 ((# a)%ar projR_monad))
                                   (pr1 (F `` R'_monad)%ar)).
Proof.
  apply (isEpi_comp (functor_category _ _));[|apply Fepi].
  apply aepi;    apply isEpi_projR_monad.
Qed.

Definition R'_μr  : nat_trans (pr1 ( b` R'_monad)) R'.
Proof.
  apply (univ_surj_nt (* (A:= ##R □ ##R) (B:=functor_composite R' R')                     *)
           
           ( pr1 (# a projR_monad )%ar ;;;(( F`` (R'_monad)  )   ))
           (μr _ R  ;;; projR)).
  (* asbtract these *)
  -  apply compat_μr_projR.      
  - apply isEpi_def_R'_μr.
Defined.

Definition R'_μr_def :
  ∏ (X:SET),
  ( (# a (projR_monad))%ar) X ;; (F`` R'_monad) X;;R'_μr X  
  =  μr _ R X ;; projR X .
Proof.
  intro x.
  abstract(
      apply (univ_surj_nt_ax_pw ((pr1 (# a (projR_monad))%ar)  ;;; (F ``  R'_monad) ))).
Qed.


Lemma R'_μr_module_laws : LModule_Mor_laws _ (T:=pr1 (b ` R'_monad))
                                           (T':=  tautological_LModule R'_monad)
                                           R'_μr.
Proof.
  intro X.
  
  (* En vrai, je n'ai pas besoin ici que ce soit un epi pointwise (me semble-t-il)*)
  assert (epi : isEpi (* (C:=functor_Precategory SET SET) *)
                  ((  ( (pr1 (# a (projR_monad))%ar)  ;;;
                                                      (F ``  R'_monad) )    ∙∙ projR) X)).
  {
    apply Pushouts_pw_epi.
    apply PushoutsHSET_from_Colims.
    apply isEpi_horcomp.
    apply isEpi_projR.
    intro Y.
    apply Pushouts_pw_epi.
    apply PushoutsHSET_from_Colims.
    apply isEpi_def_R'_μr.
  }
  apply epi.
  cbn -[R' compose].
  
  (* Etape 1 : utiliser R'_μr_def pour faire disparaître R'_μr *)
  etrans.    
  rewrite (assoc (C:=SET)).
  
  apply (cancel_postcomposition (C:=SET)).

  etrans.
  apply (cancel_postcomposition (C:=SET)).
  
  (* je dois faire reculer le b avec la naturalité de F R' *)
  etrans.
  rewrite <- (assoc (C:=SET)).
  apply (cancel_precomposition SET).
  symmetry.
  apply (nat_trans_ax (F`` R'_monad)).
  (* je dois faire avance le #a projR_monad en avec la naturalité de a *)
  rewrite  (assoc (C:=SET)).
  apply (cancel_postcomposition (C:=SET)).
  
  symmetry.
  apply (nat_trans_ax (pr1 ((# a)%ar projR_monad))).
  
  (* suppression de R'_μr annoncé *)
  rewrite <- (assoc (C:=SET)).
  rewrite <- (assoc (C:=SET)).
  apply (cancel_precomposition SET).
  rewrite assoc.
  apply R'_μr_def.
  
    (* maintenant je dois supprimer R'_mu avec R'_μ_def
  Je dois donc faire appraitre horcomp projR projR devant *)

    (*
      a_R p       m R'        p R'       mu'
a_R R ---> a_R R' ----> R R' ---> R' R' ---> R'

     *)
    

  etrans.
  rewrite assoc.
  (* 
C'est bon : il faut intervertir a_R p et m R' et ça devrait être bon
   *)
  apply (cancel_postcomposition (C:=SET)).
  apply (cancel_postcomposition (C:=SET)).
  apply nat_trans_ax.
  
  etrans.
  rewrite <- assoc.
  rewrite <- assoc.
  apply (cancel_precomposition SET).
  rewrite assoc.
  apply R'_μ_def.
  
  apply pathsinv0.
  (* Dans l'autre sens maintenant *)
  etrans.
  (* 
       a_p R         F_R' R       b_R' p         σ_b_R'      m'
a_R R -----> a_R' R -----> b_R' R ----> b_R' R' -----> b_R' -----> R'
   *)
  (* But : utiliser R'_μr_def pour faire disparaître R'_μr = m' 

Il faut utiliser le fait que F R' et a p sont des morphismes de modules.

faire reculer b_R' p
- par la naturalité de F_R'
- par la naturalité de a_R

   *)
  
  apply (cancel_postcomposition (C:=SET)).
  etrans.
  rewrite <- (assoc (C:=SET)).
  apply (cancel_precomposition SET).
  symmetry.
  apply (nat_trans_ax ((F`` R'_monad))).
  
  rewrite assoc.
  apply cancel_postcomposition.
  symmetry.
  apply (nat_trans_ax (pr1 ((# a)%ar projR_monad))).
  
  (* Maintenant on utilie le fait que F R' et p sont des morphismes de module *)
  etrans.
  rewrite assoc.
  apply (cancel_postcomposition (C:=SET)).
  repeat rewrite <- assoc.
  etrans.
  
  apply (cancel_precomposition SET).
  apply (cancel_precomposition SET).
  
  assert (hb := LModule_Mor_σ _ (  ( pr1 F R'_monad (tt))) X).
  (* On se fait emmerder à cause de # b identitye = identite *)
  assert (hid := functor_id (pr1 (pr1 b R'_monad (tt))) (R' X)).
  use (pathscomp0 _ hb).
  apply cancel_precomposition.
  cbn.
  apply funextfun.
  apply toforallpaths in hid.
  intro x.
  cbn.
  now rewrite hid.
    

    (* Ouf ! passons à #a p morphisme de module *)
    rewrite assoc,assoc.
    apply cancel_postcomposition.
    (* ici negro *)

    assert (ha := LModule_Mor_σ _ (  ( ((# a)%ar projR_monad))) ( X)).
    use (pathscomp0 _ ha).
    (* un petit de natural transformation_ax s'impose pour mettre projR_monad en premier *)
    etrans.
    apply cancel_postcomposition.
    apply (nat_trans_ax (pr1 ((# a)%ar projR_monad))).
    
    apply funextfun.
    intro x.
    apply idpath.

    (* voilà le travail ! maintenant on peu éliminer R'_μr avec R'_μr_def *)
    etrans.
    do 2  rewrite <- assoc.
    apply (cancel_precomposition SET).
    rewrite assoc.
    apply R'_μr_def.
    rewrite assoc.    
    rewrite (assoc (C:=SET)).    
    apply (cancel_postcomposition (C:=SET)).
    etrans.
    (* m_R est un morphism de module *)

    assert (hm := LModule_Mor_σ _ (  ( (μr  SET R )) ) X).
    symmetry.
    apply hm.
    apply idpath.
Qed.    

Definition R'_μr_module :LModule_Mor _ (b` R'_monad)
                                     ( tautological_LModule R'_monad) :=
  (_ ,, R'_μr_module_laws).


Definition R'_rep : (rep_disp SET b).
  use tpair.
  - exact R'_monad.
  - exact R'_μr_module.
Defined.

  (* FIN DE LA PARTIE 5 *)

  (* projR est un morphisme de representation *)

Lemma projR_rep_laws : rep_ar_mor_law SET R R'_rep F projR_monad.
Proof.
  intro X.
  (* etrans. *)
  symmetry.
  apply (R'_μr_def X).
Qed.

Definition projR_rep : R -->[F] R'_rep := (_ ,, projR_rep_laws).


End R'Representation.


Lemma cancel_ar_on {a'}
      {R'' (* : REP a*)}                  (*  *)
      (* {F' : CAT_ARITY ⟦ a', b' ⟧ *)
      {S (* : REP b *)}
      (m m' : Monad_Mor R'' S)
      (X : SET) : m = m' ->
                  (# a')%ar m X = (# a')%ar m' X .
Proof.
  intro e; now induction e.
Qed.

  (* u morphisme de représentation *)
Section uRepresentation.

Context {S:REP b} (m:R -->[ F] S).
Context (Fepi:FpreserveR') (aepi:apreserveepi).

Open Scope arity_scope.
  
  
(* Local Notation R'_REP := (R'_rep FepiR' aepiR). *)

Lemma u_rep_laws : rep_ar_mor_law SET (R'_rep Fepi aepi) S (disp_nat_trans_id (pr1 b))
                                  (u_monad m).
Proof.
  intro X.

  (* but : utiliser R'_μr_def *)
  assert (epi : isEpi (* (C:=functor_Precategory SET SET) *)
                  (   ((pr1 (# a (projR_monad))%ar)  ;;;
                                                     (F``  R'_monad) )X    )).
  {
    
    apply Pushouts_pw_epi.
    apply PushoutsHSET_from_Colims.
    apply isEpi_def_R'_μr; assumption.
  }
  
  apply epi.
  
  etrans.
  apply assoc.
  
  etrans.
  cpost _.
  (*  apply (R'_μr_def X) takes a long time, but use is immediate *)
  use (R'_μr_def Fepi aepi X).
  
  (* faire disparaitre le u avec u_def *)
  etrans.
  rewrite <- assoc.
  cpre _.      
  eapply pathsinv0.
  apply (u_def m).
  
  (* utiliser le fait que m est un morphisme de representation *)
  etrans.
  apply (rep_ar_mor_ax _ m X).
  
  rewrite assoc.
  cpost _.
  
  (* on réécrit m *)
  etrans.
  cpost _.
  apply (cancel_ar_on _ (compose (C:=category_Monad _) projR_monad (u_monad m))).
  use (invmap (Monad_Mor_equiv _ _ _)).
  { apply homset_property. }
  { apply nat_trans_eq.
    apply homset_property.
    apply (u_def m).
  }
  
  etrans.
  
  etrans.
  cpost _.
  use (nat_trans_eq_pointwise _ X); cycle 1.
  apply maponpaths.
  assert (yop:= @disp_functor_comp _ _ _ _ _ a ).
  assert (yop2 := fun xx yy zz  =>yop _ _ _ xx yy zz projR_monad (u_monad m)).
  assert (yop3 := yop2 (tt) (tt) (tt) (tt) (tt)).
  apply yop3.
  (* todo : systématiser la séquence préécdente *)
  cpost _.
  cbn -[compose].
  apply idpath.
  
  
  etrans.
  cpost _.
  eapply (pathsinv0 (b:=pr1 (#a projR_monad)%ar X ;; pr1 (#a (u_monad m))%ar X )).
  reflexivity.
  etrans.
  rewrite <- assoc.
  cpre _.
  etrans.
  assert (hF :=disp_nat_trans_ax  (f:= (u_monad m)) (xx:=tt) (xx':=tt) F (tt)).
  apply LModule_Mor_equiv in hF.
  eapply nat_trans_eq_pointwise in hF.
  apply hF.
  apply homset_property.
  set (e:= nat_trans_ax _ _ _ _).
  
  unfold transportb.      
  induction (!e).
  
  (* cbn -[compose]. *)
  apply idpath.
  apply funextfun.
  intro x.
  cbn.
  apply idpath.
Qed.


Definition u_rep : (R'_rep Fepi aepi) -->[(disp_nat_trans_id (pr1 b))] S := (_ ,, u_rep_laws).
      
End uRepresentation.

  (* FIN DE LA PARTIE 6 *)

 Section uUnique.
 Context {S:REP b} (hm: iscontr (R -->[ F] S)).
 Context (Fepi:FpreserveR') (aepi:apreserveepi).

 Variable u'_rep : (R'_rep Fepi aepi) -->[(disp_nat_trans_id (pr1 b))] S.
 
 Lemma u_rep_unique : u'_rep = (u_rep (pr1 hm) Fepi aepi).
 Proof.
   set (m' := (projR_rep Fepi aepi ;; u'_rep)%mor_disp).
   apply rep_ar_mor_mor_equiv.
   intro X.
   
   cbn.
   unfold u.
   
   revert X.
   apply (univ_surj_nt_unique _ _ _ _ (##u'_rep)).
   set (m := (pr1 hm ;; id_disp S)%mor_disp).
   assert (eqm':m' = m).
   {
     subst m.
     rewrite id_right_disp .
     apply transportf_transpose .
     apply (pr2 hm).
   }
   assert(eqm'2: pr1 m' = pr1 m).
   now rewrite eqm'.
   apply Monad_Mor_equiv in eqm'2.
   apply nat_trans_eq.
   apply has_homsets_HSET.
   intro X.
   eapply nat_trans_eq_pointwise in eqm'2.
   apply eqm'2.
   apply has_homsets_HSET.
Qed.      
    
End uUnique.

End leftadjoint.

