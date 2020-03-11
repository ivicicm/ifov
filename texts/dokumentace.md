## Dokumentace k programu

#### Uživatelská část

Balík nabízí dva způsoby jak graficky znázornit konvexní obal obalu hodnot intervalové matice. V souboru `+interval_fov` se nachází zdrojové kódy pro MATLAB. 

Do instance třídy `FOV` se pomocí funkce  `insertMatrix` vkládají matice. Konvexní obal polí hodnot všech vložených matic se dostane pomocí její vlastnosti `Coordinates`. Bude ve formátu vektoru konvexních čísel, jejichž spojení popořadě hranami dá odhad konvexního obalu. `FOV` bere v konstruktoru jeden parametr - počet bodů ve výsledných souřadnicích.

Funkce `insertCornerMatrices` bere jako parametr intervalovou matici (je ji potřeba vložit jako dvě matice dolních a horních hranic intervalů) a instanci `FOV`. Do `FOV` vloží $2^{n(n-1)}$ matic, které odpovídají popsaným v `hledani_vlastniho_cisle.pdf`.

Třída `AngleMatrixGenerator` potřebuje v konstruktoru intervalovou matici. Po použití `generate` na instanci `FOV` do `FOV` vloží matice popsané v alternativním algoritmu v`hledani_vlastniho_cisle.pdf`.

Ve skriptu `example.m` je příklad použití výše popsaných funkcí a tříd na náhodné matici.

Pro matice typu $n \times  n$, kde $n \le 4$, dávají algoritmy výsledky do několika sekund. Pro $n = 5$  počítání trvá v řádu minut, pro $n = 6$ v řádu dnů. Na $n = 7$ je potřeba čekat desítky let. Odhady jsou zatím jen pro `insertCornerMatrices`, pro větší hodnoty jsem druhý postup nezkoušel ani odhadovat, ale určitě budou menší.

#### Implementace

Jen pro `AngleMatrixGenerator`. Funguje tak, že rekurzivně vygeneruje všechny možné matice, které by mohly ovlivnit podobu pole hodnot. Aby se některé matice nevkládaly do `FOV` dvakrát, z každé matice jde vygenerovat číselný kód, který slouží jako index do pole boolů. Hodnota na indexu v poli říká, jestli matice byla už vložena. Pro $n = 6$ má pole velikost 1GB, pro vyšší hodnoty by se třída neměla používat (velikost od 4TB). Počet vložených matic je pro $n$ vždy stejný. Bylo by možné generovat matice přímo bez duplicit, bez nutnosti používání pole, ale kód by byl složitější.