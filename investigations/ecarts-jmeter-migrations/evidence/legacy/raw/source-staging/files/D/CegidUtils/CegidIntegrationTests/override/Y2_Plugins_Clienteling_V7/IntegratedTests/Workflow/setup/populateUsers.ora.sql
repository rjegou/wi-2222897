UPDATE utilisat SET us_abrege='${string::to-upper(environment::get-user-name())}', us_password='' WHERE us_utilisateur='TST';

COMMIT WORK;

EXIT;