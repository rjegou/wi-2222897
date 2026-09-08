# Contrat immédiat — définition 14264

À consommer comme preuve uniquement :

- API remote exact : run `4444962`, artefact `Nuget` `5037204`, commit
  `4c22cb2850a150161f44080815375527c4daad48`.
- Relecture indépendante : nupkg `B416C52F58D5129C36540C13E9C9BA36CCB064FE5433EE3D21C8094A9E3E5AC4`,
  DLL `38E7BA8D507FB73A661DD111224DCFABBF78C22AB2ECE23BD9D2EF67ACCD2F3`, nuspec `1.1.46`.
- Ne pas injecter cet artefact dans le candidat Console : il n'est pas `1.1.47-wi2222897-api-candidate`.
- Le candidat Console `803DDBAAEB545A901ACD500195F5372F1E42F2FBD5FC1AC88626830F14EEE55B` et le
  cache Migration `212D33F7BE8DE8AC5923E82AC7BE0A0CEECBA5A71B631337B729F37CC889BE03` restent
  locaux, avec respectivement API embarquée `57BE…` et nuspec `2.0.39`.

Postcondition manquante avant Cur/Fix : un artefact PipelineArtifact Console exact et un artefact/cache
Migration explicitement versionné, chacun téléchargé puis rehashé. Aucun lancement JMeter ne doit
être considéré comme preuve tant que ces deux entrées ne sont pas satisfaites.
