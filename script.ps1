Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Création du formulaire
$form = New-Object System.Windows.Forms.Form
$form.Text = "Gestion des droits d'accès"
$form.Size = New-Object System.Drawing.Size(800, 500)  # Taille agrandie

# Ajout du label et de la zone de texte pour le chemin du répertoire
$labelPath = New-Object System.Windows.Forms.Label
$labelPath.Text = "Chemin du répertoire :"
$labelPath.AutoSize = $true
$labelPath.Location = New-Object System.Drawing.Point(10, 20)

$textBoxPath = New-Object System.Windows.Forms.TextBox
$textBoxPath.Size = New-Object System.Drawing.Size(400, 20)
$textBoxPath.Location = New-Object System.Drawing.Point(150, 20)

# Bouton pour valider le chemin
$buttonValidatePath = New-Object System.Windows.Forms.Button
$buttonValidatePath.Text = "Valider le chemin"
$buttonValidatePath.Size = New-Object System.Drawing.Size(150, 30)  # Taille agrandie
$buttonValidatePath.Location = New-Object System.Drawing.Point(10, 60)

$labelReadOnly = New-Object System.Windows.Forms.Label
$labelReadOnly.Text = "Groupes en lecture seule :"
$labelReadOnly.AutoSize = $true
$labelReadOnly.Location = New-Object System.Drawing.Point(10, 100)

# Liste déroulante pour les groupes en lecture seule
$comboBoxReadOnly = New-Object System.Windows.Forms.ComboBox
$comboBoxReadOnly.Size = New-Object System.Drawing.Size(200, 20)
$comboBoxReadOnly.Location = New-Object System.Drawing.Point(150, 100)

$labelReadWrite = New-Object System.Windows.Forms.Label
$labelReadWrite.Text = "Groupes en lecture-écriture :"
$labelReadWrite.AutoSize = $true
$labelReadWrite.Location = New-Object System.Drawing.Point(360, 100)

# Liste déroulante pour les groupes en lecture-écriture
$comboBoxReadWrite = New-Object System.Windows.Forms.ComboBox
$comboBoxReadWrite.Size = New-Object System.Drawing.Size(200, 20)
$comboBoxReadWrite.Location = New-Object System.Drawing.Point(500, 100)

# Ajout du label et de la zone de texte pour l'utilisateur
$labelUser = New-Object System.Windows.Forms.Label
$labelUser.Text = "Utilisateur :"
$labelUser.AutoSize = $true
$labelUser.Location = New-Object System.Drawing.Point(10, 140)

$textBoxUser = New-Object System.Windows.Forms.TextBox
$textBoxUser.Size = New-Object System.Drawing.Size(300, 20)
$textBoxUser.Location = New-Object System.Drawing.Point(150, 140)

# Bouton pour ajouter les droits
$buttonAddRights = New-Object System.Windows.Forms.Button
$buttonAddRights.Text = "Ajouter les droits"
$buttonAddRights.Size = New-Object System.Drawing.Size(150, 30)  # Taille agrandie
$buttonAddRights.Location = New-Object System.Drawing.Point(10, 180)

# Ajout des contrôles au formulaire
$form.Controls.Add($labelPath)
$form.Controls.Add($textBoxPath)
$form.Controls.Add($buttonValidatePath)
$form.Controls.Add($labelReadOnly)
$form.Controls.Add($comboBoxReadOnly)
$form.Controls.Add($labelReadWrite)
$form.Controls.Add($comboBoxReadWrite)
$form.Controls.Add($labelUser)
$form.Controls.Add($textBoxUser)
$form.Controls.Add($buttonAddRights)

# Action lors du clic sur le bouton de validation du chemin
$buttonValidatePath.Add_Click({
    $directoryPath = $textBoxPath.Text
    if (Test-Path -Path $directoryPath) {
        [System.Windows.Forms.MessageBox]::Show("Chemin valide : $directoryPath")
        
        # Récupérer les groupes de sécurité
        $acl = Get-Acl -Path $directoryPath
        $groupsReadOnly = $acl.Access | Where-Object { $_.IdentityReference -match "Domain\\" -and $_.FileSystemRights -match 'ReadAndExecute' } | Select-Object -ExpandProperty IdentityReference
        $groupsReadWrite = $acl.Access | Where-Object { $_.IdentityReference -match "Domain\\" -and $_.FileSystemRights -notmatch 'ReadAndExecute' } | Select-Object -ExpandProperty IdentityReference
        
        $comboBoxReadOnly.Items.Clear()
        if ($groupsReadOnly) {
            $comboBoxReadOnly.Items.AddRange($groupsReadOnly | ForEach-Object { $_.Value })
        }

        $comboBoxReadWrite.Items.Clear()
        if ($groupsReadWrite) {
            $comboBoxReadWrite.Items.AddRange($groupsReadWrite | ForEach-Object { $_.Value })
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Chemin invalide, veuillez entrer un chemin correct.")
    }
})

# Action lors du clic sur le bouton pour ajouter les droits
$buttonAddRights.Add_Click({
    $selectedGroup = if ($comboBoxReadOnly.SelectedItem) { $comboBoxReadOnly.SelectedItem } else { $comboBoxReadWrite.SelectedItem }
    $user = $textBoxUser.Text

    if ($selectedGroup -and $user) {
        # Vérifier si le groupe est déjà présent pour l'utilisateur
        $userGroups = Get-ADUser -Identity $user -Property MemberOf | Select-Object -ExpandProperty MemberOf
        if ($userGroups -contains $selectedGroup) {
            [System.Windows.Forms.MessageBox]::Show("Le groupe $selectedGroup est déjà présent pour l'utilisateur $user.")
        } else {
            # Ajouter les droits ici
            Add-ADGroupMember -Identity ($selectedGroup -split '\\')[1] -Members $user
            [System.Windows.Forms.MessageBox]::Show("Les droits ont été ajoutés pour le groupe $selectedGroup à l'utilisateur $user.")
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Veuillez sélectionner un groupe et entrer un utilisateur.")
    }
})

# Affichage du formulaire
$form.ShowDialog()
