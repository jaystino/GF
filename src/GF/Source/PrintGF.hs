{-# OPTIONS -fno-warn-incomplete-patterns #-}
module GF.Source.PrintGF where

-- pretty-printer generated by the BNF converter

import GF.Source.AbsGF
import Data.Char
import qualified Data.ByteString.Char8 as BS

-- the top-level printing method
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : "," :ts -> showString t . space "," . rend i ts
    t  : ")" :ts -> showString t . showChar ')' . rend i ts
    t  : "]" :ts -> showString t . showChar ']' . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else (' ':s))

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- the printer class does the job
class Print a where
  prt :: Int -> a -> Doc
  prtList :: [a] -> Doc
  prtList = concatD . map (prt 0)

instance Print a => Print [a] where
  prt _ = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j<i then parenth else id


instance Print Integer where
  prt _ x = doc (shows x)


instance Print Double where
  prt _ x = doc (shows x)



instance Print LString where
  prt _ (LString i) = doc (showString (BS.unpack i))


instance Print PIdent where
  prt _ (PIdent (_,i)) = doc (showString (BS.unpack i))
  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])



instance Print Grammar where
  prt i e = case e of
   Gr moddefs -> prPrec i 0 (concatD [prt 0 moddefs])


instance Print ModDef where
  prt i e = case e of
   MMain pident0 pident concspecs -> prPrec i 0 (concatD [doc (showString "grammar") , prt 0 pident0 , doc (showString "=") , doc (showString "{") , doc (showString "abstract") , doc (showString "=") , prt 0 pident , doc (showString ";") , prt 0 concspecs , doc (showString "}")])
   MModule complmod modtype modbody -> prPrec i 0 (concatD [prt 0 complmod , prt 0 modtype , doc (showString "=") , prt 0 modbody])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print ConcSpec where
  prt i e = case e of
   ConcSpec pident concexp -> prPrec i 0 (concatD [prt 0 pident , doc (showString "=") , prt 0 concexp])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print ConcExp where
  prt i e = case e of
   ConcExp pident transfers -> prPrec i 0 (concatD [prt 0 pident , prt 0 transfers])


instance Print Transfer where
  prt i e = case e of
   TransferIn open -> prPrec i 0 (concatD [doc (showString "(") , doc (showString "transfer") , doc (showString "in") , prt 0 open , doc (showString ")")])
   TransferOut open -> prPrec i 0 (concatD [doc (showString "(") , doc (showString "transfer") , doc (showString "out") , prt 0 open , doc (showString ")")])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print ModHeader where
  prt i e = case e of
   MModule2 complmod modtype modheaderbody -> prPrec i 0 (concatD [prt 0 complmod , prt 0 modtype , doc (showString "=") , prt 0 modheaderbody])


instance Print ModHeaderBody where
  prt i e = case e of
   MBody2 extend opens -> prPrec i 0 (concatD [prt 0 extend , prt 0 opens])
   MNoBody2 includeds -> prPrec i 0 (concatD [prt 0 includeds])
   MWith2 included opens -> prPrec i 0 (concatD [prt 0 included , doc (showString "with") , prt 0 opens])
   MWithBody2 included opens0 opens -> prPrec i 0 (concatD [prt 0 included , doc (showString "with") , prt 0 opens0 , doc (showString "**") , prt 0 opens])
   MWithE2 includeds included opens -> prPrec i 0 (concatD [prt 0 includeds , doc (showString "**") , prt 0 included , doc (showString "with") , prt 0 opens])
   MWithEBody2 includeds included opens0 opens -> prPrec i 0 (concatD [prt 0 includeds , doc (showString "**") , prt 0 included , doc (showString "with") , prt 0 opens0 , doc (showString "**") , prt 0 opens])
   MReuse2 pident -> prPrec i 0 (concatD [doc (showString "reuse") , prt 0 pident])
   MUnion2 includeds -> prPrec i 0 (concatD [doc (showString "union") , prt 0 includeds])


