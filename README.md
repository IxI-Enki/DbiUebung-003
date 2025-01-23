###### <p align="center"> DbiUebung-003 </p>

<div align="center">
  
  # PLSQL - Employee Fairness Check 

  - <div align="left"> Fertige Ausgabe: 
  
    > *Erst alle ( Hilfs- )*`FUNCTIONS` *kompilieren, dann kann die Ausgabe ausgeführt werden*!  
    </div>
    
    <img src="img/output.png" alt="output" width=100%>


</div>

  - <p align="left"> Code Snippets: </p>

    - # Funktionsaufruf / Ausgabe:
      ```SQL
      SELECT 
          e.ENAME                     as "Angestellter"
        , e.SAL                       as "Lohn"
        , EMP_FAIRNESS_CHECK(e.empno) as "Fairness-Check"
          FROM emp e JOIN emp e1 ON (e1.EMPNO = e.EMPNO) 
            ORDER by e.SAL;
      ```      


    - ## Emp-Fairness-Check-`FUNCTION`: 
      ```SQL
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
      ```
      ---

    - ### Returns sal des Nächst-best-verdienenden Angestellten:
      > ```SQL
      > CREATE or REPLACE 
      >                 FUNCTION
      >                         GET_NEXT_EMP_SAL( eSal NUMBER )
      > RETURN NUMBER
      > IS
      >     CURSOR v IS SELECT * FROM EMP WHERE SAL > eSal ORDER BY SAL
      >   ; temp EMP%ROWTYPE
      >   ; diff NUMBER := 0
      >   ;
      > BEGIN
      >     open v;
      >       IF EMP_WITH_HIGHER_SALS(eSal) > 0 THEN
      >         FETCH v INTO temp;
      >        
      >         IF v%FOUND THEN
      >           diff := temp.sal - eSal;
      >           return diff;
      >
      >         END IF;
      >         
      >       END IF;
      >     close v;
      >           RETURN diff;
      > END;   
      > ```

      ---

    - ### Returns sal von Employe anhand seiner EmpNo:
      > ```SQL
      > CREATE or REPLACE 
      >                  FUNCTION 
      >                           GET_SAL_FROM_EMPNO( eNo NUMBER )
      > RETURN NUMBER
      > IS
      >   sol NUMBER;
      > BEGIN
      >   SELECT SAL INTO sol FROM EMP WHERE eNo = EMPNO GROUP BY EMPNO, SAL;
      >   RETURN sol;
      > END;
      > ```

      ---
    - ### Returns MIN / MAX sal aller Employees
        > - Min:  
        > ```SQL
        > CREATE or REPLACE FUNCTION
        >                           EMP_MIN_SAL
        > -------------------------------------
        > RETURN NUMBER 
        > IS 
        >   sol NUMBER;
        > BEGIN
        >   SELECT MIN(sal)into sol FROM EMP;
        >   RETURN sol;
        > END;
        > ```

        > - Max:  
        > ```SQL
        > CREATE or REPLACE FUNCTION
        >                           EMP_MAX_SAL
        > -------------------------------------
        > RETURN NUMBER 
        > IS 
        >   sol NUMBER;
        > BEGIN
        >   SELECT MAX(sal)into sol FROM EMP;
        >   RETURN sol;
        > END;
        > ```

      ---
