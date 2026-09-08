# File: deploy-pipeline-helper.ps1
# Module ton includein the pipeline powersell script
# to allow usage of modules used by tools for example retreive informations from the deployment configuration file

#Requires -Version 7.6

using module "..\Modules\CdmHelper.psm1"
using module "..\Modules\deployCfg.psm1"
using module "..\Modules\DevUtils.psm1"
using module "..\Modules\DockerUtils.psm1"
using module "..\Modules\logger.psm1"
using module "..\Modules\PipelineHelper.psm1"
using module "..\Modules\Roles.psm1"
using module "..\Modules\Utils.psm1"