instance Print ModType where
  prt i e = case e of
   MTAbstract pident -> prPrec i 0 (concatD [doc (showString "abstract") , prt 0 pident])
   MTResource pident -> prPrec i 0 (concatD [doc (showString "resource") , prt 0 pident])
   MTInterface pident -> prPrec i 0 (concatD [doc (showString "interface") , prt 0 pident])
   MTConcrete pident0 pident -> prPrec i 0 (concatD [doc (showString "concrete") , prt 0 pident0 , doc (showString "of") , prt 0 pident])
   MTInstance pident0 pident -> prPrec i 0 (concatD [doc (showString "instance") , prt 0 pident0 , doc (showString "of") , prt 0 pident])
   MTTransfer pident open0 open -> prPrec i 0 (concatD [doc (showString "transfer") , prt 0 pident , doc (showString ":") , prt 0 open0 , doc (showString "->") , prt 0 open])


instance Print ModBody where
  prt i e = case e of
   MBody extend opens topdefs -> prPrec i 0 (concatD [prt 0 extend , prt 0 opens , doc (showString "{") , prt 0 topdefs , doc (showString "}")])
   MNoBody includeds -> prPrec i 0 (concatD [prt 0 includeds])
   MWith included opens -> prPrec i 0 (concatD [prt 0 included , doc (showString "with") , prt 0 opens])
   MWithBody included opens0 opens topdefs -> prPrec i 0 (concatD [prt 0 included , doc (showString "with") , prt 0 opens0 , doc (showString "**") , prt 0 opens , doc (showString "{") , prt 0 topdefs , doc (showString "}")])
   MWithE includeds included opens -> prPrec i 0 (concatD [prt 0 includeds , doc (showString "**") , prt 0 included , doc (showString "with") , prt 0 opens])
   MWithEBody includeds included opens0 opens topdefs -> prPrec i 0 (concatD [prt 0 includeds , doc (showString "**") , prt 0 included , doc (showString "with") , prt 0 opens0 , doc (showString "**") , prt 0 opens , doc (showString "{") , prt 0 topdefs , doc (showString "}")])
   MReuse pident -> prPrec i 0 (concatD [doc (showString "reuse") , prt 0 pident])
   MUnion includeds -> prPrec i 0 (concatD [doc (showString "union") , prt 0 includeds])


instance Print Extend where
  prt i e = case e of
   Ext includeds -> prPrec i 0 (concatD [prt 0 includeds , doc (showString "**")])
   NoExt  -> prPrec i 0 (concatD [])


instance Print Opens where
  prt i e = case e of
   NoOpens  -> prPrec i 0 (concatD [])
   OpenIn opens -> prPrec i 0 (concatD [doc (showString "open") , prt 0 opens , doc (showString "in")])


instance Print Open where
  prt i e = case e of
   OName pident -> prPrec i 0 (concatD [prt 0 pident])
   OQualQO qualopen pident -> prPrec i 0 (concatD [doc (showString "(") , prt 0 qualopen , prt 0 pident , doc (showString ")")])
   OQual qualopen pident0 pident -> prPrec i 0 (concatD [doc (showString "(") , prt 0 qualopen , prt 0 pident0 , doc (showString "=") , prt 0 pident , doc (showString ")")])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print ComplMod where
  prt i e = case e of
   CMCompl  -> prPrec i 0 (concatD [])
   CMIncompl  -> prPrec i 0 (concatD [doc (showString "incomplete")])


instance Print QualOpen where
  prt i e = case e of
   QOCompl  -> prPrec i 0 (concatD [])
   QOIncompl  -> prPrec i 0 (concatD [doc (showString "incomplete")])
   QOInterface  -> prPrec i 0 (concatD [doc (showString "interface")])


