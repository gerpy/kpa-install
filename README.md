> **Author's Note:** The recommendations and technical choices presented here are my own. Because English is not my native language, I used Gemini to translate and format my personal notes, as well as to assist with some of the mathematical calculations.

# Installation Preparation for a Konkr Pocket Advance

## RetroArch Scaling for LCD Systems

Because grid shaders often can't deal decently with non integer scaling, we use integer scaling for every handheld system. Platforms up to GBA are 4x, NDS is 3x and PSP is 2x. Just set the following and you are done :
- **Integer Scale:** `On`
- **Integer Scale Axis:** `Y`
- **Aspect Ratio:** `Core Provided`

**The NDS exception:**

The exception is NDS. Displaying both screen on the KPA make the screens so tiny that it is unplayable. So better display on screen large and a small vignete for the second one. Unfortunately, the `Melon DS DS` core options to balance both screens are very limited and lead to non intsger scaling on both screens.

NDS 256x192 screens display at 3x but there is wasted real estate if you display only that. So the preferred layout is to display one main large screen at 3x on the left, and a thumbnail of the second screen on the right, in the remaining space. I like to spare a small black separation line between both displays. But `Melon DS DS` can't do any of this that so I had to develop a custom shader that takes a top/bottom or bottom/top layout from the core, splits it into two seperate screens and displays them it as I want. The shader preset adds a `lcd1x` grid because that's the whole point. There is one version with NDS corrected collors, and one with raw colors from the core.

To make this work, we need an NDS core override for scaling and set the viewport as such :

- **Integer Scale:** `OFF`
- **Aspect Ratio:** `Custom`
- **Custom Aspect Ratio (Width):** `960` (Justification: fill the whole width to maximize the thumbnail size)
- **Custom Aspect Ratio (Height):** `576` (Justification: 3x the NDS vertical resolution of 192)

