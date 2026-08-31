--  dfa_minimization.ads
--  Package specification for DFA minimization using Moore's algorithm.
--  Ada 2023 (ISO/IEC 8652:2023) implementation.

with Ada.Containers.Doubly_Linked_Lists;
with Ada.Containers.Vectors;
with Ada.Containers.Hashed_Sets;

package DFA_Minimization is

   -- Custom types for DFA components
   type State is range 0 .. Integer'Last;
   type Symbol is range 0 .. 255;

   -- Sets for states and symbols
   package State_Sets is new Ada.Containers.Hashed_Sets (
      Element_Type => State,
      Hash => Ada.Containers.Hash_Type'Mod,
      Equivalent_Elements => "=");
   use State_Sets;

   package Symbol_Sets is new Ada.Containers.Hashed_Sets (
      Element_Type => Symbol,
      Hash => Ada.Containers.Hash_Type'Mod,
      Equivalent_Elements => "=");
   use Symbol_Sets;

   -- Transition function: maps (State, Symbol) to State
   type Transition_Map is array (State range <>, Symbol range <>) of State;

   -- DFA type
   type DFA (Num_States, Num_Symbols : Natural) is record
      States      : State_Sets.Set;
      Alphabet    : Symbol_Sets.Set;
      Transition : access Transition_Map;
      Initial     : State;
      Final       : State_Sets.Set;
   end record;

   -- Partition: a set of state sets
   package State_Set_Vectors is new Ada.Containers.Vectors (
      Index_Type => Natural,
      Element_Type => State_Sets.Set);
   use State_Set_Vectors;

   type Partition is access State_Set_Vectors.Vector;

   -- Exceptions
   Empty_DFA_Error         : exception;
   Invalid_Transition_Error : exception;
   No_Symbols_Error        : exception;
   State_Not_Found_Error   : exception;

   -- Minimizes a DFA using Moore's algorithm
   function Minimize (Input_DFA : DFA) return DFA
     with Pre  => Input_DFA.States.Length > 0 and Input_DFA.Alphabet.Length > 0,
          Post => Minimize'Result.States.Length <= Input_DFA.States.Length,
          Global => null;

   -- Helper: Creates initial partition (accepting vs non-accepting states)
   function Initial_Partition (DFA_Input : DFA) return Partition
     with Pre  => DFA_Input.States.Length > 0,
          Post => Initial_Partition'Result.Element(0).Length > 0 orelse
                 Initial_Partition'Result.Element(1).Length > 0,
          Global => null;

   -- Helper: Refines a partition using Moore's algorithm
   function Refine_Partition (
      Current_Partition : Partition;
      DFA_Input         : DFA) return Partition
     with Pre  => Current_Partition.Length > 0 and DFA_Input.States.Length > 0,
          Post => Refine_Partition'Result.Length >= Current_Partition.Length,
          Global => null;

   -- Helper: Checks if two partitions are equivalent
   function Partitions_Equal (Left, Right : Partition) return Boolean
     with Global => null;

   -- Helper: Validates a DFA (checks for undefined transitions)
   procedure Validate_DFA (DFA_Input : DFA)
     with Pre  => DFA_Input.States.Length > 0,
          Post => True,
          Global => null;

   -- Helper: Checks if a state is in the final set
   function Is_Final (State_To_Check : State; DFA_Input : DFA) return Boolean
     with Pre  => DFA_Input.States.Contains (State_To_Check),
          Global => null;

   -- Helper: Gets the transition for a (State, Symbol) pair
   function Get_Transition (
      Current_State : State;
      Input_Symbol  : Symbol;
      DFA_Input     : DFA) return State
     with Pre  => DFA_Input.States.Contains (Current_State) and
                  DFA_Input.Alphabet.Contains (Input_Symbol),
          Global => null;

end DFA_Minimization;
