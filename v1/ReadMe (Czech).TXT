SoilMod - Soil Management & Growth Control (v1.2.0)

Mod pro funkci vyžaduje:

- PDAMod v2.0.2 (or newer) -

http://fs-uk.com/mods/view/34554


Popis

SoilMod při správném vložení do mapy rozšiřuje hru o následující:

- Vlastní kontrola růstu s možností okamžitého růstu nezávisle na době hraní.
- Rozšířené použití prostředku(vápna) pro regulaci stavu půdního ph.
- Organické hnojivo(hnůj) je třeba zaorat pro maximální možný efekt
- Běžné šíření náletových plevelných rostlin a jejich hubení pomocí herbicidních přípravků.
- A několik dalších efektů.

UPOZORNĚNÍ!

Mod nemusí splňovat přesně to co od něj vy sami očekáváte nebo chcete aby dělal. Buďte proto prosím otevřeni jiným názorům a konstruktivní kritice nebo návrhům jak zlepšit následující verze.

POZOR! NUNTNO PŘEČÍST!

POZNÁMKA
Tuto část můžete přeskočit pokud již máte zkušenosti se SoilModem verze 1.0.0 a vše už máte upraveno a připraveno pro správnou funkci SoilModu

Co vyžaduje SoilMod pro svou správnou funkci.

SoilMod(SoilManagement.zip) bude pracovat pouze na mapách, které byly pro jeho použití upraveny.
V balíčku naleznete veškeré potřebné soubory(i3d a lua) a textury nutné pro úpravu map.
Pro správnou implementaci modu je nutné mít znalosti použití textového editoru(např. NotePad++) či podobného a orientaci v textu u souborů typu i3d a lua.
Při implementaci do mapy je nejtěžší částí správné přidání řádků určujících materiál a textury do správné sekce v souboru i3d. Jak na to je podrobně popsáno v „,maps – Isntruction.txt“.

Nezapomeňte!
Než začnete s jakoukoli editací mapy, vytvořte si zálohu původních souborů, případně mapy(poslední funkční pracovní podoba).
Pro případ, že se stane cokoli a dojde k nějaké kolizi nebo chybě, nebudete se tak muset vracet na úplný začátek práce.
Uvědomte si, že standardní nebo chcete-li normální velikost mapy je „x1“(rozměr 4096x4096).
Některé mapy mají velikost menší „x.25“ nebo naopak větší „x4“, proto kopírujte pouze soubory odpovídající rozměrům vámi upravované mapy.

