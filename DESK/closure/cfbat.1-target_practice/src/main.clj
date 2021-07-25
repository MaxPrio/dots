(ns main)

; TARGET: {:name "string"} or {:name "string" :parts LIST_OF_PARTS }
;   LIST_OF_PARTS : (list {:size NUMBER :part TARGET } {}...{} )
;   NUMBER: relative size of the part, as to the other parts in the list. 

; abstract target definition
;----------------------------
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
  (list {:size 1 :part {:name "part-21"}}
        {:size 1 :part {:name "part-22"}}
        {:size 1 :part {:name "part-23"}}
        ))
; level 1 (parts of the target)
(def target-parts
  (list {:size 1 :part {:name "part-1"}}
        {:size 2 :part {:name "part-2" :parts target-parts2}}
        {:size 3 :part {:name "part-3" :parts target-parts3}}
        ))

; the head def
(def simple-target
  {:name "hobbit"
   :parts target-parts})

; target def (hobbit)
;--------------------------
(def target-hobbit
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
;--------------------------

; Size weighted, random choice of a target,
; from the givet 'list of parts'.
;--------------------------
(defn lucky [parts]
  " Size weighted, random choice of a target,
    from the givet 'list of parts'."
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

; If the given target has no parts,  return it's name,
; otherwise, give the parts to the 'lucky' function,
; and shoot the result subtarget .
;--------------------------
(defn shoot [target]
  " If the given target has no parts,  return it's name,
      otherwise, give the parts to the 'lucky' function,
      and shoot the result subtarget."
  (let [parts (:parts target)]
    (if (= parts nil)
      (:name target)
      (shoot (lucky parts)))))
;--------------------------

(shoot simple-target)
(shoot target-hobbit)
