# Create-Sequence.ps1
# requires -version 1
#
# Create a sequence object similar to an Oracle sequence.
#
# see : http://www.acs.ilstu.edu/docs/oracle/server.101/b10759/statements_6014.htm
#
# Cr�e un objet s�quence similaire � une s�quence Oracle
# Version sp�cifique � PowerShell v1.0

# L'appel de Nextval n'est pas n�cessaire CurrVal est accessible d�s que l'objet cr��
   

#Propri�t�s en ReadOnly: 
#-----------------------------------------------------------------------------------------

#Tutorial (french) : http://laurent-dardenne.developpez.com/articles/Windows/PowerShell/CreationDeMembresSynthetiquesSousPowerShell/

# Name         : Nom de la s�quence.
#
# CurrVal      : Contient la valeur courante. 
#
# Increment_By : Sp�cifie l'interval entre les num�ros de la s�quence. 
#                Cette valeur enti�re peut �tre n'importe quel nombre entier positif ou n�gatif de type .NET INT, mais elle ne peut pas �tre 0. 
#                L'absolu de cette valeur doit �tre moins (ou �gal) que la diff�rence de MAXVALUE et de MINVALUE. 
#                Si cette valeur est n�gative, alors le s�quence est descendante (ordre d�croissant). 
#                Si la valeur est positive, alors la s�quence est ascendante (ordres croissant). 
#                Si vous omettez ce param�tre la valeur de l'interval est par d�faut de 1.
#
# Start_With   : Sp�cifie le premier nombre de la s�quence � produire. 
#                Employez ce param�tre pour d�marrer une s�quence ascendante � une valeur plus grande que son minimum ou pour  
#                d�marrer une s�quence descendante � une valeur moindre que son maximum. Pour des s�quences ascendantes, 
#                la valeur par d�faut est la valeur minimum de la s�quence. Pour des s�quences descendantes, la valeur par d�faut 
#                est la valeur maximum de la s�quence.
#                Note :
#                 Cette valeur n'est pas n�cessairement la valeur � laquelle une s�quence ascendante cyclique red�marre une fois 
#                 sa valeur maximum ou minimum atteinte. 
#
# MaxValue     : Sp�cifie la valeur maximum que la s�quence peut produire. 
#                MAXVALUE doit �tre �gal ou plus grand que le valeur du param�tre START_WITH et doit �tre plus grand que MINVALUE.
#
# MinValue     : Sp�cifie la valeur minimum de la s�quence. 
#                MINVALUE doit �tre inf�rieur ou �gal � le valeur du param�tre START_WITH  et doit �tre inf�rieure � MAXVALUE.
#
# Cycle        : Indique que la s�quence continue � produire des valeurs une fois atteinte sa valeur maximum ou minimum. 
#                Une fois qu'une s�quence ascendante a atteint sa valeur maximum, elle reprend � sa valeur minimum. 
#                Une fois qu'une s�quence descendante a atteint sa valeur minimum, elle reprend � sa valeur maximum.
#                Par d�faut une s�quence ne produit plus de valeurs une fois atteinte sa valeur maximum ou minimum. 
#
# Comment      : Commentaire.
#
#M�thodes :
#-----------------------------------------------------------------------------------------
# NextVal: Incr�mente la s�quence et retourne la nouvelle valeur.



# ** Le fonctionnment de cet objet s�quence est similaire � celui d'une s�quence Oracle sans pour autant �tre identique.

# Si vous ne sp�cifiez aucun param�tre, autre que le nom obligatoire, alors vous cr�ez une s�quence ascendante qui 
# d�bute � 1 et est incr�ment�e de 1 jusqu'� sa limite sup�rieure ([int]::MaxValue). 
# Si vous sp�cifiez seulement INCREMENT_BY -1 vous cr�ez une s�quence d�scendante qui d�bute � -1 et 
# est d�cr�ment�e de 1 jusqu'� sa limite inf�rieure ([int]::MinValue).

# Pour cr�er une s�quence ascendante qui incr�mente sans limite (autre que celle du type .NET INT), omettez le param�tre MAXVALUE. 
# Pour cr�er une s�quence descendante qui d�cr�mente sans limite, omettez le param�tre MINVALUE.

# Pour cr�er une s�quence ascendante qui s'arr�te � une limite pr�d�finie, sp�cifiez une valeur pour le param�tre MAXVALUE. 
# Pour cr�er une s�quence descendante qui s'arr�te � une limite pr�d�finie, sp�cifiez une valeur pour le param�tre MINVALUE. 
# Si vous ne pr�cisez pas le param�tre -CYCLE, n'importe quelle tentative de produire un num�ro de s�quence une fois que la s�quence 
# a atteint sa limite d�clenchera une erreur.