instance Print Included where
  prt i e = case e of
   IAll pident -> prPrec i 0 (concatD [prt 0 pident])
   ISome pident pidents -> prPrec i 0 (concatD [prt 0 pident , doc (showString "[") , prt 0 pidents , doc (showString "]")])
   IMinus pident pidents -> prPrec i 0 (concatD [prt 0 pident , doc (showString "-") , doc (showString "[") , prt 0 pidents , doc (showString "]")])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print Def where
  prt i e = case e of
   DDecl names exp -> prPrec i 0 (concatD [prt 0 names , doc (showString ":") , prt 0 exp])
   DDef names exp -> prPrec i 0 (concatD [prt 0 names , doc (showString "=") , prt 0 exp])
   DPatt name patts exp -> prPrec i 0 (concatD [prt 0 name , prt 0 patts , doc (showString "=") , prt 0 exp])
   DFull names exp0 exp -> prPrec i 0 (concatD [prt 0 names , doc (showString ":") , prt 0 exp0 , doc (showString "=") , prt 0 exp])

  prtList es = case es of
   [x] -> (concatD [prt 0 x , doc (showString ";")])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print TopDef where
  prt i e = case e of
   DefCat catdefs -> prPrec i 0 (concatD [doc (showString "cat") , prt 0 catdefs])
   DefFun fundefs -> prPrec i 0 (concatD [doc (showString "fun") , prt 0 fundefs])
   DefFunData fundefs -> prPrec i 0 (concatD [doc (showString "data") , prt 0 fundefs])
   DefDef defs -> prPrec i 0 (concatD [doc (showString "def") , prt 0 defs])
   DefData datadefs -> prPrec i 0 (concatD [doc (showString "data") , prt 0 datadefs])
   DefTrans defs -> prPrec i 0 (concatD [doc (showString "transfer") , prt 0 defs])
   DefPar pardefs -> prPrec i 0 (concatD [doc (showString "param") , prt 0 pardefs])
   DefOper defs -> prPrec i 0 (concatD [doc (showString "oper") , prt 0 defs])
   DefLincat printdefs -> prPrec i 0 (concatD [doc (showString "lincat") , prt 0 printdefs])
   DefLindef defs -> prPrec i 0 (concatD [doc (showString "lindef") , prt 0 defs])
   DefLin defs -> prPrec i 0 (concatD [doc (showString "lin") , prt 0 defs])
   DefPrintCat printdefs -> prPrec i 0 (concatD [doc (showString "printname") , doc (showString "cat") , prt 0 printdefs])
   DefPrintFun printdefs -> prPrec i 0 (concatD [doc (showString "printname") , doc (showString "fun") , prt 0 printdefs])
   DefFlag flagdefs -> prPrec i 0 (concatD [doc (showString "flags") , prt 0 flagdefs])
   DefPrintOld printdefs -> prPrec i 0 (concatD [doc (showString "printname") , prt 0 printdefs])
   DefLintype defs -> prPrec i 0 (concatD [doc (showString "lintype") , prt 0 defs])
   DefPattern defs -> prPrec i 0 (concatD [doc (showString "pattern") , prt 0 defs])
   DefPackage pident topdefs -> prPrec i 0 (concatD [doc (showString "package") , prt 0 pident , doc (showString "=") , doc (showString "{") , prt 0 topdefs , doc (showString "}") , doc (showString ";")])
   DefVars defs -> prPrec i 0 (concatD [doc (showString "var") , prt 0 defs])
   DefTokenizer pident -> prPrec i 0 (concatD [doc (showString "tokenizer") , prt 0 pident , doc (showString ";")])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print CatDef where
  prt i e = case e of
   SimpleCatDef pident ddecls -> prPrec i 0 (concatD [prt 0 pident , prt 0 ddecls])
   ListCatDef pident ddecls -> prPrec i 0 (concatD [doc (showString "[") , prt 0 pident , prt 0 ddecls , doc (showString "]")])
   ListSizeCatDef pident ddecls n -> prPrec i 0 (concatD [doc (showString "[") , prt 0 pident , prt 0 ddecls , doc (showString "]") , doc (showString "{") , prt 0 n , doc (showString "}")])

  prtList es = case es of
   [x] -> (concatD [prt 0 x , doc (showString ";")])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print FunDef where
  prt i e = case e of
   FunDef pidents exp -> prPrec i 0 (concatD [prt 0 pidents , doc (showString ":") , prt 0 exp])

  prtList es = case es of
   [x] -> (concatD [prt 0 x , doc (showString ";")])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print DataDef where
  prt i e = case e of
   DataDef pident dataconstrs -> prPrec i 0 (concatD [prt 0 pident , doc (showString "=") , prt 0 dataconstrs])

  prtList es = case es of
   [x] -> (concatD [prt 0 x , doc (showString ";")])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print DataConstr where
  prt i e = case e of
   DataId pident -> prPrec i 0 (concatD [prt 0 pident])
   DataQId pident0 pident -> prPrec i 0 (concatD [prt 0 pident0 , doc (showString ".") , prt 0 pident])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString "|") , prt 0 xs])

