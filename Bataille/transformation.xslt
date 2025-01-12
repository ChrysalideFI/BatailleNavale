<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:output method="xml" indent="yes"/>

    <!-- Template de base -->
    <xsl:template match="/">
        <svg:svg width="800" height="3000" xmlns:svg="http://www.w3.org/2000/svg">
            <!-- titre & info jeu -->
            <svg:text x="400" y="40" text-anchor="middle" font-size="24" fill="black">
                Bataille Navale - Grille de <xsl:value-of select="//joueurActif"/>
            </svg:text>
            <xsl:apply-templates select="batailleNavale/joueur1"/>
            <xsl:apply-templates select="batailleNavale/joueur2"/>
            <xsl:apply-templates select="batailleNavale/etatPartie"/>
            <!-- <xsl:call-template name="validationGrille"/> -->
        </svg:svg>
    </xsl:template>

    <!-- Template pour le joueur -->
    <xsl:template match="joueur1">
        <svg:g transform="translate(50, 100)">
            <!-- Fond de la grille -->
            <svg:rect width="{10 * 50}" height="{10 * 50}" fill="blue" stroke="black" stroke-width="2"/>
            
            <!-- lignes horizontales  -->
            <xsl:for-each select="1 to 10">
                <!-- Lignes horizontales -->
                <svg:line x1="0" y1="{50 * position()}" x2="{10 * 50}" y2="{50 * position()}"
                          stroke="blue" stroke-width="1"/>
                
                <!-- lignes verticales -->
                <svg:line x1="{50 * position()}" y1="0" x2="{50 * position()}" y2="{10 * 50}"
                          stroke="blue" stroke-width="1"/>
                
                <!-- colonnes -->
                <svg:text x="{(50 * position()) - (50 div 2)}" y="-10" text-anchor="middle" fill="#9999ff" font-size="16">
                    <xsl:value-of select="codepoints-to-string(64 + position())"/>
                </svg:text>
                
                <!-- lignes -->
                <svg:text x="-10" y="{(50 * position()) - (50 div 2)}" text-anchor="end" dominant-baseline="middle" fill="#9999ff" font-size="16">
                    <xsl:value-of select="position()"/>
                </svg:text>
            </xsl:for-each>

            <!-- Dessiner les navires -->
            <xsl:apply-templates select="grille/caseGrille"/>
            

            <xsl:apply-templates select="flotte/porteAvions/caseBateau"/>
            <xsl:apply-templates select="flotte/croiseur/caseBateau"/>
            <xsl:apply-templates select="flotte/contreTorpilleur/caseBateau"/>
            <xsl:apply-templates select="flotte/sousMarin/caseBateau"/>

            <!-- Dessiner les tirs -->
            <xsl:apply-templates select="tirsReçus/tir"/>
        </svg:g>
    </xsl:template>

        <xsl:template match="joueur2">
        <svg:g transform="translate(50, 1400)">
            <!-- Fond de la grille -->
            <svg:rect width="{10 * 50}" height="{10 * 50}" fill="blue" stroke="black" stroke-width="2"/>
            
            <!-- lignes horizontales  -->
            <xsl:for-each select="1 to 10">
                <!-- Lignes horizontales -->
                <svg:line x1="0" y1="{50 * position()}" x2="{10 * 50}" y2="{50 * position()}"
                          stroke="blue" stroke-width="1"/>
                
                <!-- lignes verticales -->
                <svg:line x1="{50 * position()}" y1="0" x2="{50 * position()}" y2="{10 * 50}"
                          stroke="blue" stroke-width="1"/>
                
                <!-- colonnes -->
                <svg:text x="{(50 * position()) - (50 div 2)}" y="-10" text-anchor="middle" fill="#9999ff" font-size="16">
                    <xsl:value-of select="codepoints-to-string(64 + position())"/>
                </svg:text>
                
                <!-- lignes -->
                <svg:text x="-10" y="{(50 * position()) - (50 div 2)}" text-anchor="end" dominant-baseline="middle" fill="#9999ff" font-size="16">
                    <xsl:value-of select="position()"/>
                </svg:text>
            </xsl:for-each>

            <!-- Dessiner les navires -->
            <xsl:apply-templates select="grille/caseGrille"/>
            
            <xsl:apply-templates select="flotte/porteAvions/caseBateau"/>
            <xsl:apply-templates select="flotte/croiseur/caseBateau"/>
            <xsl:apply-templates select="flotte/contreTorpilleur/caseBateau"/>
            <xsl:apply-templates select="flotte/sousMarin/caseBateau"/>

            <!-- Dessiner les tirs -->
            <xsl:apply-templates select="tirsReçus/tir"/>

    </svg:g>

    </xsl:template>
    <!-- Template pour les cases -->
    <xsl:template match="caseGrille">
        <xsl:variable name="x" select="(string-to-codepoints(@colonne) - 65) * 50"/>
        <xsl:variable name="y" select="(@ligne - 1) * 50"/>
        <svg:rect x="{$x + 2}" y="{$y + 2}" width="46" height="46" fill="#9999ff" stroke="black" stroke-width="1" />
    </xsl:template>

    <!-- Template pour un tir -->
    <xsl:template match="tir">
        <xsl:variable name="x" select="(string-to-codepoints(@colonne) - 65) * 50 + (50 div 2)"/>
        <xsl:variable name="y" select="(@ligne - 1) * 50 + (50 div 2)"/>           
        <!-- Marqueur de tir -->
        <svg:g transform="translate({$x},{$y})">
        <svg:circle r="5" fill="pink"></svg:circle>
        </svg:g>
    </xsl:template>

    <xsl:template match="caseBateau">
        <xsl:variable name="x" select="(string-to-codepoints(@colonne) - 65) * 50"/>
        <xsl:variable name="y" select="(@ligne - 1) * 50"/>  
        <svg:rect x="{$x + 2}" y="{$y + 2}" width="46" height="46" fill="red" stroke="black" stroke-width="1"/>
    </xsl:template>

    <!-- Template pour l'état de la partie -->
    <!-- <xsl:template match="etatPartie">
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
    </xsl:template> -->


