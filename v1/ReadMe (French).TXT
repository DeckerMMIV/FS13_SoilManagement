SoilMod - Soil Management & Growth Control (v1.2.0)

Mods supplémentaires requis:
- PDAMod v2.0.2 (ou plus récent) - http://fs-uk.com/mods/view/34554


Description du mod

'SoilMod' est un mod, destiné aux maps qui ont été correctement préparées, qui ajoute:
- une croissance personnalisée, qui suit l'échelle de temps du jeu,
- une utilité pour la chaux, puisque la notion de pH est maintenant incluse,
- la nécessité de cultiver/labourer la terre après avoir étendu du fumier pour que ça fasse effet,
- la propagation automatique des mauvaises herbes et l'usage d'herbicide,
- et quelques autres effets.

NOTE! Ce mod ne fait peut-être pas les choses exactement comme vous le pensez/souhaitez. S'il vous plait, gardez l'esprit ouvert et donnez des critiques constructives afin de nous aider à améliorer le mod.


Comment préparer la map -- LECTURE REQUISE! --

(NOTE: Vous pouvez ignorer cette partie si vous l'avez déjà fait pour une version ultérieure à 1.x.x du mod)

Le "SoilManagement.ZIP" fonctionnera SEULEMENT pour les maps qui ont été préparées correctement. Des additions à des fichiers .I3D et .LUA de votre map sont requises, et celles-ci sont incluses dans le dossier que vous téléchargez.

Nous assumons que vous savez utiliser un éditeur de texte, par exemple Notepad++ ("Notepad Plus Plus") ou autre, et que vous êtes capables de travailler avec des fichiers .I3D et .LUA.

Préparation de votre map.I3D pour le SoilMod

La partie la plus difficile est d'ajouter les bonnes lignes dans l'I3D de votre map. Des instructions détaillées sont incluses dans le fichier 'map - Instructions.txt', que vous pouvez trouver dans le sous-dossier contenant les instructions.

IMPORTANT: Avant de commencer à modifier votre map, faites une sauvegarde! Si vous brisez quelque chose, il vous sera facile de retourner à une version fonctionnelle.

Veuillez noter que la taille normale (ou standard) pour une map est 'x1' (fichier de densité de 4096x4096 pixels). Dans un dossier sont inclus les fichiers de densité pour une map 0.25x (petite) et x4 (large), que vous devez impérativement copier si votre map n'est pas de taille normale.

Préparation de votre SampleModMap.LUA pour le SoilMod

La seconde partie des modifications consiste à ajouter des lignes de code additionnelles dans le fichier SampleModMap.LUA de votre map (le nom peut être différent).

Dans le fichier d'instructions vous trouverez un fichier nommé 'SampleModMap - Additions.LUA', qui contient cinq blocs de code clairement identifiés, que vous devez copier et coller dans votre propre SampleModMap.LUA, en prenant soin de conserver la position relative des blocs de code (instructions) dans le fichier SampleModMap.LUA.


Comment utiliser le mod (en jeu)

ATTENTION! Puisqu'il existe plusieurs autres mods qui modifient les fonctions internes qui régissent le fonctionnement de l'épandage, du déchaumage ou de la moisson dans Farming Simulator 2013, il est POSSIBLE que des conflits se produisent entre ces mods et le SoilMod. 

Il est donc recommandé de supprimer ou désactiver ces mods qui pourraient affecter le SoilMod.

Une fois que vous avez préparé votre map correctement pour le SoilMod, placez les mods fournis dans votre dossier "mods", c'est à dire 'SoilModManagement.ZIP' et 'PDAModPlugin_SoilCondition.ZIP'.
Aussi, assurez-vous d'avoir téléchargé et installé la plus récente version du PDAMod.ZIP.

Démarrez le jeu et lancez une partie avec la map que vous avez préparée. Notez qu'il est probablement possible de continuer une partie sauvegardée existante, mais expérimentez d'abord pour voir si c'est possible dans votre cas.

Lors du chargement de la map, le SoilMod va afficher diverses informations dans la console (en jeu) et dans le fichier LOG.TXT, ce qui est requis au cas où il y aurait un problème.


Soil Condition - un plugin de PDA MOD

La première chose que vous devriez vérifier est que la page 'Soil Condition' dans votre PDA fonctionne. Si cette page n'est pas disponible (avez-vous bien installé le PDA MOD?) ou ne ressemble pas à ce que les images (screenshots) affichent, il est possible que vous ayiez mal installé le SoilMod. Dans ce cas, référez-vous au fichier LOG.TXT pour avoir plus de détails.
 
Lorsque la page 'Soil Condition' fonctionne correctement, elle affiche des informations sur le sol dans un bloc de 10mx10m autour du joueur, mise à jour automatiquement toutes les 2 secondes.

Une sous-page appellée 'Fruit Effects' contient des informations statiques à propos de quel fruit obtient un boost à partir d'un fertilizant en particulier, et quels fruits obtiennent des effets néfastes à partir de certains herbicides.


La croissance, système de pourriture inclu, se produit à minuit tous les jours.

Initialement, j'ai développé ce mod dans le but de savoir avec précision quand allait se produire le prochain stade de croissance.

Actuellement, la croissance des fruits (avancement d'un niveau de pousse) se produit à minuit tous les jours.

La progression est indiquée au haut de l'écran et montre le pourcentage de progression, car une mise à jour de la croissance affecte seulement une région prédéterminée de la map, afin de réduire le lag et les problèmes.

Le système de pourriture des récoltes est activé, et il n'y a actuellement aucun moyen 'simple' de le désactiver sans jouer avec les valeurs des scripts.

Durant un cycle de croissance, les choses suivantes se produisent: 
- Les fruits poussent de un niveau (une étape), à moins que la croissance ne soit affectée par un herbicide qui mettrait la croissance en pause ou causerait le dépérissement (pourriture) de la récole.
- Les andains et le fumier non cultivé sont réduits de 1 niveau (disparition graduelle).
- La chaux et le lisier non cultivés sont absorbés par le sol, mais avec une efficacité réduite par rapport à s'ils étaient cultivés.
- Les herbicides vont causer la disparition des mauvaises herbes.
- L'humidité produite par la pulvérisation s'évapore. 


pH du sol et chaux - vont maintenant affecter les récoltes

Le pH du sol est un nouvel aspect de ce mod, qui va grandement affecter vos récoltes si le pH est trop acide.

La page 'Soil Condition' du PDA va afficher la valeur du pH pour la zone autour du joueur - ce qui ne représente pas la totalité du champ!

Pour une récolte optimale, la valeur du pH du sol doit être dans la zone 'neutre'. Un pH plus bas ou plus élevé va affecter vos récolte, comme indiqué par la table ci-dessous, où 100% représente une récolte optimale/normale.

  - 5.1 - 5.6 - 6.1 - 6.6 -  7.3 - 7.9 - 8.5 - 9.0 -
  5%   50%   75%   95%   100%   95%   90%   80%   70%

L'épandage de chaux va augmenter le pH du sol, et si vous labourez/cultivez cette chaux son efficacité sera accrue.

À cause de limitations techniques du jeu et de la façon dont fonctionne le script, le niveau de pH va varier avec un interval plus grand que ce qui peut sembler réaliste.

En utilisant l'équipement par défaut pour épandre l'engrais solide (à l'exception du fumier), il est possible de changer le type d'épandage pour de la "chaux". La boite d'information F1 (en haut à droite) va montrer sur quelle touche appuyer.


Fumier et lisier - engrais organiques

Plusieurs joueurs ont exprimé leur souhait d'avoir la possibilité d'épandre du fumier/lisier et d'ensuite le labourer/cultiver dans le sol.

C'est aussi un nouvel aspect qu'amène le 'SoilMod', dorénavant l'épandage d'engrais organique ne produira pas un effet immédiat, mais devra être labouré/cultivé pour augmenter la nutrition du sol, et donc produire une meilleure récolte.

Voici les instructions pour utiliser le fumier et le lisier avec le 'SoilMod':

1. Épendre du fumier ou du lisier dans le champ
2a. Pour un effet optimal, le fumier doit être labouré dans le sol, ce qui augmentera le niveau de nutrition du sol par 3 (jusqu'à un maximum de 3)
2c. Cultiver le fumier est moins effectif, et n'augmentera le niveau de nutrition que de 1.
2b. Pour le lisier, labourer ou cultiver augmenteront de 1 le niveau de nutrition du sol (jusqu'à un maximum de 3).
2d. Le lisier peut être laissé tel quel en attendant le prochain cycle de croissance, toutefois l'efficacité sera réduite encore plus, puisque le niveau de nutrition maximal sera alors seulement de 1.

Notez que le fumier laissé sur le terrain va lentement disparaître (totalement au bout de 3 jours),  et que ça n'aura donc PAS d'impact sur le niveau de nutrition du sol.


Engrais synthétique - seulement durant la pousse

Il est plus effectif d'utiliser des engrais organiques, mais les engrais synthétiques peuvent aider dans des situations où seulement une petite amélioration du niveau de nutrition du sol est requise.

Toutefois, l'épandage d'engrais synthétiques sera utile seulement dans les premiers stades de pousse. Si vous utilisez des engrais synthétiques trop tard, le fruit ne l'acceptera pas.

Dans le mode 'avancé' du 'SoilMod' - qui est activé par défaut - il y a trois types d'engrais : type A, type B et type C. Chaque fruit acceptera seulement un type d'engrais synthétique, ou aucun du tout, vous pouvez voir quels engrais sont acceptés par quels fruits dans la page 'Fruit Effects' du PDA.

En utilisant l'équipement par défaut pour épandre de l'engrais liquide (sauf le lisier), il est possible de changer de type d'engrais synthétique. La boite d'informations F1 va montrer sur quelle touche appuyer.


Mauvaises herbes et herbicides - apparaissent aléatoirement dans vos champs

Des zones de mauvaises herbes vont continuellement apparaitre dans vos champs. Le déchaumage, le labour ou le semis enlèvent les mauvaises herbes présentes dans votre champ, mais parfois ces méthodes ne seront pas possibles, vous devrez alors pulvériser de l'herbicide.

Dans le mode 'avancé' du 'SoilMod' - qui est activé par défaut - il y a trois types d'herbicides : type A, type B et type C. Tous les trois vont vous débarasser des mauvaises herbes présentes, mais certains fruits n'aiment pas certains types d'herbicides et seront négativement affectés. Référez-vous à la page "Fruit Effects" du PDA. Dans le pire des scénarios, la récolte pourrait être détruite.

Lorsque de l'herbicide a été vaporisé sur les mauvaises herbes, celles-ci vont mourir après quelques jours. Toutefois, il est possible que de nouvelles mauvaises herbes soit apparues entre temps.

En utilisant l'équipement par défaut pour pulvériser de l'herbicide, il est possible de changer le type d'herbicide. La boite d'informations F1 va montrer sur quelle touche appuyer.


Problemes ou bugs?

Si vous rencontrez des problèmes ou des bugs en utilisant le 'SoilMod', utilisez le topic de support de http://fs-uk.com. Recherchez le mod (la bonne version) dans la section 'mods', dans la catégorie 'Other - Game Scripts'.

Bugs/défauts connus:
- Texte uniquement en anglais dans le fichier modDesc.XML
- La pulvérisation d'un type différent d'engrais/herbicide dans un champ va remplacer tout autre type d'engrais ou herbicide déjà présent.
- Il est possible d'épandre du lisier le jour précédent, juste avant la moisson, et quand même obtenir l'effet de l'engrais organique.
- Le passage au mode 'simplistic' est seulement possible en éditant le fichier 'fmcSoilMod.LUA'.
- La modification des différents paramètres qui régissent la croissance est seulement possible en éditant le fichier 'fmcGrowthControl.LUA'.


Restrictions

Les fichiers du mod, SoilManagement.ZIP, PDAMod.ZIP et PDAModPlugin_SoilCondition.ZIP ne DOIVENT PAS être intégrés dans d'autres mods. Par contre, ils peuvent faire partie d'un pack, lorsque le "hash" original du zip est conservé.

Veuillez ne PAS uploader ce mod sur aucun autre site de téléchargement de mods - je peux faire ça moi-même, si nécessaire!

Conservez le lien original!


Credits:
Script: Decker_MMIV.
Graphiques: KaosKnite, JakobT, GIANTS, Decker_MMIV and others.
Translation 'DE': JakobT, webalizer.
Translation 'RU': Gonimy_Vetrom, VAHA.
Translation 'CZ': KingFrame, Albi.
Translation 'FR': Marxtai, Dural.