instance Print ParDef where
  prt i e = case e of
   ParDefDir pident parconstrs -> prPrec i 0 (concatD [prt 0 pident , doc (showString "=") , prt 0 parconstrs])
   ParDefIndir pident0 pident -> prPrec i 0 (concatD [prt 0 pident0 , doc (showString "=") , doc (showString "(") , doc (showString "in") , prt 0 pident , doc (showString ")")])
   ParDefAbs pident -> prPrec i 0 (concatD [prt 0 pident])

  prtList es = case es of
   [x] -> (concatD [prt 0 x , doc (showString ";")])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print ParConstr where
  prt i e = case e of
   ParConstr pident ddecls -> prPrec i 0 (concatD [prt 0 pident , prt 0 ddecls])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString "|") , prt 0 xs])

instance Print PrintDef where
  prt i e = case e of
   PrintDef names exp -> prPrec i 0 (concatD [prt 0 names , doc (showString "=") , prt 0 exp])

  prtList es = case es of
   [x] -> (concatD [prt 0 x , doc (showString ";")])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print FlagDef where
  prt i e = case e of
   FlagDef pident0 pident -> prPrec i 0 (concatD [prt 0 pident0 , doc (showString "=") , prt 0 pident])

  prtList es = case es of
   [x] -> (concatD [prt 0 x , doc (showString ";")])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print Name where
  prt i e = case e of
   IdentName pident -> prPrec i 0 (concatD [prt 0 pident])
   ListName pident -> prPrec i 0 (concatD [doc (showString "[") , prt 0 pident , doc (showString "]")])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print LocDef where
  prt i e = case e of
   LDDecl pidents exp -> prPrec i 0 (concatD [prt 0 pidents , doc (showString ":") , prt 0 exp])
   LDDef pidents exp -> prPrec i 0 (concatD [prt 0 pidents , doc (showString "=") , prt 0 exp])
   LDFull pidents exp0 exp -> prPrec i 0 (concatD [prt 0 pidents , doc (showString ":") , prt 0 exp0 , doc (showString "=") , prt 0 exp])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print Exp where
  prt i e = case e of
   EIdent pident -> prPrec i 6 (concatD [prt 0 pident])
   EConstr pident -> prPrec i 6 (concatD [doc (showString "{") , prt 0 pident , doc (showString "}")])
   ECons pident -> prPrec i 6 (concatD [doc (showString "%") , prt 0 pident , doc (showString "%")])
   ESort sort -> prPrec i 6 (concatD [prt 0 sort])
   EString str -> prPrec i 6 (concatD [prt 0 str])
   EInt n -> prPrec i 6 (concatD [prt 0 n])
   EFloat d -> prPrec i 6 (concatD [prt 0 d])
   EMeta  -> prPrec i 6 (concatD [doc (showString "?")])
   EEmpty  -> prPrec i 6 (concatD [doc (showString "[") , doc (showString "]")])
   EData  -> prPrec i 6 (concatD [doc (showString "data")])
   EList pident exps -> prPrec i 6 (concatD [doc (showString "[") , prt 0 pident , prt 0 exps , doc (showString "]")])
   EStrings str -> prPrec i 6 (concatD [doc (showString "[") , prt 0 str , doc (showString "]")])
   ERecord locdefs -> prPrec i 6 (concatD [doc (showString "{") , prt 0 locdefs , doc (showString "}")])
   ETuple tuplecomps -> prPrec i 6 (concatD [doc (showString "<") , prt 0 tuplecomps , doc (showString ">")])
   EIndir pident -> prPrec i 6 (concatD [doc (showString "(") , doc (showString "in") , prt 0 pident , doc (showString ")")])
   ETyped exp0 exp -> prPrec i 6 (concatD [doc (showString "<") , prt 0 exp0 , doc (showString ":") , prt 0 exp , doc (showString ">")])
   EProj exp label -> prPrec i 5 (concatD [prt 5 exp , doc (showString ".") , prt 0 label])
   EQConstr pident0 pident -> prPrec i 5 (concatD [doc (showString "{") , prt 0 pident0 , doc (showString ".") , prt 0 pident , doc (showString "}")])
   EQCons pident0 pident -> prPrec i 5 (concatD [doc (showString "%") , prt 0 pident0 , doc (showString ".") , prt 0 pident])
   EApp exp0 exp -> prPrec i 4 (concatD [prt 4 exp0 , prt 5 exp])
   ETable cases -> prPrec i 4 (concatD [doc (showString "table") , doc (showString "{") , prt 0 cases , doc (showString "}")])
   ETTable exp cases -> prPrec i 4 (concatD [doc (showString "table") , prt 6 exp , doc (showString "{") , prt 0 cases , doc (showString "}")])
   EVTable exp exps -> prPrec i 4 (concatD [doc (showString "table") , prt 6 exp , doc (showString "[") , prt 0 exps , doc (showString "]")])
   ECase exp cases -> prPrec i 4 (concatD [doc (showString "case") , prt 0 exp , doc (showString "of") , doc (showString "{") , prt 0 cases , doc (showString "}")])
   EVariants exps -> prPrec i 4 (concatD [doc (showString "variants") , doc (showString "{") , prt 0 exps , doc (showString "}")])
   EPre exp alterns -> prPrec i 4 (concatD [doc (showString "pre") , doc (showString "{") , prt 0 exp , doc (showString ";") , prt 0 alterns , doc (showString "}")])
   EStrs exps -> prPrec i 4 (concatD [doc (showString "strs") , doc (showString "{") , prt 0 exps , doc (showString "}")])
   EConAt pident exp -> prPrec i 4 (concatD [prt 0 pident , doc (showString "@") , prt 6 exp])
   EPatt patt -> prPrec i 4 (concatD [doc (showString "#") , prt 2 patt])
   EPattType exp -> prPrec i 4 (concatD [doc (showString "pattern") , prt 5 exp])
   ESelect exp0 exp -> prPrec i 3 (concatD [prt 3 exp0 , doc (showString "!") , prt 4 exp])
   ETupTyp exp0 exp -> prPrec i 3 (concatD [prt 3 exp0 , doc (showString "*") , prt 4 exp])
   EExtend exp0 exp -> prPrec i 3 (concatD [prt 3 exp0 , doc (showString "**") , prt 4 exp])
   EGlue exp0 exp -> prPrec i 1 (concatD [prt 2 exp0 , doc (showString "+") , prt 1 exp])
   EConcat exp0 exp -> prPrec i 0 (concatD [prt 1 exp0 , doc (showString "++") , prt 0 exp])
   EAbstr binds exp -> prPrec i 0 (concatD [doc (showString "\\") , prt 0 binds , doc (showString "->") , prt 0 exp])
   ECTable binds exp -> prPrec i 0 (concatD [doc (showString "\\") , doc (showString "\\") , prt 0 binds , doc (showString "=>") , prt 0 exp])
   EProd decl exp -> prPrec i 0 (concatD [prt 0 decl , doc (showString "->") , prt 0 exp])
   ETType exp0 exp -> prPrec i 0 (concatD [prt 3 exp0 , doc (showString "=>") , prt 0 exp])
   ELet locdefs exp -> prPrec i 0 (concatD [doc (showString "let") , doc (showString "{") , prt 0 locdefs , doc (showString "}") , doc (showString "in") , prt 0 exp])
   ELetb locdefs exp -> prPrec i 0 (concatD [doc (showString "let") , prt 0 locdefs , doc (showString "in") , prt 0 exp])
   EWhere exp locdefs -> prPrec i 0 (concatD [prt 3 exp , doc (showString "where") , doc (showString "{") , prt 0 locdefs , doc (showString "}")])
   EEqs equations -> prPrec i 0 (concatD [doc (showString "fn") , doc (showString "{") , prt 0 equations , doc (showString "}")])
   EExample exp str -> prPrec i 0 (concatD [doc (showString "in") , prt 5 exp , prt 0 str])
   ELString lstring -> prPrec i 6 (concatD [prt 0 lstring])
   ELin pident -> prPrec i 4 (concatD [doc (showString "Lin") , prt 0 pident])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print Exps where
  prt i e = case e of
   NilExp  -> prPrec i 0 (concatD [])
   ConsExp exp exps -> prPrec i 0 (concatD [prt 6 exp , prt 0 exps])


