REM --- Installation de MSMQ pour Windows 8 & 8.1
dism /online /enable-feature /featurename:MSMQ-Container /featurename:MSMQ-Server /featurename:MSMQ-Triggers /featurename:MSMQ-ADIntegration /featurename:MSMQ-Multicast /ALL
