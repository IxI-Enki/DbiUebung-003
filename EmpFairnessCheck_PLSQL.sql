
--                     P L S Q L   Ü B U N G  -  R I T T                     --
-- =============================== 20.1.2025 =============================== --
                                                           set serveroutput on;
-- ‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗ Angabe : To do ‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗‗ --


/* Ⅰ.)  ▻  S C H U L Ü B U N G          

  Schreiben Sie eine Stored Function names EMP_FAIRNESS_CHECK, welche zu große 
    Gehaltssprünge in der EMP-Tabelle erkennt
    
  Wenn ein Mitarbeiter mehr als 1500€ mehr verdient als der nächst-bestverdienende Mitarbeiter, 
    so soll der Funktion den Wert "unfair" zurückgeben, ansonsten "fair"

‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/

/* ▻   U S E :  Ausgabe                     EMP_FAIRNESS_CHECK( empNo NUMBER );
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/
SELECT 
    e.ENAME                     as "Angestellter"
  , e.SAL                       as "Lohn"
  , EMP_FAIRNESS_CHECK(e.empno) as "Fairness-Check"
    FROM emp e JOIN emp e1 ON (e1.EMPNO = e.EMPNO) 
      ORDER by e.SAL;

--———————————————————————————————————————————————————————————————————————————--

/* ▻   C R E A T E   Function :           EMP_FAIRNESS_CHECK( empNo in NUMBER )
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/
                                           -- DROP FUNCTION EMP_FAIRNESS_CHECK;
CREATE or REPLACE 
                FUNCTION
                        EMP_FAIRNESS_CHECK ( eNo NUMBER ) 
RETURN VARCHAR
IS
    sol VARCHAR(20)
  ; diff NUMBER := 0
  ;
BEGIN
  SELECT GET_NEXT_EMP_SAL(GET_SAL_FROM_EMPNO(eNo)) INTO diff;
    
    IF diff < 1500 THEN 
      sol := 'fair';
    ELSE
      sol :='unfair';
    END IF;

    IF GET_SAL_FROM_EMPNO(eNo) = EMP_MAX_SAL THEN
      sol := 'Bestverdiener';
    END IF;

  RETURN sol;
END;
/
--———————————————————————————————————————————————————————————————————————————--



/* ▻    N  O  T  I  Z  E  N    zu    Ⅰ.                                      --
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/
                                              -- SELECT GET_NEXT_EMP_SAL(3000);
CREATE or REPLACE 
                FUNCTION
                        GET_NEXT_EMP_SAL( eSal NUMBER )
RETURN NUMBER
IS
    CURSOR v IS SELECT * FROM EMP WHERE SAL > eSal ORDER BY SAL
  ; temp EMP%ROWTYPE
  ; diff NUMBER := 0
  ;
BEGIN
    open v;
      IF EMP_WITH_HIGHER_SALS(eSal) > 0 THEN
        FETCH v INTO temp;
        
        IF v%FOUND THEN
          diff := temp.sal - eSal;
          return diff;

        END IF;
        
      END IF;
    close v;
          RETURN diff;
END;    
/

/* ▻  GET_SAL_FROM_EMPNO( eNo NUMBER )
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/
                                            -- SELECT GET_SAL_FROM_EMPNO(7900);
CREATE or REPLACE 
                FUNCTION 
                        GET_SAL_FROM_EMPNO( eNo NUMBER )
RETURN NUMBER
IS
  sol NUMBER;
BEGIN
  SELECT SAL INTO sol FROM EMP WHERE eNo = EMPNO GROUP BY EMPNO, SAL;
  RETURN sol;
END;
/

/* ▻  EMP_WITH_LOWER_SALS( esal NUMBER )
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/
                                            -- select EMP_WITH_LOWER_SALS(950);
CREATE or replace 
                Function 
                        EMP_WITH_LOWER_SALS( esal NUMBER )
RETURN NUMBER
IS
    counter NUMBER := 0
  ; CURSOR v IS SELECT * FROM EMP WHERE SAL < esal ORDER BY SAL
  ; tV EMP%ROWTYPE
  ;
BEGIN
  OPEN v;
    LOOP 
      FETCH v INTO tV;
      IF v%FOUND THEN
        counter := counter + 1;
      END IF;
      EXIT WHEN v%NOTFOUND;  
    END LOOP;
  CLOSE v;
  RETURN counter;
END;
/

/* ▻  EMP_WITH_HIGHER_SALS( esal NUMBER )
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/
                                          -- select EMP_WITH_HIGHER_SALS(4000);
CREATE or replace 
                Function
                        EMP_WITH_HIGHER_SALS( esal NUMBER )
RETURN NUMBER
IS
    counter NUMBER := 0
  ; CURSOR v IS SELECT * FROM EMP WHERE SAL > esal ORDER BY SAL DESC
  ; tV EMP%ROWTYPE
  ;
BEGIN
  OPEN v;
    LOOP 
      FETCH v INTO tV;
      IF v%FOUND THEN
        counter := counter + 1;
      END IF;
      EXIT WHEN v%NOTFOUND;  
    END LOOP;
  CLOSE v;
  RETURN counter;
END;
/

/* ▻  EMP_MIN_SAL
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/
                                                         -- SELECT EMP_MIN_SAL;
CREATE or REPLACE FUNCTION
                          EMP_MIN_SAL
-------------------------------------
RETURN NUMBER 
IS 
  sol NUMBER;
-- - - - - - - - - - - - --
BEGIN
  SELECT MIN(sal)into sol FROM EMP;
  RETURN sol;
END;
/

/* ▻  EMP_MAX_SAL
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾*/
                                                         -- SELECT EMP_MAX_SAL;
CREATE or REPLACE FUNCTION
                          EMP_MAX_SAL
-------------------------------------
RETURN NUMBER 
IS 
  sol NUMBER;
-- - - - - - - - - - - - --
BEGIN
  SELECT MAX(sal)into sol FROM EMP;
  RETURN sol;
END;
/
--———————————————————————————————————————————————————————————————————————————--