instance Print Patt where
  prt i e = case e of
   PChar  -> prPrec i 2 (concatD [doc (showString "?")])
   PChars str -> prPrec i 2 (concatD [doc (showString "[") , prt 0 str , doc (showString "]")])
   PMacro pident -> prPrec i 2 (concatD [doc (showString "#") , prt 0 pident])
   PM pident0 pident -> prPrec i 2 (concatD [doc (showString "#") , prt 0 pident0 , doc (showString ".") , prt 0 pident])
   PW  -> prPrec i 2 (concatD [doc (showString "_")])
   PV pident -> prPrec i 2 (concatD [prt 0 pident])
   PCon pident -> prPrec i 2 (concatD [doc (showString "{") , prt 0 pident , doc (showString "}")])
   PQ pident0 pident -> prPrec i 2 (concatD [prt 0 pident0 , doc (showString ".") , prt 0 pident])
   PInt n -> prPrec i 2 (concatD [prt 0 n])
   PFloat d -> prPrec i 2 (concatD [prt 0 d])
   PStr str -> prPrec i 2 (concatD [prt 0 str])
   PR pattasss -> prPrec i 2 (concatD [doc (showString "{") , prt 0 pattasss , doc (showString "}")])
   PTup patttuplecomps -> prPrec i 2 (concatD [doc (showString "<") , prt 0 patttuplecomps , doc (showString ">")])
   PC pident patts -> prPrec i 1 (concatD [prt 0 pident , prt 0 patts])
   PQC pident0 pident patts -> prPrec i 1 (concatD [prt 0 pident0 , doc (showString ".") , prt 0 pident , prt 0 patts])
   PDisj patt0 patt -> prPrec i 0 (concatD [prt 0 patt0 , doc (showString "|") , prt 1 patt])
   PSeq patt0 patt -> prPrec i 0 (concatD [prt 0 patt0 , doc (showString "+") , prt 1 patt])
   PRep patt -> prPrec i 1 (concatD [prt 2 patt , doc (showString "*")])
   PAs pident patt -> prPrec i 1 (concatD [prt 0 pident , doc (showString "@") , prt 2 patt])
   PNeg patt -> prPrec i 1 (concatD [doc (showString "-") , prt 2 patt])

  prtList es = case es of
   [x] -> (concatD [prt 2 x])
   x:xs -> (concatD [prt 2 x , prt 0 xs])

