-- Nettoyage
DROP VIEW IF EXISTS vue_materiel;
DROP TABLE IF EXISTS MATERIEL;
DROP TABLE IF EXISTS CATEGORIE;

-- Création de la table CATEGORIE
CREATE TABLE CATEGORIE (
    id_type INT PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL
);

-- Modifie la création de la table MATERIEL
CREATE TABLE MATERIEL (
    id INT AUTO_INCREMENT PRIMARY KEY, -- Ajout de l'auto-incrémentation
    nom VARCHAR(100) NOT NULL,
    annee INT,
    details TEXT,
    id_type INT NOT NULL,
    id_parent INT DEFAULT NULL,
    CONSTRAINT fk_type FOREIGN KEY (id_type) REFERENCES CATEGORIE(id_type),
    CONSTRAINT fk_parent FOREIGN KEY (id_parent) REFERENCES MATERIEL(id)
);

--  Insertion des catégories
INSERT INTO CATEGORIE (id_type, libelle) VALUES 
(1, 'PC'), (2, 'Écran'), (3, 'CPU'), (4, 'RAM'), (5, 'Disque'), 
(6, 'GPU'), (7, 'Carte réseau'), (8, 'OS'), (9, 'Batterie');

--  Insertion des données du tableau
INSERT INTO MATERIEL (id, nom, annee, details, id_type, id_parent) VALUES
(1, 'PC 1 – Unité centrale', 2016, NULL, 1, NULL),
(2, 'PC 2 – Unité centrale', 2017, NULL, 1, NULL),
(3, 'PC 3 – Portable', 2015, 'Inspiron 15-3558', 1, NULL),
(4, 'Écran A', 2012, 'HP LA1951g – 19’’', 2, NULL),
(10, 'CPU PC1', 2016, 'Intel Core i3-6100', 3, 1),
(11, 'RAM PC1', 2016, '4 Go DDR4', 4, 1),
(15, 'OS PC1', 2016, 'Windows 10 Pro', 8, 1);
-- (Ajoutez les autres lignes ici si besoin)

--  LA TRUQUE : On crée une vue que le PHP pourra lire facilement
CREATE VIEW vue_materiel AS
SELECT 
    m.id,
    m.nom,
    m.annee,
    m.details,
    m.id_type AS id_type_raw, -- Indispensable pour le filtre PHP
    c.libelle AS type_libelle,
    p.nom AS parent_nom
FROM MATERIEL m
LEFT JOIN CATEGORIE c ON m.id_type = c.id_type
LEFT JOIN MATERIEL p ON m.id_parent = p.id;