# Pour cr�er une s�quence qui red�marre/boucle apr�s avoir atteint une limite pr�d�finie, indiquez le param�tre CYCLE. Dans ce cas 
# vous devez obligatoirement sp�cifiez une valeur pour les param�tres MAXVALUE ou MINVALUE. 

#Valeur par d�faut d'une s�quence ascendante :
# $Sq=Create-Sequence "SEQ_Test"  ;$Sq
#
# Name         : SEQ_Test
# CurrVal      : 1
# Increment_By : 1
# MaxValue     : 2147483647
# MinValue     : 1
# Start_With   : 1
# Cycle        : False
# Comment      :

#Valeur par d�faut d'une s�quence descendante :
# $Sq=Create-Sequence "SEQ_Test" -inc -1  ;$Sq
# 
# Name         : SEQ_Test
# CurrVal      : -1
# Increment_By : -1
# MaxValue     : -1
# MinValue     : -2147483648
# Start_With   : -1
# Cycle        : False
# Comment      :

#Exemple :
# $DebugPreference = "Continue"
# $Sq= Create-Sequence "SEQ_Test"
# $Sq.Currval
# $Sq.NextVal()
# $Sq.Currval

Function Create-Sequence
{
  #Tous les param�tres sont contraint, i.e. on pr�cise un type. 
 param([String] $Sequence_Name, 
       [String] $Comment,
       $Increment_By=1,
       $MaxValue,
       $MinValue,
       $Start_With,            
       [switch] $Cycle)

  function ValidateParameter([string]$Name,$Parameter,[Type] $Type)
  {  # Renvoi True si le type est celui attendu et si le contenu n'est pas $Null ou si on peut caster 
     # la valeur re�ue dans le type attendu
     # Renvoi False si le contenu est � $Null.
     # D�clenche une exception ArgumentTransformationMetadataException si le type n'est pas celui attendu. 
   
    Write-Debug "ValidateParameter"
    Write-debug "$Name"
    if ($Parameter -ne $null) 
     {Write-debug "$($Parameter.GetType())"}
    else {Write-debug "`$Parameter est � `$null."}
    Write-debug "$Parameter"
    Write-debug "$Type"
    
    
    if (($Parameter -eq $null)) 
    { Write-Debug "Le param�tre $Name est � `$null."
      return $False
    }
    elseif ($Parameter -isNot $Type) 
     {  #Peut-on caster la valeur re�ue dans le type attendu ?
       if (!($Parameter -as $Type)) 
        {
         #r�cup�re le contexte d'appel de l'appelant
         $Invocation = (Get-Variable MyInvocation -Scope 1).Value
         throw (new-object System.Management.Automation.ArgumentTransformationMetadataException "$($Invocation.MyCommand).$($MyInvocation.MyCommand) : Impossible de convertir la valeur ��$Parameter � en type ��$($Type.ToString())��.")
        }
     } 
    return $True
  } #ValidateParameter 
  write-Debug "[Valeurs des param�tres]"
  write-Debug "Sequence_Name $Sequence_Name"
  write-Debug "Comment $Comment"
  write-Debug "Increment_By $Increment_By" 
  write-Debug "MaxValue $MaxValue"
  write-Debug "MinValue $MinValue"
  write-Debug "Start_With $Start_With"  
  write-Debug "Cycle $Cycle"        


 if (($Sequence_Name -eq $null) -or ($Sequence_Name -eq [String]::Empty))
  {Throw "Nom de s�quence invalide. La valeur de Sequence_Name doit �tre renseign�e."}

 write-Debug "Test isTypeEqual termin�."

 if ( (!(ValidateParameter "Increment_By" $Increment_By System.Int32) ) -and ($Increment_By -eq 0) ) 
  {Throw "La valeur de Increment_By doit �tre un entier diff�rent de z�ro."}
     
# Valeur par d�faut
# Si on ne sp�cifie aucun param�tre alors on cr�e une s�quence ascendante qui d�bute � 1
# est incr�ment�e de 1 sans limite de valeur sup�rieure (autre que celle du type utilis�)   
#Si on sp�cifie seulement -Increment_By -1 on cr�e une s�quence descendante qui d�bute � -1
# est d�cr�ment�e de -1 sans limite de valeur inf�rieure (autre que celle du type utilis�)
 write-Debug ""
 write-Debug "Les valeurs par d�faut pour la s�quence de type sont :"

#Ici si $Increment_By n'est pas renseign� il vaut par d�faut 1, on ne peut donc avoir 0 comme valeur renvoy�e par la m�thode Sign 
$local:Signe=[System.Math]::Sign($Increment_By)      
 write-Debug "`tIncrement_By $Increment_By"
 write-Debug "`tSigne $Signe (1= positif  -1= n�gatif)"
 
 if ( ($Signe -eq 1) -and
       #test si les param�tres  sont � $null
      (!(ValidateParameter "Start_With" $Start_With System.Int32)) -and
      (!(ValidateParameter "MaxValue" $MaxValue System.Int32)) -and
      (!(ValidateParameter "MinValue" $MinValue System.Int32)) 
     )
      { write-Debug "`tS�quence ascendante. Valeur par d�faut."
        $Start_With=1     
        $MaxValue=[int]::MaxValue
        $MinValue=1
      }
 elseif 
    ( ($Signe -eq -1) -and
      (!(ValidateParameter "Start_With" $Start_With System.Int32)) -and
      (!(ValidateParameter "MaxValue" $MaxValue System.Int32)) -and
      (!(ValidateParameter "MinValue" $MinValue System.Int32))
     )
      { write-Debug "`tS�quence descendante. Valeur par d�faut."
        $Start_With=-1     
        $MaxValue=-1
        $MinValue=[int]::MinValue
      }
 else
  { 
    write-Debug "`t* Pas de valeur par d�faut. *"
 
    # Si MaxValue n'est pas sp�cifi� on indique la valeur maximum pour une s�quence ascendante 
    # sinon 1 pour une s�quence descendante    
    if (!(ValidateParameter "MaxValue" $MaxValue System.Int32))
    { $MaxValue=[int]::MaxValue 
      if ($local:Signe -eq -1)
       {$MaxValue=-1 }
    }
    # Si MinValue n'est pas sp�cifi� on indique la valeur 1 pour une s�quence ascendante 
    # sinon la valeur minimum  pour une s�quence descendante    
   if (!(ValidateParameter "MinValue" $MinValue System.Int32))
    { $MinValue=1
      if ($Signe -eq -1)
       {$MinValue=[int]::MinValue }
    }
     
     # Si Start_With n'est pas sp�cifi� on indique, pour une s�quence ascendante, la valeur minimum de la s�quence 
     # ou pour une s�quence descendante la valeur maximum de la s�quence.
   if (!(ValidateParameter "Start_With" $Start_With System.Int32)) 
    {
     switch ($local:Signe)
      { 
        1  {$Start_With=$MinValue}
       -1  {$Start_With=$MaxValue}
      }#switch    
    }#If
 }#else 
 
 write-Debug "Start_With $Start_With"
 write-Debug "MaxValue $MaxValue"
 write-Debug "MinValue $MinValue"

 if (!(ValidateParameter "Increment_By" $Increment_By System.Int32))
  { 
   if ($Cycle.Ispresent) 
    { #Dans ce cas selon le signe du param�tre $Increment_By on doit pr�ciser soit Minvalue soit MaxValue  
     switch ($local:Signe)
      { 
       1  { if (!(ValidateParameter "MinValue" $MinValue System.Int32)) 
             { Throw "S�quence ascendante cyclique pour laquelle vous devez sp�cifier MinValue."}
          }
      -1  { if (!(ValidateParameter "MaxValue" $MaxValue System.Int32))
            { Throw "S�quence descendante cyclique pour laquelle vous devez sp�cifier MaxValue."}
          }
      default  { Throw "Analyse erron�e!"}
      }#switch
    }#if cycle
  }#if increment
 write-Debug "Test de la variable Cycle termin�."      
 write-Debug "[Test de validit� de la s�quence]"     

 # MINVALUE must be less than or equal to START WITH and must be less than MAXVALUE. 
 if (!($MinValue -le $Start_With ))
  { Throw "Start_With($Start_With) ne peut pas �tre inf�rieur � MinValue($MinValue)."}
 elseif (!($MinValue -lt $MaxValue))
  { Throw "MinValue($MinValue) doit �tre inf�rieure � MaxValue($MaxValue)."}
 # MAXVALUE must be equal to or greater than START WITH and must be greater than MINVALUE.
 if (!($MaxValue -ge $Start_With))
   { Throw "Start_With($Start_With) ne peut pas �tre sup�rieur � MaxValue($MaxValue)."}
 elseif (!($MaxValue -gt $MinValue))
  { Throw "MaxValue($MaxValue) doit �tre sup�rieure � MinValue($MinValue)."}
  
  #On test s'il est possible d'it�rer au moins une fois.
  #La construction suivant est valide mais pour un seul chiffre :
  # $Sq=Create-Sequence $N $C -inc 1 -min 0 -max 5 -start 5
  # $Sq=Create-Sequence $N $C -inc -1 -min 0 -max 2 -start 0
    
  #Start_with n'est pas pris en compte dans ce calcul, on autorise donc un s�quence proposant un seul nombre.
  #Si dans ce cas on pr�cise le switch -Cycle on a bien plusieurs it�rations :
  # $Sq=Create-Sequence $N $C -inc 1 -min 0 -max 5 -start 5 -cycle

  #On cast $Increment_By car sa valeur peut �tre �gale � [int]::MinValue, d'o� une exception lors de l'appel � Abs
  # La documentation Oracle pr�cise l'op�rateur -lt mais dans ce cas la s�quence suivante est impossible :
  #  Create-Sequence $N $C -min 1 -max 2 
 if (!([system.Math]::Abs([Long]$Increment_By) -le ($MaxValue-$MinValue)) )
  { Throw "Increment_By($Increment_By) doit �tre inf�rieur ou �gale � MaxValue($MaxValue) moins MinValue($MinValue)."} 

#Cr�ation de la s�quence
 $Sequence= new-object System.Management.Automation.PsObject
 # Ajout des propri�t�s en R/O, le code est cr�� dynamiquement
$MakeReadOnlyMember=@"
`$Sequence | add-member ScriptProperty Name         -value {"$Sequence_Name"}   -Passthru|`
             add-member ScriptProperty Comment      -value {"$Comment"}         -Passthru|`
             add-member ScriptProperty Increment_By -value {[int]$Increment_By} -Passthru|`
             add-member ScriptProperty MaxValue     -value {[int]$MaxValue}     -Passthru|`
             add-member ScriptProperty MinValue     -value {[int]$MinValue}     -Passthru|`
             add-member ScriptProperty Start_With   -value {[int]$Start_With}   -Passthru|`
             add-member ScriptProperty Cycle        -value {`$$Cycle}           -Passthru|`
             add-member ScriptProperty CurrVal      -value {[int]$Start_With}
"@
  Invoke-Expression $MakeReadOnlyMember
  
  #La m�thode NextVal renvoie en fin de traitement la valeur courante du membre Currval
 $Sequence | add-member ScriptMethod NextVal {   
                          $NewValue=$this.CurrVal + $this.Increment_By
                          write-debug "this $this"
                          write-debug "NewValue $NewValue"
                           
                           #D�claration param�tr�e pour la red�finition du membre CurrVal
                           #Le param�tre -Force annule et remplace la d�finition du membre sp�cifi�
                          $RazMember="`$this | add-member -Force ScriptProperty CurrVal  -value {0}"
                                                                                                  
                          switch ([System.Math]::Sign($this.Increment_By))
                          {  
                              #MAXVALUE cannot be made to be less than the current value
                             1  { if ($NewValue -gt  $this.MaxValue)
                                  { write-debug "Borne maximum atteinte."
                                    
                                    if ($this.Cycle -eq $true) #Dans ce cas on recommence
                                     { #On construit (par formatage) la d�finition du membre CurrVal 
                                       #puis on reconstruit le membre.
                                      Invoke-Expression ($RazMember -F "{[int]$this.MinValue}")
                                     } 
                                    else {Throw "La s�quence $($this.Name).Nextval a atteint la valeur maximum autoris�e."}
                                  }
                                  else { Invoke-Expression ($RazMember -F "{[int]$NewValue}")}
                                }#S�quence ascendante

                              #MINVALUE cannot be made to exceed the current value 
                            -1  { if ($NewValue -lt  $this.MinValue)
                                  { write-debug "Borne minimum atteinte."
                                    if ($this.Cycle -eq $true)
                                     {Invoke-Expression ($RazMember -F "{[int]$this.MaxValue}") }
                                    else {Throw "La s�quence $($this.Name).Nextval a atteint la valeur minimum autoris�e."}
                                  }
                                  else {Invoke-Expression ($RazMember -F "{[int]$NewValue}") }
                                }#S�quence descendante
                             else {Throw "Erreur dans la m�thode Nextval."}    
                          }#switch
                           #Renvoi la nouvelle valeur
                          $this.CurrVal
                          write-debug "this $this"
                        }

 write-Debug "[Valeurs de la s�quence]"
 write-Debug "Sequence_Name $Sequence_Name"
 write-Debug "Comment $Comment"
 write-Debug "Increment_By $Increment_By" 
 write-Debug "MaxValue $MaxValue"
 write-Debug "MinValue $MinValue"
 write-Debug "Start_With $Start_With"  
 write-Debug "Cycle $Cycle"        
 write-Debug "Current $Current"
 write-Debug "----"
 write-Debug  $Sequence

  #Sp�cifie l'affichage des propri�t�s par d�faut
  #On �vite ainsi l'usage d'un fichier de type .ps1xml
  #From http://poshoholic.com/2008/07/05/essential-powershell-define-default-properties-for-custom-objects/
 $DefaultProperties =@(
  'Name',
  'CurrVal', 
  'Increment_By',
  'MaxValue',
  'MinValue',
  'Start_With',
  'Cycle',
  'Comment')
 $DefaultPropertySet=New System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$DefaultProperties)
 $PSStandardMembers=[System.Management.Automation.PSMemberInfo[]]@($DefaultPropertySet)
 $Sequence|Add-Member MemberSet PSStandardMembers $PSStandardMembers

 return $Sequence
}

