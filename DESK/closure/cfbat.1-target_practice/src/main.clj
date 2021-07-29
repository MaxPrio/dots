(ns main)

; TO DO
;-------
; groups (of similar targets)
;  DONE- include in the target data structure discription
;  DONE- include in exaple target defs
;  - impliment functions: normalize-parts ; gen-group.
;  - impliment functions: gen-group-TYPE.
;      -TYPE 'name-key' ('left-right' 'upper-lower' 'front-back')
;      -TYPE 'number'
;
;
; ===============================
;
; DESCRIPTION:
; It's a game of shooting a target.
; You don't actualy take an aim and shoot.
; You just, so to say, throw dice, and same random part of the target is hit.
; If you think that's no fun, imagine the target is Elijah Wood with anshaved legs.
;
; IMPLEMENTATION:
; general discription:
;
; A target def, is somthing that has name, and may have parts.
; A part def, is somthing that has size,
; and a part itself, which is a target.
;
; Instead of a standard definition of a single part,
; there may be a definition that evaluaties to a group of parts.

; For example, a group of parts definition, may be a definition,
; with a key in the name, that refers a predifined group of names.
; ( left-somthing evals to left-somthing and right-somthing )
; or
; More generally, a group of parts definition
; may be, just a prosidure pointer and parameters. 
;
; Shooting a target:
;-------------------
; 1.Shoot the target:
;   2.If the target has no parts, return the name of the lucky target. END
;   3.Otherwise process parts:
;     3.1.If tere is any group of parts defs, eval them.
;     3.2.Make a (size weighted) random choice of a part (a subtarget).
; 1.Shoot the target.

; TARGET DATA STRACTURE
;-----------------------
; TARGET: a map, like {:name "string"}
;                      or/and
;                      {:name "string" :parts LIST_OF_PARTS }
;   LIST_OF_PARTS : a list of maps, like {:size NUMBER :part TARGET }
;                                        or/and
;                                        {:group GROUP_TYPE PARAMS }
;   NUMBER: relative size of the part.
;   GROUP_TYPE: a PROCIDURE pointer.
;   PROCIDURE: returns a FLAT_LIST_OF_PARTS.
;   FLAT_LIST_OF_PARTS: a list of maps, like {:size NUMBER :part TARGET }
;   PARAMS: parameters for the PROCIDURE.

; ===============================

; Targets definitions
;----------------------------

; exaple target
;----------------------------

; (it may be more handy to def each list of parts separatly)

; level 3 (parts of the part-3 of the part-3)
(def target-parts33
  (list {:size 1 :part {:name "part-331"}}
        {:size 1 :part {:name "part-332"}}
        {:size 1 :part {:name "part-333"}}
        ))
; level 2 (parts of the part-3)
(def target-parts3
  (list {:size 1 :part {:name "part-31"}}
        {:size 1 :part {:name "part-32"}}
        {:size 2 :part {:name "part-33" :parts target-parts33}}
        ))
; level 2 (parts of the part-2)
(def target-parts2
  (list {:size 1 :part {:name "feelling-part-21"}}
        {:size 1 :part {:name "smelling-part-22"}}
        {:size 1 :part {:name "fimale-part-22"}}
        {:size 1 :part {:name "part-22"}}
        {:size 1 :part {:name "part-23"}}
        ))
; level 1 (parts of the target)
(def target-parts
  (list {:size 1 :part {:name "left-part-1"}}
        {:size 1 :part {:name "front-part-1"}}
        {:size 1 :part {:name "upper-part-1"}}
        {:size 1 :part {:name "male-part-1"}}
        {:size 2 :part {:name "part-2" :parts target-parts2}}
        {:size 3 :part {:name "part-3" :parts target-parts3}}
        ))

; the root target
(def exaple-target
  {:name "hobbit"
   :parts target-parts})

; hobbit
;--------------------------
(def hobbit
  {:name "hobbit"
   :parts (list {:size 10
                   :part {:name "torso"
                          :parts (list {:size 1
                                         :part {:name "chest"}}
                                        {:size 1
                                         :part {:name "stamock"}})}}
                 {:size 3
                  :part {:name "head"}}
                 {:size 2
                  :part {:name "arm"}}
                 {:size 3
                  :part {:name "leg"}})})

; Generating groups of parts
;--------------------------

; for debuging
(def dummy-list-of-parts
  (list {:size 10 :part {:name somename1}}
        {:size 10 :part {:name somename2}}
        {:size 10 :part {:name somename3}}
        {:size 10 :part {:name somename4}}
        {:size 10 :part {:name somename5}}))

;--------------------------
; If a target in a part def has name including one of the words defined in this lists,
; then similar parts defs needs to be generated for all the words in the same list.
(def group-name-keys 
  (list (list left right)
        (list upper lower)
        (list front back)
        (list male fimale)
        (list seeing hearing smelling feeling tasting))

(defn gen-group-by-name-key [in-part]
  ())

;--------------------------
(defn gen-group-by-number [in-part]
  ())

;--------------------------
(def gen-group-functions
  (list gen-group-by-name-key
        gen-group-by-number))

(defn gen-group-dummy [in-part]
  "Expects a group of parts def.
   Returns alist of parts, or nil"
  dummy-list-of-parts)

(defn gen-group [in-part]
  ())
;--------------------------
(defn normalize-parts-dummy [in-parts]
  "Expects a list of parts, that may include group-of-parts definitions.
   Riturns a list of standart parts defintions."
  dummy-list-of-parts)

(defn normalize-parts [in-parts]
  "Expects a list of parts, that may include group-of-parts definitions.
   Riturns a list of standart parts defintions."
  (loop [[ cr-in-part & left-in-parts] in-parts
         out-parts '()]
    (if (empty? left-in-parts) out-parts
      (let [out-group (gen-group cr-in-part)]
        (if (= out-group nil)
          (recur left-in-parts
                 (cons cr-in-part out-parts))
          (recur left-in-parts
                 (into out-parts out-group)))))))

; Shooting
;--------------------------
(defn lucky [parts]
  " Makes a, size weighted, random choice of a part def,
    Expects a normalized list of parts
    Returns the part's target"
  (let [hitpoint (rand
                   (reduce +
                     (map :size parts)))]
   (loop [[hd & tl] parts
          cr_sum (:size hd)]
     (if (< cr_sum
            hitpoint)
       (recur tl
              (+ cr_sum
                 (:size (first tl))))
       (:part hd)))))
;--------------------------

(defn shoot [target]
  " If the given target has no parts,  return it's name,
      otherwise, give the parts to the 'lucky' function,
      and shoot the result subtarget."
  (let [parts (:parts target)]
    (if (= parts nil)
      (:name target)
      (shoot
        (lucky
          (normalize-parts  parts))))))
;--------------------------

;(shoot simple-target)
;(shoot target-hobbit)