instance Print PattAss where
  prt i e = case e of
   PA pidents patt -> prPrec i 0 (concatD [prt 0 pidents , doc (showString "=") , prt 0 patt])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print Label where
  prt i e = case e of
   LIdent pident -> prPrec i 0 (concatD [prt 0 pident])
   LVar n -> prPrec i 0 (concatD [doc (showString "$") , prt 0 n])


instance Print Sort where
  prt i e = case e of
   Sort_Type  -> prPrec i 0 (concatD [doc (showString "Type")])
   Sort_PType  -> prPrec i 0 (concatD [doc (showString "PType")])
   Sort_Tok  -> prPrec i 0 (concatD [doc (showString "Tok")])
   Sort_Str  -> prPrec i 0 (concatD [doc (showString "Str")])
   Sort_Strs  -> prPrec i 0 (concatD [doc (showString "Strs")])


instance Print Bind where
  prt i e = case e of
   BIdent pident -> prPrec i 0 (concatD [prt 0 pident])
   BWild  -> prPrec i 0 (concatD [doc (showString "_")])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print Decl where
  prt i e = case e of
   DDec binds exp -> prPrec i 0 (concatD [doc (showString "(") , prt 0 binds , doc (showString ":") , prt 0 exp , doc (showString ")")])
   DExp exp -> prPrec i 0 (concatD [prt 4 exp])