Další změnou, kterou je třeba provést je úprava scriptu mapy, SampleModMap.lua
Ve složce „SampleModMap – Additions.LUA“ naleznete vzorový script nutná pro správnou funkci modu.
Tento script obsahuje jasně a viditelných a odlišených 5 příkazových odstavců vztahující se k SoilModu.
Pokud máte mapu pracující na tomto scriptu, pak stačí pouze vyměnit script stávající za script ze složky a v jeho textu změnit cestu, případně jméno i3d souboru vaší mapy.
V případě, že vaše mapa používá jakýkoli jiný script(buď jiného jména, či rozšířený o další funkce, musíte kopírovat jednotlivé příkazové řádky a odstavce do stejné či relativní pozice a příkazům odpovídající přiloženému scriptu.

Jak správně používat SoilMod ve hře.

POZOR!
Vzhledem k tomu, že existuje celá řada modů, které nějakým podobným způsobem přibližují standardní hru LS/FS13 k realitě je možné, že dojde ke kolizi s těmito dalšími mody.
Proto je pro správnou funkci SoilModu nezbytné odstranit tyto mody ze složky mods a případně i mapy.

Pakliže jste již upravili svojí mapu pro použití SoilModu, je nyní třeba už pouze umístit do složky mods následující soubory:

SoilManagement.ZIP
PDAModPlugin_SoilCondition.ZIP

Nezapomínejte, že tyto dva soubory ještě vyžadují použití dalšího modu a to sice  PDAMod.ZIP na jehož nejnovější verzi naleznete odkaz hned na začátku textu kde je označený jako „Mod pro funkci vyžaduje:“

Nyní už můžete tedy přejít k samotné hře.
Je pravděpodobné, že budete moci pokračovat ve vámi uložené pozici(savegame), ale nejdříve si řádně ověřte, pomocí výpisu z konzole, že vše se načítá a funguje správně.

UPOZORNĚNÍ!
Pokud jste dosud ještě nepoužili PDA mod, není proto nakonfigurovaný a v log.txt nebo ve výpisu z konzole se objeví chybová hláška, že nebylo možné načíst konfigurační soubor PDAModu, toto je naprosto normální chování a po nakonfigurování, případně pouhém uložení rozehrané pozice se tento soubor automaticky vytvoří a chybová hláška sama zmizí, na funkci ve hře to nemá jinak žádný vliv.

Stav půdy -  PDA MOD plugin
První věcí kterou by jste měli zjistit je to, že v PDA ve hře přibude jedna obrazovka navíc s informacemi o stavu půdy.
Pokud se vám tyto informace vůbec nezobrazují pak jste zapomněli vložit do složky mods právě plugin, který je součástí balíčku.
V případě, že se obrazovka objeví, ale informace jsou neúplné nebo zmatečné, dochází k nějaké kolizi, buď nejsou správně vloženy příkazové odstavce do scriptu a nebo je to možná kolize s nějakým vámi používaným modem či scriptem daného modu. V tomto případě je potřeba otevřít si soubor log.txt, najít případnou chybu či kolizi a následně tuto odstranit nebo opravit.

Pokud obrazovka funguje správně, zobrazuje informace o stavu půdy vztahující se vždy k rozloze 10x10, tedy zobrazuje čtverec o straně 10 metrů v jehož středu se právě nacházíte. Pro lepší orientaci nebo použití kompasu se zobrazují ještě souřadnice GPS, tedy přesná poloha kde sena mapě nacházíte.
Druhá stránka této přidané obrazovky pak obsahuje informace o tom jaký typ syntetického(průmyslového) hnojiva a typu herbicidního přípravku je vhodné pro danou plodinu použít a současně typu hnojiva a herbicidního přípravku, jehož použití se máte k dané plodině zásadně vyvarovat.
Použití nesprávného typu herbicidního přípravku má negativní vliv na plodinu a takto zasažené plodiny buď výrazně zpomalí svůj růst a nebo dojde k jejím zničení.


Fáze růstu a tzv. „havarování“(zničení, hniloba, uvadnutí) plodiny
Důvod nebo smysl vytvoření tohoto modu byl v jasném požadavku. Vědět přesně kdy se co stane a v případě, že budu potřebovat, mít možnost do procesu zasáhnout.
Proto každá fáze růstu končí a začíná o půlnoci času ve hře, tedy co jeden den ve hře, to jedna fáze růstu.
Zobrazovaná indikace(objeví se uprostřed, na horní hraně obrazu s údajem v %)ukazuje v jakém stavu se zpracovávají jednotlivé fáze a pochody v době růstu. Toto je důležité pro vyloučení tzv. „zamrzání“ hry a nebo latence odezvy síťového připojení, známého také jako „lag“.

POZOR!
Havarování(vadnutí, hniloba) plodin je u SoilModu standardně aktivní, je jí, ale možné odstranit, jak na to naleznete ve složce "SampleModMap – Additions.LUA".
V zájmu zachování co největšího přiblížení se realitě se, ale nedoporučuje tuto funkci odstraňovat.

Co se děje během růstového cyklu.
Plodiny zvyšují svůj růst o jednu fázi, ale to pouze v případě, že nedošlo k použití nevhodného přípravku na hnojení nebo hubení plevele(herbicid).

Nezpracovaná(neodvezená, neslisovaná) sláma nebo seno jsou o jednu fázi sníženy, dochází k jejich rozkladu.

Do půdy nezapracované vápno, kejda(močůvka, digestát) přechází do půdy(textury zmizí), ovšem s nižším účinkem než při zapracování do půdy.

Herbicidem zasažené náletové plevele pomalu uvadají a rozkládají se.

Vlhkost(znázorněna ztmavnutím půdy/terénu) po aplikaci hnojiv nebo herbicidů se odpaří/vsákne a půda/terén opět zesvětlá.

Vliv půdního ph na výnosy a použití vápna.
Vliv půdního ph na výnos sklizně je novým aspektem, který přináší tento mod.
Informace naleznete prostřednictvím PDA a pamatujte na to, že se vždy zobrazují informace pouze ze čtverce o straně 10m, čili není to z celé rozlohy pole.
Podmínkou vysokého výnosu je právě stav ph, které by mělo být pro dosažení maximálního výnosu neutrální. Jakákoli výchylka buď do kyselého nebo alkalického(zásaditého) stavu se odrazí na výši výnosu.
Jaká jsou rozmezí půdního ph ve vztahu na výnos ukazuje následující tabulka, kde 100% znamená maximální výnos daný hrou(dle zvolené obtížnosti hry, případně použití MoreRealistic).
Pamatujte, že čím nižší číslo u ph, tím je půda kyselejší, čím vyšší číslo, tím je zásaditější(alkalická, „hořká“)







0 – 5 – 5%

5,1 – 5,6 – 50%

5,7 – 6,1 – 75%

6,2 – 6,6 – 95%

6,7 – 7,3 – 100%

7,4 – 7,9 – 95%

8 – 8,5 – 90%

8,6 – 9 – 80%

9,1 a vyšší  - 70%

Pro zvýšení ph používejte vápno, má vysoké ph(12,5) je tedy silně zásadité(alkalické) a snižuje kyselost půdy. Pro aplikaci vápna je možné použít standardní stroje a zařízení(rozmetadla hnojiv, nikoli rozmetadla hnoje nebo cisterny pro aplikaci kejdy). SoilMod umožňuje přepínat mezi jednotlivými přípravky.
Děje se tak za použití klávesy „O“ a o jejím použití a zvoleném přípravku se zobrazuje informace v nápovědě(F1).
Pro vyšší účinek je vhodné vápno buď zaorat nebo pomocí kultivátoru zapravit do půdy, takto zapravené vápno zvyšuje ph o 2 stupně, volně ponechané vápno pouze o 1,3 stupně.
Vzhledem k technickým omezením hry zvyšuje vápno ph více, ve větších skocích než se zdá být reálné.

Organická hnojiva – hnůj, kejda(močůvka), digestát
Někteří uživatelé a hráči, kteří chtějí dosáhnout co největšího možného přiblížení se realitě měli požadavek, aby bylo použití organických hnojiv nějak v hře upraveno, zvláště pak, aby aplikace hnoje a jeho využití půdou byla i dále něčím podmíněna.
Právě toto přináší SoilMod.

Pokyny pro správné použití hnojiv v SoilModu.
Aplikujte kejdu(digestát) / hnůj na půdu.
Pro maximální efekt hnůj zaorejte, zvýší stupeň prohnojení půdy na maximum, tedy na 3 stupeň.
Zakultivování hnoje do půdy je méně účinná, zvyšuje stupeň prohnojení půdy jen o 1 stupeň.
Při použití kejdy(močůvky, digestátu) zvyšuje orba nebo kultivace stupeň prohnojení půdy opět pouze o 1 stupeň.
Volně ponechaná(nezapracovaná do půdy)kejda(močůvka, digestát) přejde do půdy, ale s ještě nižším účinkem.
Nazapracovaný hnůj, ponechaný volně na poli se po třech dnech rozloží(textura hnoje zmizí)bez jakéhokoli účinku a prohnojení půdy. To se týká i jakéhokoli prostoru mimo pole, tzn., že pokud se vám nějakým způsobem dostane hnůj mimo pole, nezaoráte ho, tak zmizí až po třech dnech, nikoli hned o půlnoci jako vše ostatní.



Syntetická(průmyslová) hnojiva
Použití pouze v době vegetačního růstu.

Používání organických hnojiv je sice nejlepší, ale jsou situace kdy se organického hnojiva nedostává a pak nastupují právě syntetická(průmyslová) hnojiva.
Tato hnojiva budou mít, ale účinek pouze v případě, že jsou rostliny ve fázi růstu, použití v jakékoli jiné době(v době zralosti nebo na neoseté pole) nebude mít žádný efekt, protože je rostliny nepřijmou.
V pokročilém režimu(standardní nastavení SoilModu) je na výběr ze tří druhů syntetických hnojiv(typ A, B a C).
Každá plodina pro svůj růst potřebuje specifické hnojivo. Informace o plodině a vhodném typu hnojiva naleznete v PDA.
Pro aplikaci syntetických hnojiv lze použít jakékoli standardní vybavení umožňující aplikaci jak kapalných(vyjma aplikátorů kejdy) nebo práškových hnojiv.
Mezi jednotlivými typy lze opět přepínat pomocí klávesy „O“ se zobrazením v nápovědě.

Plevel a použití herbicidních přípravků.
Plevel se bude při použití SoilModu objevovat pravidelně na polích, protože plevel se šíří náletově, čili vzduchem.
K jeho odstranění lze použít jak orbu, tak kultivaci, ovšem jsou případy, kdy tyto operace nelze provést. To se týká hlavně oseté půdy a rostlin ve fázi růstu. V takovém případě je třeba použít selektivní herbicid.
Opět platí to co u hnojiv, lze vybírat ze tří druhů herbicidních přípravků(typ A, B a C) a opět každá plodina snáší určitý typ přípravku.
Informace o vhodnosti použití toho kterého typu přípravku naleznete v PDA.
Jak už bylo výše popsáno, použití nesprávného typu přípravku bude mít negativní vliv na plodinu, který může vést až k uhynutí rostlin.
Pro aplikaci lze opět použít standardní vybavení a opět lze vybírat/přepínat pomocí klávesy „O“.
Po zasažení plevele herbicidem dochází k jeho postupnému vadnutí(trvá několik dnů) a po aplikaci herbicidnícho přípravku už by se další plevel neměl objevit.

Problémy a chyby.
Pokud při používání SoilModu narazíte na problém nebo chybu, prosím informujte nás o tom na následujících stránkách:

http://fs-uk.com

Najdětě prosím odpovídající téma s podporou pro SoilMod a chybu zde popište.

Známé chyby a kolize
Po aplikaci hnojiva nebo herbicidu dojde k „přepnutí“ na jiný typ hnojiva nebo herbicidu než byl na půdě původně použit.

Je možné aplikovat kejdu těsně před sklizní a dojde ke zvýšení výnosu a prohnojení půdy.

Při doplňování hnojiva nebo herbicidního přípravku se typ přípravku opět vrátí na výchozí typ A bez rozdílu na jaký typ byl původně nastaven.
Tento problém je řešitelný tím způsobem, že se do mapy osadí pro každý typ přípravku separátní nádrž, nebudete tedy mít jednu nádrž nebo místo na doplňování hnojiv a herbicidů, ale několik.

Přepnutí do „lehkého“ režimu lze províst jen úpravou scriptu.

Omezení
Následující soubory, SoilManagement.ZIP, PDAMod.zip a PDAModPlugin_SoilCondition.ZIP NESMÍ být užité v jakémkoli jiném modu.
To neplatí pouze v případě, že se jedná o tzv. ModPack, tedy součásti nutné k bezproblémovému použití například mapy. A původní součty hash jsou v neporušeném stavu, nedošlo tedy k editaci modu.

Prosím neukládejte mod na jakákoli jiná uložiště, to může udělat autor modu v případě potřeby sám!
Respektujete tak něčí práci a přání, je to elementární slušností. Uvědomte si, že tuto práci dostáváte zcela zdarma a bez omezení pro svoje vlastní použití ve hře.

Zachovávejte proto prosím vždy jen originální odkaz pro možné stažení modu.

Kredity
Script: Decker_MMIV.
Grafika: KaosKnite, JakobT, GIANTS, Decker_MMIV a další.
Překlad "DE": JakobT, webalizer.
Překlad "RU": Gonimy_Vetrom, VAHA.
Překlad "CZ": KingFrame, Albi.
Překlad "FR": Marxtai, Dural.
