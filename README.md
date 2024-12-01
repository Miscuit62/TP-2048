Réalisé par : Français Maxence 
Numéro étudiant : 22205909
Formation : LP DLWM

Jeu 2048 - TP Flutter

Fonctionnalités principales :
1. Déplacement des tuiles :
   - Les tuiles peuvent être déplacées dans 4 directions : haut, bas, gauche, droite.
   - Les tuiles identiques fusionnent lorsqu'elles se rencontrent.
   - Un nouveau numéro (2 ou 4) apparaît aléatoirement après chaque mouvement.
   - Les mouvements peuvent être effectués via :
     - Gestes (swipe) sur l'écran.
     - Touches directionnelles (clavier).

2. Conditions de victoire et défaite :
   - Victoire : Atteindre la valeur de l'objectif (par défaut : 2048).
     - Option pour continuer à jouer après avoir atteint l'objectif.
   - Défaite : Aucun mouvement disponible (grille pleine et aucune fusion possible).

3. Système de score :
   - Score actuel : Somme de toutes les tuiles sur la grille.
   - Meilleur score : Score le plus élevé atteint (sauvegardé via `SharedPreferences`).

4. Bouton pour les règles du jeu :
   - Un bouton situé dans la barre d'application permet d'afficher les règles du jeu.
   - Les règles expliquent les principes de base du jeu, ainsi que les options disponibles.

5. Retour en arrière :
   - Un bouton permet d'annuler le dernier mouvement.
   - Le bouton est situé en bas à gauche de l'écran.

6. Recommencer une partie :
   - Un bouton permet de réinitialiser la grille et de recommencer une nouvelle partie.
   - Le bouton est situé en bas à droite de l'écran.

Options de personnalisation (via GameSettingsScreen) :
1. Objectif :
   - Choisissez une valeur d'objectif parmi : 256, 512, 1024, 2048, 4096, ou 8192.

2. Palette de couleurs :
   - Sélectionnez une palette de couleurs parmi "Default", "Blue", ou "Green".

3. Taille de la grille :
   - Choisissez entre une grille classique 4x4 ou une grande grille 8x8.

4. Grille aléatoire :
   - Activez cette option pour commencer une partie avec une disposition aléatoire des tuiles.

5. Mode de fusion :
   - "Classique" : Les tuiles identiques se combinent normalement.
   - "Fusion Multiple" : Fusionnez 4 tuiles identiques adjacentes pour former une seule tuile.
   - "Double Fusion" : Les tuiles identiques se combinent pour doubler leur fusion habituelle.

6. Inversion des directions :
   - Activez cette option pour inverser les directions haut/bas et gauche/droite.

Éléments de l'interface utilisateur :
- SplashScreen : Écran d'accueil affiché pendant 3 secondes avant d'accéder au jeu.
- GameScreen : Écran principal où se déroule le jeu.
- CustomPaint : Utilisé pour dessiner la grille et les tuiles.
- Boutons flottants : Placés en bas à gauche et en bas à droite pour annuler ou recommencer.
