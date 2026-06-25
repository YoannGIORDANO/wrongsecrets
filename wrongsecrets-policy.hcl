# Policy : acces en LECTURE SEULE au secret de l'application WrongSecrets
# Principe du moindre privilege : l'application ne peut que LIRE son secret,
# elle ne peut ni le modifier, ni le supprimer, ni acceder aux autres secrets.

path "secret/data/wrongsecrets" {
  capabilities = ["read"]
}

path "secret/metadata/wrongsecrets" {
  capabilities = ["read", "list"]
}
