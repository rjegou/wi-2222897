# VM de tests Legacy — fiche technique

## Accès
- VMs connues : `Y2-TSTAUTOXXPG1` à `Y2-TSTAUTOXXPG4` ; `Y2-TSTAUTOXXPG2` utilisée pour les plugins étudiés.
- Compte : `CEGIDGROUP\SvcTestAutoRetail`.
- Accès typique : RDP.

### Accès SMB à `vm-RJE-priv`

**FACT rapporté par le mémo utilisateur du 2026-09-11** : la VM `vm-RJE-priv`
(`10.113.64.179`) est joignable en SMB sur TCP `445`, et le partage administratif
`D$` est accessible avec le compte `CEGIDGROUP\jegour`.

- Partage : `\\vm-RJE-priv\D$`.
- Référence du mot de passe : `C:\Users\jegour\OneDrive - CEGID\Documents\vmMdp.txt`.
- Le contenu de ce fichier est un secret : ne pas le lire dans une sortie, le copier,
  le journaliser, le committer ou l'intégrer à un script.

Connexion PowerShell 5.1, avec le mot de passe conservé uniquement en mémoire :

```powershell
$pwd = (Get-Content "C:\Users\jegour\OneDrive - CEGID\Documents\vmMdp.txt" -Raw).Trim()
$sec = ConvertTo-SecureString $pwd -AsPlainText -Force
$cred = New-Object PSCredential("CEGIDGROUP\jegour", $sec)

New-PSDrive -Name VM -PSProvider FileSystem `
    -Root "\\vm-RJE-priv\D$" -Credential $cred
```

Accès et déconnexion :

```powershell
Get-ChildItem "VM:\"
Remove-PSDrive VM
```

Cette fiche documente le routage et la méthode fournis ; elle ne constitue pas une
nouvelle preuve brute ni une autorisation de modifier la VM. Les collectes restent en
lecture seule par défaut et doivent filtrer les secrets avant partage.

## Chemins clés

| Usage | Chemin |
|---|---|
| Moteur Legacy | `D:\CegidUtils\CegidIntegrationTests` |
| Repos/configs plugins | `D:\CegidUtils\CegidIntegrationTests\override\Y2_Plugins_*` |
| Workflow d’un plugin | `...\IntegratedTests\Workflow` |
| Données/fixtures Legacy | `...\IntegratedTests\AutoTest\Data` |
| Historique commande lancée | `D:\CegidUtils\CegidIntegrationTests\history.storage.xml` |
| Log détaillé host | `D:\CegidUtils\CegidIntegrationTests\integrationTestsHost-ip00.log` |
| File/queue host | `D:\CegidUtils\CegidIntegrationTests\integrationTestsHost-nw00.log` |
| Résultats locaux d’exécution | `C:\Users\SvcTestAutoRetail\AppData\Roaming\CegidIntegrationTests` |
| Rapports publiés principaux | `D:\wwwroot\integrationTestsReports` |
| Rapports IIS historiques | `C:\inetpub\wwwroot\integrationTestsReports` |
| Publication TRX | `D:\CegidUtils\PublishTRX` |
| Répertoire temporaire d’un run | `D:\Temp\TempoAutoTest\<GUID>` |
| Archives TRX réseau | `\\cbr-tstauto-sql\Archives\TRX\CBR_AUTO_TT_XX.XX` |
| Config dashboard TRX | `\\cbr-tstauto-sql\Outils\PublishTRX\Dashboard.SourceItems.xml` |

## Ce qu’un run laisse comme preuves
Priorité d’analyse : **TRX → XML/log de run → log MSTest → logs host → Workflow → AutoTest/Data**.

Les noms suivent généralement :
`Y2_Plugins_<Plugin>_<branche>_<version/label>...`

Exemples utiles présents sur PG2 :
- `*.trx` : résultat détaillé réel des tests.
- `*.mstest.log` : exécution MSTest.
- `*.xml`, `*.new.xml`, `*.inflated.xml` : journal/report du workflow.
- `report-*.log` : génération/publication du rapport.

## Fonctionnement à connaître
Le pipeline Azure `TestAutos` peut seulement **soumettre** un workflow asynchrone au launcher :
`http://<VM>:8181/integrationlauncher`.

Un ID de corrélation prouve la soumission, **pas le résultat final**. Pour connaître l’issue réelle, consulter les preuves sur la VM, surtout TRX/XML/logs.

Le moteur Legacy peut mettre à jour automatiquement les dossiers `override` (`git reset/checkout/pull`) avant un run : ne pas les modifier pendant une investigation.

## Comparaison Legacy ↔ JMeter
Ne conclure à une régression de migration que si les éléments sont suffisamment comparables :
`testcase/scénario`, `branche/version plugin`, `Current/Fix`, `données`, `environnement`, `requête/payload`, `assertion attendue`.

Classer les conclusions : **FACT / INFERENCE / UNKNOWN**.

## Précautions
- Investigation en lecture seule par défaut.
- Ne pas supprimer/modifier les rapports, TRX, logs, configs ou dossiers `override`.
- Les logs peuvent contenir chemins internes, comptes, mots de passe ou secrets : filtrer avant partage.
- Pour PowerShell d’investigation : écrire les résultats utiles dans `%TEMP%\*.txt` puis ouvrir automatiquement le TXT avec Notepad pour faciliter le copier-coller.
