# Extraits expurgés — build 4444389

Source REST : timeline du build et logs ciblés, collectés le 2026-09-08. Horodatages UTC.

| Log | Observation directe |
|---:|---|
| 129 | `08:50:29` Initialize containers; `docker version` échoue à trois reprises sur `npipe:////./pipe/docker_engine`; `08:51:02` exit code 1. |
| 129 | `08:51:02–04` erreurs dérivées `Value cannot be null (ContainerId)` et archive/log paths absents; `TI Jmeter V26-Fix` termine failed. |
| 178 | `08:50:28` Initialize containers; Docker API/client `1.55`; login et pull réussissent; `09:00:56` network create; `09:00:57` create; `09:01:02` container started successfully. |
| 178 | `09:01:37` checkout; `09:01:44.439` `The Operation will be canceled`; campagne Cur et publications deviennent skipped; `09:01:46–48` stop/remove container et network réussissent. |
| 102/103 | `ContainerId` nul et chemins de zip absents dans les suites de cleanup/publication du job Fix. |

La présence de messages d'annulation après l'échec Fix ne prouve pas la cause de l'annulation
globale; aucune ligne de timeline/log ciblée ne l'explicite.
