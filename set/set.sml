fun uniqueElements list =
    let fun removeDuplicates xs accum =
            case xs of
                [] => accum
              | x::xs' => if List.exists (fn e => e = x) xs'
                          then removeDuplicates xs' accum
                          else removeDuplicates xs' (x::accum)
    in
      removeDuplicates (List.rev list) []
    end

fun joinList elementToString separator list =
    let fun combine (element, accum) =
            if accum = ""
            then elementToString element
            else (elementToString element) ^ separator ^ accum
    in
      List.foldl combine "" (List.rev list)
    end


signature SET =
sig
  type ''a set
           
  val emptySet : ''a set
  val hasElement : ''a set -> ''a -> bool
  val addElement : ''a set -> ''a -> ''a set
  val union : ''a set -> ''a set -> ''a set
  val fold : (''a * 'b -> 'b) -> 'b -> ''a set -> 'b
  val fromList : ''a list -> ''a set
  val toString : (''a -> string) -> ''a set -> string
end


structure Set :> SET =
struct
  datatype ''a set = EmptySet
                   | ListSet of ''a list
                                  
  val emptySet = EmptySet
                     
  fun hasElement set element =
      case set of
          EmptySet => false
        | ListSet lst => List.exists (fn x => x = element) lst
                                     
  fun addElement set element =
      if hasElement set element
      then set
      else case set of
               EmptySet => ListSet [element]
             | ListSet lst => ListSet (element::lst)
                                      
  fun union a b =
      case (a,b) of
          (_, EmptySet) => a
        | (EmptySet, _) => b
        | (ListSet xs, ListSet ys) => ListSet (uniqueElements (xs @ ys))
                                              
  fun fromList lst =
      List.foldl (fn (a,b) => addElement b a)
                 EmptySet
                 (List.rev lst)

  fun fold reducer initial set =
      case set of
          EmptySet => initial
        | ListSet xs => List.foldl reducer initial xs

  fun toString elementToString set =
      case set of
          EmptySet => "{ }"
        | ListSet xs => "{ " ^ (joinList elementToString ", " xs) ^ " }"
end




val empty = Set.emptySet;

val one = Set.addElement empty 1;
val oneAndTwo = Set.addElement one 2;

val three = Set.addElement empty 3;
val threeAndFour = Set.addElement three 4;

val oneThroughFour = Set.union oneAndTwo threeAndFour;
Set.hasElement oneThroughFour 0;  (* false *)
Set.hasElement oneThroughFour 1;  (* true *)
Set.toString Int.toString oneThroughFour;  (* "{ 2, 1, 3, 4 }" *)

fun multiplesOf n max =
    let fun buildMultiples curr accum =
            if curr >= max
            then accum
            else buildMultiples (curr + n) (curr::accum)
    in
      Set.fromList (buildMultiples n [])
    end;

val intSetSum = Set.fold (fn (a,b) => a + b) 0;

intSetSum (Set.union (multiplesOf 3 1000) (multiplesOf 5 1000));