instance Print TupleComp where
  prt i e = case e of
   TComp exp -> prPrec i 0 (concatD [prt 0 exp])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print PattTupleComp where
  prt i e = case e of
   PTComp patt -> prPrec i 0 (concatD [prt 0 patt])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ",") , prt 0 xs])

instance Print Case where
  prt i e = case e of
   Case patt exp -> prPrec i 0 (concatD [prt 0 patt , doc (showString "=>") , prt 0 exp])

  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print Equation where
  prt i e = case e of
   Equ patts exp -> prPrec i 0 (concatD [prt 0 patts , doc (showString "->") , prt 0 exp])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print Altern where
  prt i e = case e of
   Alt exp0 exp -> prPrec i 0 (concatD [prt 0 exp0 , doc (showString "/") , prt 0 exp])

  prtList es = case es of
   [] -> (concatD [])
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])

instance Print DDecl where
  prt i e = case e of
   DDDec binds exp -> prPrec i 0 (concatD [doc (showString "(") , prt 0 binds , doc (showString ":") , prt 0 exp , doc (showString ")")])
   DDExp exp -> prPrec i 0 (concatD [prt 6 exp])

  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x , prt 0 xs])

instance Print OldGrammar where
  prt i e = case e of
   OldGr include topdefs -> prPrec i 0 (concatD [prt 0 include , prt 0 topdefs])


instance Print Include where
  prt i e = case e of
   NoIncl  -> prPrec i 0 (concatD [])
   Incl filenames -> prPrec i 0 (concatD [doc (showString "include") , prt 0 filenames])


instance Print FileName where
  prt i e = case e of
   FString str -> prPrec i 0 (concatD [prt 0 str])
   FIdent pident -> prPrec i 0 (concatD [prt 0 pident])
   FSlash filename -> prPrec i 0 (concatD [doc (showString "/") , prt 0 filename])
   FDot filename -> prPrec i 0 (concatD [doc (showString ".") , prt 0 filename])
   FMinus filename -> prPrec i 0 (concatD [doc (showString "-") , prt 0 filename])
   FAddId pident filename -> prPrec i 0 (concatD [prt 0 pident , prt 0 filename])

  prtList es = case es of
   [x] -> (concatD [prt 0 x , doc (showString ";")])
   x:xs -> (concatD [prt 0 x , doc (showString ";") , prt 0 xs])


