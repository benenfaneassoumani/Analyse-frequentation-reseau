--------------------------------------------------------------------------------
-- PROJET : Analyse fréquentation réseau (réseau STAR, Keolis)
-- AUTEUR : Ben-Enfane Assoumani
--------------------------------------------------------------------------------

-- ÉTAPE 1 : Nettoyage et Structuration des Données (Staging Table Strategy)
-- Création de la table propre avec les types de données adaptés (DATE, TIME, TINYINT, FLOAT)
CREATE TABLE frequentation_star_clean (
    DateFreq DATE,
    TrancheHoraire15mn TIME,
    Heure TINYINT,
    NomArret NVARCHAR(100),
    NomCourtLigne NVARCHAR(50),
    Sens NVARCHAR(50),
    Frequentation FLOAT
);

-- Insertion des données converties (Correction format date JJ/MM/AAAA et conversion des virgules en points)
INSERT INTO frequentation_star_clean (DateFreq, TrancheHoraire15mn, Heure, NomArret, NomCourtLigne, Sens, Frequentation)
SELECT 
    CONVERT(DATE, DateFreq, 103),
    CAST(TrancheHoraire15mn AS TIME),
    CAST(Heure AS TINYINT),
    NomArret,
    NomCourtLigne,
    Sens,
    CAST(REPLACE(Frequentation, ',', '.') AS FLOAT)
FROM 
    frequentation_star;

-- Bascule vers la table propre définitive
DROP TABLE frequentation_star;
EXEC sp_rename 'frequentation_star_clean', 'frequentation_star';


--------------------------------------------------------------------------------
-- ÉTAPE 2 : Requêtes d'Analyse Métier et Décisionnelle
-- Note : la ligne '9999' correspond aux autocars de tourisme, hors périmètre
-- du réseau de transport urbain régulier, et est exclue des analyses par ligne.
--------------------------------------------------------------------------------

-- ANALYSE 1 : Heures de pointe globales (Identification des pics de charge)
-- Objectif : Savoir à quelles heures le réseau est le plus sous tension pour adapter l'offre.
SELECT 
    Heure,
    SUM(Frequentation) AS Total_Passagers
FROM 
    frequentation_star
GROUP BY 
    Heure
ORDER BY 
    Total_Passagers DESC;


-- ANALYSE 2 : Heures creuses globales (Identification des opportunités d'économies)
-- Objectif : Repérer les moments où l'offre est surdimensionnée pour optimiser les coûts.
SELECT 
    Heure,
    SUM(Frequentation) AS Total_Passagers
FROM 
    frequentation_star
GROUP BY 
    Heure
ORDER BY 
    Total_Passagers ASC;


-- ANALYSE 3 : Fréquentation par jour (Variations hebdomadaires)
-- Objectif : Mesurer l'impact de la variation des jours sur le trafic (semaine vs week-end).
SELECT
    DateFreq,
    SUM(Frequentation) AS Total_Passagers
FROM 
    frequentation_star
GROUP BY 
    DateFreq
ORDER BY 
    Total_Passagers DESC;


-- ANALYSE 4 : Fréquentation par ligne (Hiérarchisation du réseau)
-- Objectif : Identifier les lignes stratégiques (métros, lignes chronostar) et les lignes secondaires.
SELECT 
    NomCourtLigne,
    SUM(Frequentation) AS Total_Passagers
FROM 
    frequentation_star
WHERE
    NomCourtLigne <> '9999' -- Exclusion des autocars de tourisme
GROUP BY 
    NomCourtLigne
ORDER BY 
    Total_Passagers DESC;
