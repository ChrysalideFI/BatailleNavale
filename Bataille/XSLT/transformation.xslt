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
            <xsl:call-template name="validationGrille"/>
            <xsl:call-template name="verifierFinPartie"/>
            <xsl:call-template name="afficherEtatNaviresEtTirsManques"/>
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

            <!-- Vérifier des contacts-->
            <svg:text x="0" y="0" font-size="18" fill="red">Vérification des contacts entre bateaux :</svg:text>
        
            <!-- Parcourir les cases contenant des bateaux -->
            <xsl:for-each select="//joueur1/grille/caseGrille[@etat='bateau']">
                <xsl:variable name="ligneGrille" select="@ligne"/>
                <xsl:variable name="colonneGrille" select="@colonne"/>

                <!-- ID du bateau de cette case -->
                <xsl:variable name="idParent" select="//joueur1/flotte/*/caseBateau[@ligne=$ligneGrille and @colonne=$colonneGrille]/../@id"/>

                <!-- Vérifier les cases adjacentes -->
                <xsl:for-each select="//joueur1/grille/caseGrille[@etat='bateau']">
                    <xsl:if test="not(@ligne = $ligneGrille and @colonne = $colonneGrille) and abs(number(@ligne) - number($ligneGrille)) &lt;= 1 and abs(string-to-codepoints(@colonne) - string-to-codepoints($colonneGrille)) &lt;= 1">
                        
                        <!-- ID du bateau adjacent -->
                        <xsl:variable name="idAdjacent" select="//joueur1/flotte/*/caseBateau[@ligne=@ligne and @colonne=@colonne]/../@id"/>

                        <!-- Vérifier si les bateaux sont différents -->
                        <xsl:if test="$idParent != $idAdjacent">
                            <svg:text x="0" y="{20 + position() * 20}" font-size="16" fill="red">
                                Les bateaux <xsl:value-of select="$idParent"/> et <xsl:value-of select="$idAdjacent"/> sont en contact aux coordonnées (<xsl:value-of select="$ligneGrille"/>,<xsl:value-of select="$colonneGrille"/>).
                            </svg:text>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </svg:g>
    </xsl:template>

        <!-- <xsl:variable name="bateauId" select="ancestor::porteAvions/@id | ancestor::croiseur/@id | ancestor::contreTorpilleur/@id | ancestor::sousMarin/@id"/>
    <xsl:for-each select="//joueur1/grille/caseGrille[@etat='bateau' and not(@ligne = $ligne and @colonne = $colonne) and abs(number(@ligne) - number($ligne)) &lt;= 1 and abs(string-to-codepoints(@colonne) - string-to-codepoints($colonne)) &lt;= 1 and 
        (ancestor::porteAvions/@id != $bateauId and ancestor::croiseur/@id != $bateauId and 
        ancestor::contreTorpilleur/@id != $bateauId and ancestor::sousMarin/@id != $bateauId)]">
        <svg:text x="20" y="140" font-size="14">
            Les bateaux sont en contact aux coordonnées : 
            <xsl:value-of select="concat('(', $ligne, ',', $colonne, ') et (', @ligne, ',', @colonne, ')')"/>
        </svg:text>
    </xsl:for-each> -->

    <!-- Template pour vérifier la fin de partie -->
    <xsl:template name="verifierFinPartie">
        <!-- Vérification de fin de partie -->
        <xsl:variable name="joueur1TousCoules" select="count(//joueur1/flotte/*[/@etat='coule']) = count(//joueur1/flotte/*)"/>
        <xsl:variable name="joueur2TousCoules" select="count(//joueur2/flotte/*[/@etat='coule']) = count(//joueur2/flotte/*)"/>

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
            Nombre de tirs manqués : <xsl:value-of select="count(//tir[@etat='manque'])"/>
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


    <!-- <xsl:template name="validerGrille">
        <svg:g transform="translate(50, 550)">
            <xsl:variable name="validation">
                <xsl:call-template name="verifierNombresNavires"/>
            </xsl:variable>
            
            <xsl:variable name="contacts">
                <xsl:call-template name="verifierContacts"/>
            </xsl:variable>

            <xsl:choose>
                <xsl:when test="$validation/erreurs/erreur or $contacts/contacts/contact">
                    <svg:text x="0" y="0" fill="red" font-size="18">Configuration invalide :</svg:text>
                    
                    <xsl:for-each select="$validation/erreurs/erreur">
                        <svg:text x="20" y="{position() * 25}" font-size="14">
                            <xsl:value-of select="."/>
                        </svg:text>
                    </xsl:for-each>
                    
                    <xsl:for-each select="$contacts/contacts/contact">
                        <svg:text x="20" y="{(count($validation/erreurs/erreur) + position()) * 25}" 
                                font-size="14">
                            Contact entre navires aux coordonnées : <xsl:value-of select="@cases"/>
                        </svg:text>
                    </xsl:for-each>
                </xsl:when>
                
                <xsl:otherwise>
                    <svg:text x="0" y="0" fill="green" font-size="18">Configuration valide</svg:text>
                    
                    <xsl:call-template name="afficherEtatNavires"/>
                    
                    <xsl:if test="count(//navire[every $case in case satisfies $case/@etat='touche']) 
                                = count(//navire)">
                        <svg:text x="0" y="200" fill="red" font-size="24">
                            PARTIE TERMINÉE - Tous les navires sont coulés !
                        </svg:text>
                    </xsl:if>
                    
                    <svg:text x="0" y="240" font-size="16">
                        Nombre de tirs à l'eau : <xsl:value-of select="count(//tir[@etat='eau'])"/>
                    </svg:text>
                </xsl:otherwise>
            </xsl:choose>
        </svg:g>
    </xsl:template> -->

    <!-- Template pour vérifier le nombre de navires -->
    <!-- <xsl:template name="verifierNombresNavires">
        <erreurs>
            <xsl:if test="count(//flotte/porteAvion) != 1">
                <erreur>Nombre incorrect de porte-avions : 
                    <xsl:value-of select="count(//flotte/porteAvion)"/>/1
                </erreur>
            </xsl:if>
            <xsl:if test="count(//flotte/croiseur) != 2">
                <erreur>Nombre incorrect de croiseurs : 
                    <xsl:value-of select="count(//flotte/croiseur)"/>/2
                </erreur>
            </xsl:if>
            <xsl:if test="count(//flotte/contreTorpilleur) != 3">
                <erreur>Nombre incorrect de contre-torpilleurs : 
                    <xsl:value-of select="count(//flotte/contreTorpilleur"/>/3
                </erreur>
            </xsl:if>
            <xsl:if test="count(//flotte/sousMarin) != 4">
                <erreur>Nombre incorrect de sous-marins : 
                    <xsl:value-of select="count(//flotte/sousMarin)"/>/4
                </erreur>
            </xsl:if>
        </erreurs>
    </xsl:template> -->

    <!-- Template pour vérifier les contacts entre navires -->
    <!-- <xsl:template name="verifierContacts">
        <contacts>
            <xsl:for-each select="//navire">
                <xsl:variable name="navire1" select="."/>
                <xsl:for-each select="following::navire">
                    <xsl:variable name="navire2" select="."/>
                    <xsl:for-each select="$navire1/case">
                        <xsl:variable name="case1" select="."/>
                        <xsl:for-each select="$navire2/case">
                            <xsl:variable name="case2" select="."/>
                            <xsl:if test="
                                (abs(string-to-codepoints($case1/@colonne) - 
                                    string-to-codepoints($case2/@colonne)) &lt;= 1 and
                                abs(xs:integer($case1/@ligne) - xs:integer($case2/@ligne)) &lt;= 1)">
                                <contact cases="{$case1/@colonne}{$case1/@ligne} et 
                                              {$case2/@colonne}{$case2/@ligne}"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
        </contacts>
    </xsl:template> -->

    <!-- Template pour afficher l'état des navires -->
    <!-- <xsl:template name="afficherEtatNavires">
        <xsl:for-each select="//navire">
            <xsl:variable name="touches" select="count(case[@etat='touche'])"/>
            <xsl:variable name="total" select="count(case)"/>
            <svg:text x="20" y="{position() * 25 + 25}" font-size="14">
                <xsl:value-of select="@type"/> 
                (<xsl:value-of select="@id"/>) : 
                <xsl:choose>
                    <xsl:when test="$touches = $total">COULÉ</xsl:when>
                    <xsl:when test="$touches > 0">Touché (<xsl:value-of select="$touches"/>/<xsl:value-of select="$total"/>)</xsl:when>
                    <xsl:otherwise>Intact</xsl:otherwise>
                </xsl:choose>
            </svg:text>
        </xsl:for-each>
    </xsl:template> -->
</xsl:stylesheet>