> More in the [https://github.com/gerpy/kpa-install/blob/main/shaders.md|shaders dedicated page].

## Mise à l'échelle RetroArch pour les systèmes CRT

La Konkr Pocket Advance (KPA) est équipée d'un écran au format 3:2 (960 × 640)[cite: 3]. S'il est idéal pour la Game Boy Advance, l'affichage des consoles historiques 4:3 avec les réglages par défaut génère d'importantes bandes noires latérales (pillarboxing)[cite: 3].

Pour maximiser la surface d'affichage utile, les configurations suivantes reposent sur une double approche[cite: 3] :
1. **Rognage de l'overscan vertical (Vertical Overscan Cropping) :** Suppression chirurgicale des marges supérieures et inférieures inutilisées afin d'agrandir l'image, tout en garantissant que tous les éléments d'interface (HUD) restent intégralement visibles et respirent confortablement[cite: 1, 3].
2. **Étirement horizontal maîtrisé (Horizontal Stretching) :** Élargissement du Pixel Aspect Ratio (PAR) visant ~4,5 % (et plafonné strictement sous le seuil de perception de 5 %) afin de réduire les bandes noires sans déformation géométrique perceptible[cite: 1, 3]. Fixer ainsi les viewports permet en outre d'absorber les changements dynamiques de résolution interne de certaines consoles en maintenant un cadre d'affichage parfaitement stable[cite: 1, 2].

**L'exception de correction cathodique historique :**
Pour les plateformes dotées de résolutions natives plus étroites qui subissaient déjà un fort étirement horizontal sur les téléviseurs CRT 4:3 d'époque (comme la NES en 16:15 ou la SNES en 8:7), nous dépassons délibérément la limite des 5 % sur le PAR 1:1[cite: 1, 3]. En visant le point médian exact entre le Display Aspect Ratio (DAR) 4:3 historique et le Pixel Aspect Ratio (PAR) 1:1 mathématique (+8,33 % sur SNES et +12,50 % sur NES/PCE), nous réduisons la distorsion géométrique d'origine tout en flattant la mémoire visuelle[cite: 1, 2, 3].

### Résumé de référence rapide (Quick Reference Summary)

Pour tous les systèmes ci-dessous, les paramètres de base suivants sont **strictement obligatoires** pour garantir la justesse de l'auto-centrage mathématique (les cœurs restant sur leur configuration par défaut)[cite: 1, 3] :
- **Integer Scale :** `OFF`[cite: 3]
- **Aspect Ratio :** `Custom`[cite: 3]
- **Custom Aspect Ratio (X Position) :** `0`[cite: 3]
- **Custom Aspect Ratio (Y Position) :** `0`[cite: 3]
- **Crop Overscan :** `OFF`[cite: 3]

| Plateforme (Cœur) | Résolution de sortie du cœur (DAR) | Tolérance en px natifs (par côté) | Résolution affichée native restante | Viewport : arrondis pairs (`W × H`) | % d'étirement horizontal appliqué au PAR |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Atari 2600** (`Stella`) | `160 × 210 (4:3)` | **7 px** | `160 × 196` | **956 × 686** | **+4,52 %** |
| **NES** (`Mesen`) | `256 × 240 (16:15)`[cite: 2] | **12 px** | `256 × 216` | **852 × 710** | **+12,50 %**[cite: 2, 3] |
| **Master System** (`Genesis Plus GX`) | `256 × 192 (4:3)`[cite: 2] | **0 px**[cite: 1, 2] | `256 × 192`[cite: 2] | **892 × 640** | **+4,53 %** |
| **PC Engine** (`Beetle PCE Fast`) | `256 × 240 (16:15)`[cite: 2] | **12 px** | `256 × 216` | **852 × 710** | **+12,50 %**[cite: 2, 3] |
| **Super Nintendo** (`Snes9x`) | `256 × 224 (8:7)`[cite: 2] | **5,33 px**[cite: 2] | `256 × 213,3`[cite: 2] | **832 × 672**[cite: 2, 3] | **+8,33 %**[cite: 2, 3] |
| **Mega Drive** (`Genesis Plus GX`) | `320 × 224 (10:7)`[cite: 2] | **0 px**[cite: 1, 2] | `320 × 224`[cite: 2] | **960 × 640**[cite: 2, 3] | **+5,00 %**[cite: 2, 3] |
| **Sega Saturn** (`YabaSanshiro`) | `320 × 240 (4:3)`[cite: 2] | **2 px** | `320 × 236` | **906 × 650** | **+4,54 %** |
| **PlayStation 1** (`SwanStation`) | `320 × 240 (4:3)`[cite: 2] | **2 px** | `320 × 236` | **906 × 650** | **+4,54 %** |
| **Nintendo 64** (`Mupen64Plus-Next`) | `320 × 240 (4:3)`[cite: 2] | **6 px**[cite: 1, 2] | `320 × 228` | **940 × 674** | **+4,60 %** |
| **Dreamcast** (`Flycast`) | `640 × 480 (4:3)`[cite: 2] | **0 px**[cite: 2] | `640 × 480`[cite: 2] | **892 × 640** | **+4,53 %** |
| **Arcade** (`FBNeo`) | `Var. × 224 (4:3)`[cite: 2] | **0 px**[cite: 1, 2] | `Var. × 224`[cite: 2] | **892 × 640** | **+4,53 %** |
| **Neo Geo** (`FBNeo`) | `320 × 224 (4:3)`[cite: 2] | **0 px**[cite: 1, 2] | `320 × 224`[cite: 2] | **892 × 640** | **+4,53 %** |
| **Amiga** (`PUAE`) | `320 × 256 (4:3)`[cite: 2] | **0 px**[cite: 2] | `320 × 256`[cite: 2] | **892 × 640** | **+4,53 %** |

### Métriques d'affichage réelles (Surface vs Taille perçue)

Comme nous utilisons un écran 3:2 de 3,5 pouces (960 × 640) pour afficher principalement des contenus 4:3, mesurer l'image uniquement par sa diagonale physique affichée est mathématiquement trompeur[cite: 3]. En repoussant les marges d'overscan verticales hors du cadre physique de l'écran, nous agrandissons la fenêtre de rendu au-delà des limites matérielles[cite: 1, 3].

Ce tableau unifié distingue deux réalités complémentaires[cite: 3] :
1. **La surface affichée (Displayed Surface) :** Ce qui est effectivement allumé sur l'écran physique de la KPA[cite: 3].
2. **Le canevas sous-jacent (Underlying Canvas) :** La taille complète de la fenêtre de jeu rendue (incluant les lignes rognées hors écran)[cite: 3]. En convertissant cette surface sous-jacente en une **diagonale 4:3 équivalente**, on mesure le véritable gain optique de cette approche : *la taille réelle des sprites telle que perçue par l'œil* comparée à une console portable 4:3 standard[cite: 1, 3].

| Système(s) | AR affiché | Diagonale affichée | Surface d'écran | AR sous-jacent (crop incl.) & Étirement PAR | Diagonale sous-jacente | Diagonale 4:3 équivalente |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Mega Drive** | 1.50 (3:2)[cite: 3] | **3.50"**[cite: 3] | 100.0%[cite: 3] | 1.50 (3:2) + 5.00% stretch[cite: 3] | 3.50"[cite: 3] | **3.43"**[cite: 3] |
| **Atari 2600** | 1.49 (~3:2) | **3.49"** | 99.6% | 1.39 (~7:5) + 4.52% stretch | 3.57" | **3.55"** |
| **Nintendo 64** | 1.47 (~47:32) | **3.45"** | 97.9% | 1.39 (~7:5) + 4.60% stretch | 3.51" | **3.49"**[cite: 3] |
| **PS1 & Saturn** | 1.42 (~7:5) | **3.36"** | 94.4% | 1.39 (~7:5) + 4.54% stretch | 3.38" | **3.36"** |
| **SMS / DC / Arcade / Neo Geo / Amiga** | 1.39 (~7:5) | **3.33"** | 92.9% | 1.39 (~7:5) + 4.53% stretch | 3.33" | **3.31"** |
| **NES & PC Engine** | 1.33 (4:3) | **3.23"** | 88.8% | 1.20 (6:5) + 12.50% stretch[cite: 3] | 3.36" | **3.41"** |
| **Super Nintendo** | 1.30 (13:10)[cite: 3] | **3.18"**[cite: 3] | 86.7%[cite: 3] | 1.24 (~11:9) + 8.33% stretch[cite: 3] | 3.24"[cite: 3] | **3.27"**[cite: 3] |

**Le verdict :**
Même si la Konkr Pocket Advance est un appareil au format 3:2, cette doctrine de mise à l'échelle neutralise efficacement la pénalité liée au ratio d'écran[cite: 3]. En exploitant la largeur supplémentaire de l'écran pour zoomer et rogner sans risque les marges verticales inutiles, des systèmes comme l'Atari 2600, la N64 ou la NES/PC Engine affichent des modèles 3D et des sprites d'une taille équivalente à un **écran 4:3 de 3,41 à 3,55 pouces**[cite: 3]. Même les systèmes sans aucun rognage vertical (3,31") ou plus étroits comme la Super Nintendo (3,27") conservent une taille perçue très proche d'un écran 4:3 natif de 3,5 pouces[cite: 3].

## Shaders for the KPA

### CRT Shaders

The KPA doesn't have a high resolution wrt decent shaders standards, and its processor isn't strong enough to calculate complex shaders. A small resolution is not a big deal when you integer scale but unfortunately, as one may see above, many systems are scaled in a non integer way. So one needs to find and carefuly setup shaders that are known to be robust wrt fractional scaling :

- I have tried my best with `hyllian` but I failed at finding decent parameters that show a nice look and zero to very little moire an artifacts
- I had good results with `crt-guest-advanced-fast` despite the 640 vertical resolution of the KPA. However, even in its `fast` version, `guest` is too heavy, be to older and easy to emulate older platforms. But even so, it draine too much battery to justify the look.

My non negocialble prerequisite is to make things properly, which means :

- **Scanlines** have to correspond to native pixel lines and not with the device screen (many shaders "cheat" and it is ugly once you notice it)
- **Masks** however have to take the device screen as a reference
- Scanlines make no sense past 240p (NTSC).

I don't like overcooked shaders but I want them to help increasing perceived color palettes of 2D games, smooth dithering a bit and lower aliasing in 3D games. With such tastes in mind, considering the processing power, the KPA screen resolution and size, as well as the non integer scalings, I did my best with the `easymode` suite (regular and `halation`). The `halation` version is too heavy with N64 (Parallel) or with the PS1 Swannstation core at 2x, but the regular `crt-easymode` is just fine. For 2D platforms, `halation` is a must to get a decent look. I have ony tinkered with parameters to find decent settings. And I have to admit that I'm impressed by what it is possible to achieve with only 640 lines. 

> More in the [https://github.com/gerpy/kpa-install/blob/main/shaders.md|shaders dedicated page].

### LCD Shaders

For LCD plaforms, I don't think that advanced grid shaders with RGB separation matter on the KPA screen, so I keep it simple with `lcd1x` (dark grid for backlit handhelds) and `simpletex` (for earlier handhelds such as GB for instance). All I did is tweaking parameters to roughly match the colors from the core, without heavy darkening or enlihting. 

> More in the [https://github.com/gerpy/kpa-install/blob/main/shaders.md|shaders dedicated page].
