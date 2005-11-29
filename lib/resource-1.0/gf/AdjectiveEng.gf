concrete AdjectiveEng of Adjective = CatEng ** open ResEng, Prelude in {

  lin

    PositA  a = {
      s = \\_ => a.s ! AAdj Posit ;
      isPre = True
      } ;
    ComparA a np = {
      s = \\_ => a.s ! AAdj Compar ++ "than" ++ np.s ! Nom ; 
      isPre = False
      } ;

-- $SuperlA$ belongs to determiner syntax in $Noun$.

    ComplA2 a np = {
      s = \\_ => a.s ! AAdj Posit ++ a.c2 ++ np.s ! Acc ; 
      isPre = False
      } ;

    ReflA2 a = {
      s = \\ag => a.s ! AAdj Posit ++ a.c2 ++ reflPron ! ag ; 
      isPre = False
      } ;

    SentAP ap s = {
      s = \\a => ap.s ! a ++ conjThat ++ s.s ; 
      isPre = False
      } ;
    QuestAP ap qs = {
      s = \\a => ap.s ! a ++ qs.s ! QIndir ; 
      isPre = False
      } ;

    AdAP ada ap = {
      s = \\a => ada.s ++ ap.s ! a ;
      isPre = ap.isPre
      } ;

    UseA2 a = a ;

}
