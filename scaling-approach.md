**Doctrine d'Optimisation d'Affichage Rétro**

Cette doctrine définit une méthode universelle pour afficher des contenus rétro (historiquement pensés pour des tubes cathodiques 4:3 ou des ratios atypiques) sur des écrans modernes de ratios divers (16:9, 16:10, 3:2, etc.). L'objectif n'est ni la perfection mathématique stérile, ni le remplissage d'écran aveugle, mais l'optimisation optique : maximiser la taille perçue des sprites tout en préservant strictement l'intégrité de l'interface (HUD) et en interdisant toute déformation visuellement choquante ("Aspect Ratio Crime").

### 1. La Hiérarchie des Priorités

L'élaboration d'un profil d'affichage obéit à trois priorités absolues, par ordre d'importance :
1.  **Intégrité du HUD :** Aucune information de gameplay ou d'interface ne doit être tronquée par les coupes, quelles que soient les marges techniques (overscan). Les considérations esthétiques s'effacent devant les contraintes d'utilisabilité de l'interface.
2.  **Maximisation de l'axe vertical (Le "Cheat Code" optique) :** L'image doit remplir l'écran physique de haut en bas autant que le HUD le permet. L'axe vertical dicte le niveau de zoom général : plus on rogne les marges verticales inutiles (overscan repoussé hors cadre), plus l'image sous-jacente grossit, augmentant la diagonale perçue des sprites.
3.  **Expansion horizontale sous contrainte :** Remplir au maximum la largeur de l'écran pour limiter les bandes noires (pillarboxing), mais en s'arrêtant strictement aux seuils de tolérance géométrique définis ci-dessous.

### 2. Les Leviers d'Ajustement

*   **L'Integer Scaling Strict (Portables LCD) :** C'est la règle d'or pour les portables LCD. Les consoles dotées historiquement d'écrans LCD (Game Boy, GBA, Game Gear, etc.) exigent un Integer Scaling parfait (sans rognage). C'est la seule méthode permettant aux shaders de grille LCD de s'appliquer sans générer de motifs de moiré.  On préfère toujours l'Integer Scaling quand le ratio le permet sans trop de perte d'écran.
*   **L'Échelle Fractionnelle (Consoles de salon et autres cas) :** L'Integer Scaling peut parfois être un frein à l'optimisation verticale car il génère des marges noires massives ou impose des coupes destructrices. La doctrine autorise donc l'utilisation de **l'échelle fractionnelle**, dont les éventuels artefacts de sous-pixels sont généralement lissés par l'application de shaders CRT (qui tolèrent mieux le fractionnel que les shaders de grille).
*   **L'Auto-centrage Symétrique :** Les coordonnées matérielles (dans RetroArch) doivent par défaut être centrées (`X=0, Y=0`). Tout débordement d'image fractionnelle hors de l'écran physique est ainsi coupé mathématiquement en deux (moitié en haut, moitié en bas), garantissant un rognage parfaitement symétrique. 
*   **Les décalages asymétriques (offsets) :** Les offsets (décalages de `X` et `Y`) ne sont pas proscrits, mais doivent être justifiés. Ils sont appliqués uniquement lorsque les spécifications matérielles de la console d'origine dictent une asymétrie de l'affichage (ex. un overscan décentré par défaut).

### 3. Doctrine Horizontale et Seuils de Déformation

L'ajustement horizontal repose sur deux scénarios, appliquant chacun une limite stricte à l'étirement :

*   **Le Seuil de Nostalgie (Tolérance Max : 5 %)**
    *   *Cibles :* Systèmes basés sur un rendu 4:3 assumé, géométrie 3D, ou Pixel Aspect Ratio (PAR) historiquement juste (Arcade, Mega Drive, Master System, PS1, Saturn, N64, consoles 128-bit).
    *   *Règle :* L'étirement horizontal appliqué pour grignoter les bandes noires latérales ne doit **jamais dépasser 5 %** de la largeur mathématique parfaite (1:1). Cette limite est visuellement imperceptible par le cerveau (surtout sur des modèles 3D ou derrière un masque CRT) et préserve l'intégrité géométrique (les roues de voitures restent rondes).
*   **La Correction Cathodique (L'Exception 8/16-bit)**
    *   *Cibles :* Systèmes historiquement victimes d'un fort écrasement matériel sur les téléviseurs 4:3 en raison de résolutions atypiques (ex: NES, Super Nintendo).
    *   *Règle :* La largeur cible vise le **