<!-- TODO FAIRE UN FOR EACH -->
<!--    <xsl:template match="flotte">
        <h3>Flotte :</h3>
        <ul>
            <xsl:apply-templates select="porteAvions | croiseur | contreTorpilleur | sousMarin"/>
        </ul>
    </xsl:template>

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
    </xsl:template> -->

    <!-- Template pour les tirs reçus -->
    <!-- <xsl:template match="tirsReçus">
        <h3>Tirs Reçus :</h3> -->

        <!-- TODO FAIRE UN FOR EACH -->
        <!-- <ul>
            <xsl:apply-templates select="tir"/>
        </ul> -->
    <!-- </xsl:template> -->
 
 <!-- TODO -->
    <!-- Template pour un tir -->
    <!-- <xsl:template match="tir">
        <li>
            Tir en <xsl:value-of select="@ligne"/> <xsl:value-of select="@colonne"/> - État : <xsl:value-of select="@etat"/>
        </li>
    </xsl:template> -->

  <!-- Template pour valider la grille -->
    <!-- <xsl:template name="validationGrille">
        <svg:g transform="translate(50, 550)">
            <xsl:if test="count(//flotte/porteAvions) != 1 or count(//flotte/croiseur) != 2 or count(//flotte/contreTorpilleur) != 3 or count(//flotte/sousMarin) != 4">
                <svg:text x="0" y="0" fill="red" font-size="18">La flotte n'est pas complète</svg:text>
            </xsl:if>

            <xsl:for-each select="joueur1/grille/case[@etat='bateau']">
                <xsl:variable name="ligne" select="@ligne"/>
                <xsl:variable name="colonne" select="@colonne"/>
                <xsl:variable name="bateauId" select="ancestor::porteAvions/@id | ancestor::croiseur/@id | ancestor::contreTorpilleur/@id | ancestor::sousMarin/@id"/>
                <xsl:for-each select="//joueur1/grille/case[@etat='bateau' and 
                    not(@ligne = $ligne and @colonne = $colonne) and 
                    abs(number(@ligne) - number($ligne)) &lt;= 1 and abs(string-to-codepoints(@colonne) - string-to-codepoints($colonne)) &lt;= 1 and 
                    (ancestor::porteAvions/@id != $bateauId and ancestor::croiseur/@id != $bateauId and 
                    ancestor::contreTorpilleur/@id != $bateauId and ancestor::sousMarin/@id != $bateauId)]">
                    <svg:text x="20" y="{position() * 25}" font-size="14">
                        Les bateaux sont en contact aux coordonnées : 
                        <xsl:value-of select="concat('(', $ligne, ',', $colonne, ') et (', @ligne, ',', @colonne, ')')"/>
                    </svg:text>
                </xsl:for-each>
            </xsl:for-each>
        </svg:g>
    </xsl:template> -->


</xsl:stylesheet>