# Examples :

#  # Valeur pas d�faut
#   #S�quence ascendante
# $Sq=Create-Sequence "SEQ_Test"
# $Sq=Create-Sequence "SEQ_Test" ""
# $Sq=Create-Sequence "SEQ_Test" "S�quence de test"
# $Sq=Create-Sequence "SEQ_Test" "S�quence de test" -cycle
#  #Valeur pas d�faut d'une s�quence ascendante
# $Sq=Create-Sequence "SEQ_Test" "S�quence de test" -min 1 -max ([int32]::MaxValue) -inc 1 -start 1
#  #Valeur pas d�faut d'une s�quence descendante
# $Sq=Create-Sequence "SEQ_Test" "S�quence de test" -min ([int32]::MinValue) -max -1 -inc -1 -start -1
# 
#  #Incr�ment de 2
# $Sq=Create-Sequence "SEQ_Test" "S�quence de test" -inc 2
#  #Incr�ment n�gatif
# $Sq=Create-Sequence "SEQ_Test" "S�quence de test" -inc -1
# 
# 
# $N="SEQ_Test" 
# $C="S�quence de test"
#  
#  #Suite ascendante maximum, de [int32]::MinValue � [int32]::MaxValue d�butant � [int32]::MinValue
# $Sq=Create-Sequence $N $C -min ([int32]::MinValue+1) -start ([int32]::MinValue+1)
#  #Suite descendante maximum, de [int32]::MinValue � [int32]::MaxValue d�butant � [int32]::MaxValue
# $Sq=Create-Sequence $N $C -min ([int32]::MinValue+1) -max ([int32]::MaxValue) -start ([int32]::MaxValue) -inc -1
# 
#  #suite ascendante d�butant � 0 et finissant � 255
# $Sq=Create-Sequence $N $C -min 0 -max 255
#  
#  
#  #Valeur minimum
#   #suite ascendante de 2 nombres 
# $Sq=Create-Sequence $N $C -minvalue 0 -maxvalue 1
#   #suite descendante de 2 nombres  
# $Sq=Create-Sequence $N $C -minvalue 0 -maxvalue 1  -inc -1
#   #suite de 2 nombres positifs avec un pas de 2 
# $sq=Create-Sequence $N $C -min 1 -max 3 -inc 2
#  
#  #"suite" de 1 nombre : 2 
# $sq=Create-Sequence $N $C -min 1 -max 2 -start 2
#  #"suite" de 1 nombre : 5
# $Sq=Create-Sequence $N $C -min 0 -max 5 -inc 1 -start 5
#  #"suite" de 1 nombre : 0
# $Sq=Create-Sequence $N $C -min 0 -max 2 -inc -1 -start 0
# 
#  #suite cyclique ascendante d�butant � 2, ensuite chaque cycle d�butera � 1, c'est � dire la valeur de MinValue
# $sq=Create-Sequence $N $C -min 1 -max 2 -start 2 -cycle
#  #suite cyclique ascendante  d�butant � 5, ensuite chaque cycle d�butera � 0
# $Sq=Create-Sequence $N $C -min 0 -max 5 -inc 1 -start 5 -cycle
#  #suite cyclique descendante d�butant � 0, ensuite chaque cycle d�butera aussi � 0
# $Sq=Create-Sequence $N $C -min 0 -max 2 -inc -1 -start 0 -cycle
# 
#   #MaxValue � 0, pour une suite descendante uniquement 
# $Sq=Create-Sequence $N $C -maxvalue 0 -inc -1
# 
#   #suite descendante d�butant � -1 jusqu'� [int32]::MinValue
# $Sq=Create-Sequence $N $C -maxvalue -1 -inc -1
#  #suite ascendante n�gative d�butant [int32]::MinValue jusqu'� -1 
# $Sq=Create-Sequence $N $C -min -2147483648 -max -1 -inc 1 -start -2147483648

