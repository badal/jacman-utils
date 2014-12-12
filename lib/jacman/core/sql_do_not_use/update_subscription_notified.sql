-- mise a jour de l'état de notification d'un abonnement après sa notification

-- attention SQL avec un jeton

UPDATE
  abonnement
SET
  abonnement_ip_a_notifier             = 0,
  abonnement_ip_notification_timestamp = '::time_stamp::'
WHERE
  abonnement_id = ::abonnement_id::;
