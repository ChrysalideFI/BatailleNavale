<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:output method="xml" indent="yes"/>

    <!-- Template de base -->
    <xsl:template match="/">
        <svg:svg width="800" height="1000" xmlns:svg="http://www.w3.org/2000/svg">
            <!-- arrière plan + style -->
            <svg:defs>
                <svg:pattern id="waterPattern" width="10" height="10" patternUnits="userSpaceOnUse">
                    <svg:path d="M0 5 Q2.5 0, 5 5 T10 5" fill="none" stroke="#93c5fd" stroke-width="0.5"/>
                </svg:pattern>
            </svg:defs>
            
            <!-- fond couleur marin -->
            <svg:rect width="100%" height="100%" fill="url(#waterPattern)"/>
            
            <!-- titre + info jeu -->
            <svg:text x="400" y="40" text-anchor="middle" font-size="24" fill="#1a365d">
                Bataille Navale - Grille de <xsl:value-of select="//joueurActif"/>
            </svg:text>

            <!-- ici, on appelle les templates spécifiques -->
            <xsl:apply-templates select="batailleNavale"/>
            <xsl:call-template name="validationGrille"/>
            <xsl:call-template name="verifierFinPartie"/>
            <xsl:call-template name="afficherEtatNaviresEtTirsManques"/>
        </svg:svg>
        
    </xsl:template>

    <!-- Template pour la grille -->
    <xsl:template match="batailleNavale">
        <xsl:apply-templates select="joueur1"/>
        <xsl:apply-templates select="joueur2"/>
        <xsl:apply-templates select="etatPartie"/>
    </xsl:template>

    <!-- Template pour le joueur -->
    <xsl:template match="joueur1 | joueur2">
        <h2><xsl:value-of select="name()"/></h2>
        <svg:g transform="translate(50, 100)">
            <!-- Fond de la grille + effet d'eau -->
            <svg:rect width="{10 * 50}" height="{10 * 50}" fill="#bfdbfe" stroke="#1a365d" stroke-width="2"/>
            
            <!-- lignes horizontales et verticales -->
            <xsl:for-each select="1 to 10">
                <!-- Lignes horizontales + effet d'ombre -->
                <svg:line x1="0" y1="{50 * position()}" x2="{10 * 50}" y2="{50 * position()}"
                          stroke="#1a365d" stroke-width="1" stroke-dasharray="2,2"/>
                
                <!-- lignes verticales + effet d'ombre -->
                <svg:line x1="{50 * position()}" y1="0" x2="{50 * position()}" y2="{10 * 50}"
                          stroke="#1a365d" stroke-width="1" stroke-dasharray="2,2"/>
                
                <!-- labels des colonnes (A-J) -->
                <svg:text x="{(50 * position()) - (50 div 2)}" y="-10" text-anchor="middle" fill="#1a365d" font-size="16">
                    <xsl:value-of select="codepoints-to-string(64 + position())"/>
                </svg:text>
                
                <!-- labels des lignes (1-10) -->
                <svg:text x="-10" y="{(50 * position()) - (50 div 2)}" text-anchor="end" dominant-baseline="middle" fill="#1a365d" font-size="16">
                    <xsl:value-of select="position()"/>
                </svg:text>
            </xsl:for-each>

            <!-- Dessiner les navires -->
            <xsl:apply-templates select="grille/case"/>
            
            <!-- Dessiner les tirs -->
            <xsl:apply-templates select="tirsReçus/tir"/>
        </svg:g>
        <xsl:apply-templates select="flotte"/>
    </xsl:template>

    <!-- Template pour les cases -->
    <xsl:template match="case">
        <xsl:variable name="x" select="(string-to-codepoints(@colonne) - 65) * 50"/>
        <xsl:variable name="y" select="(@ligne - 1) * 50"/>
        
        <!-- Case du navire + effet de profondeur -->
        <svg:rect x="{$x + 2}" y="{$y + 2}" width="46" height="46"
                  fill="{if (@etat='touche') then '#dc2626' else if (@etat='coule') then 'red' else '#475569'}" stroke="black" stroke-width="1">
            <svg:animate attributeName="fill-opacity" values="1;0.7;1" dur="2s" repeatCount="indefinite"/>
        </svg:rect>
    </xsl:template>

    <!-- Template pour un tir -->
    <xsl:template match="tir">
        <xsl:variable name="x" select="(string-to-codepoints(@colonne) - 65) * 50 + (50 div 2)"/>
        <xsl:variable name="y" select="(@ligne - 1) * 50 + (50 div 2)"/>
        
        <!-- Marqueur de tir + animation -->
        <svg:g transform="translate({$x},{$y})">
            <xsl:choose>
                <xsl:when test="@etat='eau'">
                    <svg:circle r="5" fill="#60a5fa">
                        <svg:animate attributeName="r" values="3;6;3" dur="2s" repeatCount="indefinite"/>
                    </svg:circle>
                </xsl:when>
                <xsl:otherwise>
                    <svg:path d="M-5,-5 L5,5 M-5,5 L5,-5" stroke="#dc2626" stroke-width="2">
                        <svg:animate attributeName="stroke-width" values="2;3;2" dur="1s" repeatCount="indefinite"/>
                    </svg:path>
                </xsl:otherwise>
            </xsl:choose>
        </svg:g>
    </xsl:template>

    <!-- Template pour l'état de la partie -->
    <xsl:template match="etatPartie">
        <h2>État de la Partie : <xsl:value-of select="."/></h2>
        <xsl:choose>
            <xsl:when test=". = 'avantPartie'">
                <p>La partie n'a pas encore commencé.</p>
            </xsl:when>
            <xsl:when test=". = 'pendantPartie'">
                <p>La partie est en cours.</p>
                <xsl:apply-templates select="../joueur1/flotte"/>
            </xsl:when>
            <xsl:when test=". = 'finPartie'">
                <p>La partie est terminée.</p>
                <xsl:apply-templates select="../joueur1/flotte"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Template pour la flotte -->
    <xsl:template match="flotte">
        <h3>Flotte :</h3>
        <ul>
            <xsl:apply-templates select="porteAvions | croiseur | contreTorpilleur | sousMarin"/>
        </ul>
    </xsl:template>

    <!-- Template pour les bateaux -->
    <xsl:template match="porteAvions | croiseur | contreTorpilleur | sousMarin">
        <li>
            <xsl:value-of select="name()"/> - État : <xsl:value-of select="@etat"/>
            <xsl:if test="@etat = 'touche'">
                <xsl:text> (Touché)</xsl:text>
            </xsl:if>
            <xsl:if test="@etat = 'coule'">
                <xsl:text> (Bateau coulé)</xsl:text>
            </xsl:if>
        </li>
    </xsl:template>

    <!-- Template pour les tirs reçus -->
    <xsl:template match="tirsReçus">
        <h3>Tirs Reçus :</h3>
        <ul>
            <xsl:apply-templates select="tir"/>
        </ul>
    </xsl:template>
 
    <!-- Template pour un tir -->
    <xsl:template match="tir">
        <li>
            Tir en <xsl:value-of select="@ligne"/> <xsl:value-of select="@colonne"/> - État : <xsl:value-of select="@etat"/>
        </li>
    </xsl:template>

  <!-- Template pour valider la grille -->
    <xsl:template name="validationGrille">
        <svg:g transform="translate(50, 550)">
            <!-- Vérification du nombre de navires pour joueur1 -->
         
            <xsl:if test="count(//joueur1/flotte/porteAvions) != 1 or count(//joueur1/flotte/croiseur) != 2 or count(//joueur1/flotte/contreTorpilleur) != 3 or count(//joueur1/flotte/sousMarin) != 4">
                <svg:text x="0" y="170" fill="red" font-size="18">La flotte de joueur 1 n'est pas complète</svg:text>
            </xsl:if>
            

            <!-- Vérification du nombre de navires pour joueur2 -->
            
            <xsl:if test="count(//joueur2/flotte/porteAvions) != 1 or count(//joueur2/flotte/croiseur) != 2 or count(//joueur2/flotte/contreTorpilleur) != 3 or count(//joueur2/flotte/sousMarin) != 4">
                <svg:text x="0" y="200" fill="red" font-size="18">La flotte de joueur 2 n'est pas complète</svg:text>
            </xsl:if>
          

            <!-- Vérification si la grille est valide pour joueur1
            <xsl:variable name="flotteCompleteJoueur1" select="count(//joueur1/flotte/porteAvions) = 1 and count(//joueur1/flotte/croiseur) = 2 and count(//joueur1/flotte/contreTorpilleur) = 3 and count(//joueur1/flotte/sousMarin) = 4"/>
            <xsl:variable name="pasDeContactJoueur1" select="not(//joueur1/grille/case[@etat='bateau' and 
                not(@ligne = current()/@ligne and @colonne = current()/@colonne) and 
                abs(number(@ligne) - number(current()/@ligne)) &lt;= 1 and abs(string-to-codepoints(@colonne) - string-to-codepoints(current()/@colonne)) &lt;= 1 and 
                (ancestor::porteAvions/@id != current()/ancestor::porteAvions/@id and ancestor::croiseur/@id != current()/ancestor::croiseur/@id and 
                ancestor::contreTorpilleur/@id != current()/ancestor::contreTorpilleur/@id and ancestor::sousMarin/@id != current()/ancestor::sousMarin/@id)])"/>

            <xsl:if test="$flotteCompleteJoueur1 and $pasDeContactJoueur1">
                <svg:text x="20" y="170" fill='green' font-size="24">Grille valide pour joueur 1</svg:text>     
            </xsl:if>
            <xsl:if test="not($flotteCompleteJoueur1)">
                <svg:text x="20" y="200" fill="red" font-size="18">La flotte de joueur 1 n'est pas complète</svg:text>
            </xsl:if> -->

            <!-- Vérification si la grille est valide pour joueur2
            <xsl:variable name="flotteCompleteJoueur2" select="count(//joueur2/flotte/porteAvions) = 1 and count(//joueur2/flotte/croiseur) = 2 and count(//joueur2/flotte/contreTorpilleur) = 3 and count(//joueur2/flotte/sousMarin) = 4"/>
            <xsl:variable name="pasDeContactJoueur2" select="not(//joueur2/grille/case[@etat='bateau' and 
                not(@ligne = current()/@ligne and @colonne = current()/@colonne) and 
                abs(number(@ligne) - number(current()/@ligne)) &lt;= 1 and abs(string-to-codepoints(@colonne) - string-to-codepoints(current()/@colonne)) &lt;= 1 and 
                (ancestor::porteAvions/@id != current()/ancestor::porteAvions/@id and ancestor::croiseur/@id != current()/ancestor::croiseur/@id and 
                ancestor::contreTorpilleur/@id != current()/ancestor::contreTorpilleur/@id and ancestor::sousMarin/@id != current()/ancestor::sousMarin/@id)])"/>

            <xsl:if test="$flotteCompleteJoueur2 and $pasDeContactJoueur2">
                <svg:text x="20" y="230" fill='green' font-size="24">Grille valide pour joueur 2</svg:text>     
            </xsl:if>
            <xsl:if test="not($flotteCompleteJoueur2)">
                <svg:text x="20" y="260" fill="red" font-size="18">La flotte de joueur 2 n'est pas complète</svg:text>
            </xsl:if> -->
             
             <!-- Vérification si la grille est valide -->
            <!-- <xsl:variable name="flotteComplete" select="count(//joueur1/flotte/porteAvions) = 1 and count(//joueur1/flotte/croiseur) = 2 and count(//joueur1/flotte/contreTorpilleur) = 3 and count(//joueur1/flotte/sousMarin) = 4"/>
            <xsl:variable name="pasDeContact" select="not(//joueur1/grille/case[@etat='bateau' and 
                not(@ligne = current()/@ligne and @colonne = current()/@colonne) and 
                abs(number(@ligne) - number(current()/@ligne)) &lt;= 1 and abs(string-to-codepoints(@colonne) - string-to-codepoints(current()/@colonne)) &lt;= 1 and 
                (ancestor::porteAvions/@id != current()/ancestor::porteAvions/@id and ancestor::croiseur/@id != current()/ancestor::croiseur/@id and 
                ancestor::contreTorpilleur/@id != current()/ancestor::contreTorpilleur/@id and ancestor::sousMarin/@id != current()/ancestor::sousMarin/@id)])"/>

            <xsl:if test="$flotteComplete and $pasDeContact">
                <svg:text x="20" y="170" fill='green' font-size="24">Grille valide</svg:text>     
            </xsl:if> -->
            <!-- <xsl:if test="not($flotteComplete)">
                <svg:text x="0" y="170" fill="red" font-size="18">La flotte n'est pas complète</svg:text>
            </xsl:if> -->

            <!-- Vérification des contacts -->
            <xsl:for-each select="joueur1/grille/case[@etat='bateau']">
                <xsl:variable name="ligne" select="@ligne"/>
                <xsl:variable name="colonne" select="@colonne"/>
                <xsl:variable name="bateauId" select="ancestor::porteAvions/@id | ancestor::croiseur/@id | ancestor::contreTorpilleur/@id | ancestor::sousMarin/@id"/>
                <xsl:for-each select="//joueur1/grille/case[@etat='bateau' and 
                    not(@ligne = $ligne and @colonne = $colonne) and 
                    abs(number(@ligne) - number($ligne)) &lt;= 1 and abs(string-to-codepoints(@colonne) - string-to-codepoints($colonne)) &lt;= 1 and 
                    (ancestor::porteAvions/@id != $bateauId and ancestor::croiseur/@id != $bateauId and 
                    ancestor::contreTorpilleur/@id != $bateauId and ancestor::sousMarin/@id != $bateauId)]">
                    <svg:text x="20" y="140" font-size="14">
                        Les bateaux sont en contact aux coordonnées : 
                        <xsl:value-of select="concat('(', $ligne, ',', $colonne, ') et (', @ligne, ',', @colonne, ')')"/>
                    </svg:text>
                </xsl:for-each>
            </xsl:for-each>
        </svg:g>
    </xsl:template>

    <!-- Template pour vérifier la fin de partie -->
    <xsl:template name="verifierFinPartie">
        <!-- Vérification de fin de partie -->
        <xsl:variable name="joueur1TousCoules" select="count(//joueur1/flotte/*[case/@etat='coule']) = count(//joueur1/flotte/*)"/>
        <xsl:variable name="joueur2TousCoules" select="count(//joueur2/flotte/*[case/@etat='coule']) = count(//joueur2/flotte/*)"/>

        <xsl:if test="$joueur1TousCoules">
            <svg:text x="0" y="200" fill="red" font-size="20">
                Partie finie : Tous les navires de Joueur 1 sont coulés ! Joueur 2 a gagné !
            </svg:text>
        </xsl:if>
        <xsl:if test="$joueur2TousCoules">
            <svg:text x="0" y="230" fill="red" font-size="20">
                Partie finie : Tous les navires de Joueur 2 sont coulés ! Joueur 1 a gagné !
            </svg:text>
        </xsl:if>
    </xsl:template>

    <!-- Template pour afficher les navires touchés ou coulés et les tirs manqués -->
    <xsl:template name="afficherEtatNaviresEtTirsManques">
        <!-- Affichage des navires touchés ou coulés -->
        <xsl:call-template name="afficherEtatNavires"/>
        
        <!-- Tirs manqués -->
        <svg:text x="0" y="500" fill="grey" font-size="16">
            Nombre de tirs manqués : <xsl:value-of select="count(//tir[@etat='eau'])"/>
        </svg:text>
    </xsl:template>

    <!-- Template pour afficher si les navires sont touchés, coulés ou toujours intacts -->
    <xsl:template name="afficherEtatNavires">
        <xsl:for-each select="//navire">
            <xsl:variable name="touches" select="count(case[@etat='touche'])"/>
            <xsl:variable name="total" select="count(case)"/>
            <svg:text x="20" y="{position() * 25 + 25}" font-size="13">
                <xsl:value-of select="@type"/> 
                (<xsl:value-of select="@id"/>) : 
                <xsl:choose>
                    <xsl:when test="$touches = $total">Bateau coulé !</xsl:when>
                    <xsl:when test="$touches > 0">Touché (<xsl:value-of select="$touches"/>/<xsl:value-of select="$total"/>)</xsl:when>
                    <xsl:otherwise>Intact</xsl:otherwise>
                </xsl:choose>
            </svg:text>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>