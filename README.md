# Gestion de parc informatique — M2L

Application web de gestion et de consultation d'un parc informatique : inventaire du matériel, de ses composants et de leurs relations, avec recherche multicritère et interface d'administration.

![PHP](https://img.shields.io/badge/PHP-8-777BB4?logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-MariaDB-4479A1?logo=mysql&logoColor=white)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-7952B3?logo=bootstrap&logoColor=white)

## À propos

Projet réalisé en binôme dans le cadre du BTS SIO option SLAM (Lycée Charles de Foucauld, Paris 18e), sur le contexte M2L.

**Auteurs :** [Tiago Da Cunha](https://github.com/Tidaku) et [rayan95210](https://github.com/rayan95210)

## Le problème

Un parc informatique ne se décrit pas comme une simple liste de machines. Un poste de travail est un assemblage : un PC contient un processeur, de la mémoire, un disque, un système d'exploitation — et chacun de ces composants a sa propre année d'acquisition et ses propres caractéristiques.

Une table plate oblige soit à dupliquer l'information machine sur chaque composant, soit à créer une table par type de composant. Les deux vieillissent mal : la première crée des incohérences, la seconde impose une modification du schéma à chaque nouveau type de matériel.

## La solution

Une **table unique auto-référencée**. Chaque élément du parc est une ligne de `MATERIEL`, qu'il s'agisse d'une machine complète ou d'un composant, et la colonne `id_parent` pointe vers la machine à laquelle il appartient (`NULL` pour un équipement autonome).

Ajouter un nouveau type de matériel devient une ligne dans `CATEGORIE`, jamais une migration de schéma.

![Modèle conceptuel de données](mcd_parc.png)

### Modèle de données

| Table | Rôle |
|---|---|
| `CATEGORIE` | Types de matériel (PC, Écran, CPU, RAM, Disque, GPU, Carte réseau, OS, Batterie) |
| `MATERIEL` | Tous les équipements, machines et composants confondus |
| `vue_materiel` | Vue de lecture : jointure des libellés de catégorie et du nom de la machine parente |

La vue `vue_materiel` évite de réécrire les deux jointures (`CATEGORIE` et l'auto-jointure sur `MATERIEL`) dans chaque page PHP. Elle expose `id_type_raw` en plus du libellé, pour que le filtre par catégorie reste indexable.

## Fonctionnalités

**Consultation** — `index.php`
- Inventaire complet sous forme de tableau
- Recherche plein texte sur le nom et les caractéristiques
- Filtre par catégorie, combinable avec la recherche
- Affichage de la machine parente pour chaque composant

**Administration** — `admin.php`, `edit.php`, `delete.php`
- Ajout, modification et suppression d'un équipement
- Accès protégé par authentification (`login.php`, `auth.php`)

## Stack technique

| Couche | Technologie |
|---|---|
| Backend | PHP, PDO avec requêtes préparées |
| Base de données | MySQL / MariaDB |
| Frontend | HTML5, Bootstrap 5.3 (CDN) |
| Environnement | XAMPP / WAMP en local |

### Choix techniques

- **PDO et requêtes préparées à paramètres nommés** sur toutes les requêtes, y compris la recherche multicritère dont le nombre de paramètres varie selon les filtres actifs.
- **Échappement systématique en sortie** : `htmlspecialchars()` sur chaque valeur affichée, et `nl2br(htmlspecialchars())` dans cet ordre sur les champs multilignes, afin que l'échappement précède la conversion des retours à la ligne.
- **Vue SQL plutôt que jointures en PHP** : la logique de lecture reste dans la base, les pages PHP ne font que du `SELECT * FROM vue_materiel`.

## Installation

### Prérequis

- PHP 8 ou supérieur
- MySQL ou MariaDB
- Un serveur local type XAMPP, WAMP ou MAMP

### Étapes

1. **Cloner le dépôt** dans le répertoire web de votre serveur local

```bash
   git clone https://github.com/Tidaku/gestion-parc-informatique.git
   cd gestion-parc-informatique
```

2. **Créer la base de données**

```bash
   mysql -u root -p < parc.sql
```

   Le script crée la base `gpi`, les tables, la vue et un jeu de données d'exemple.

3. **Configurer la connexion**

```bash
   cp credentials.example.php credentials.php
```

   Puis renseigner l'hôte, l'utilisateur, le mot de passe et le nom de la base dans `credentials.php`.

4. **Lancer**

   Ouvrir `http://localhost/gestion-parc-informatique/` dans un navigateur.

> `credentials.php` est exclu du dépôt via `.gitignore` : chaque poste garde sa propre configuration.

## Structure du projet

```
gestion-parc-informatique/
├── index.php                  ← Inventaire, recherche et filtres
├── admin.php                  ← Interface d'administration
├── edit.php                   ← Modification d'un équipement
├── delete.php                 ← Suppression d'un équipement
├── login.php                  ← Formulaire de connexion
├── auth.php                   ← Contrôle d'accès aux pages d'administration
├── db.php                     ← Connexion PDO
├── credentials.example.php    ← Modèle de configuration
├── parc.sql                   ← Script de création de la base
├── mcd_parc.png               ← Modèle conceptuel de données
└── .gitignore
```

## Compétences mobilisées (Référentiel BTS SIO SLAM)

| Bloc | Compétence | Niveau |
|---|---|---|
| B1.1 | Gérer le patrimoine informatique | Application |
| B2.1 | Concevoir et développer une solution applicative | Maîtrise |
| B2.2 | Assurer la maintenance corrective ou évolutive | Application |
| B2.3 | Gérer les données | Maîtrise |
| B3.6 | Cybersécurité d'une solution applicative | Application |

## Limitations connues et perspectives

Projet réalisé dans un cadre pédagogique. Les évolutions suivantes seraient nécessaires pour un usage réel :

- [ ] Jeton CSRF sur les formulaires de modification et de suppression
- [ ] Confirmation avant suppression, et suppression logique plutôt que définitive
- [ ] Gestion du cas où une machine parente est supprimée alors qu'elle porte des composants
- [ ] Pagination de l'inventaire au-delà de quelques centaines d'équipements
- [ ] Export CSV de l'inventaire filtré
