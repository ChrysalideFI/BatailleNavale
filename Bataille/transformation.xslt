<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svg="http://www.w3.org/2000/svg">

  <!-- Template de base -->
  <xsl:template match="/">
    <html>
      <head>
        <title>Jouez à la Bataille Navale !</title>
      </head>
      <body>
        <h1>Grille de Bataille Navale</h1>
        <xsl:apply-templates select="batailleNavale"/>
      </body>
    </html>
  </xsl:template>

  <!-- Template pour la grille -->
  <xsl:template match="batailleNavale">
    <svg:svg width="500" height="500" xmlns:svg="http://www.w3.org/2000/svg">
      <xsl:apply-templates select="joueur1/grille/case"/>
    </svg:svg>
    <xsl:apply-templates select="etatPartie"/>
  </xsl:template>

  <!-- Template pour les cases -->
  <xsl:template match="case">
     <svg:rect x="{@colonne * 50}" y="{@ligne * 50}" width="50" height="50" fill="{if (@etat='eau') then 'blue' else if (@etat='intact') then 'grey' else if (@etat='touche') then 'orange' else 'red'}" stroke="black"/> 
     <!--si ce n'est pas de l'eau, un bateau intact ou touché alors c'est un bateau coulé qui sera rouge -->
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

  <!-- Template pour les tirs -->
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

  <!-- Validation grille -->
    <xsl:template match="batailleNavale">
        <xsl:if test="not(porteAvions) or count(croiseur)!=2 or count(contreTorpilleur)!=3 or count(sousMarin)!=4">
            <p>La flotte n'est pas complète.</p>
        </xsl:if>
        <xsl:for-each select="joueur1/grille/case[@etat='bateau']">
            <xsl:variable name="ligne" select="@ligne"/>
            <xsl:variable name="colonne" select="@colonne"/>
            <xsl:variable name="bateauId" select="ancestor::porteAvions/@id | ancestor::croiseur/@id | ancestor::contreTorpilleur/@id | ancestor::sousMarin/@id"/>
            <xsl:if test="//case[@etat='bateau' and 
                (not(@ligne = $ligne and @colonne = $colonne) and 
                (abs(number(@ligne) - number($ligne)) &lt;= 1 and abs(number(@colonne) - number($colonne)) &lt;= 1) and 
                (ancestor::porteAvions/@id != $bateauId and ancestor::croiseur/@id != $bateauId and 
                ancestor::contreTorpilleur/@id != $bateauId and ancestor::sousMarin/@id != $bateauId))]">
                <p>Les bateaux sont en contact.</p>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>