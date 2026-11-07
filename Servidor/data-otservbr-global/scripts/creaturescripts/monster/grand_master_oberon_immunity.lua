local grandMasterOberonImmunity = CreatureEvent("OberonImmunity")

function grandMasterOberonImmunity.onHealthChange(
	creature,
	attacker,
	primaryDamage,
	primaryType,
	secondaryDamage,
	secondaryType,
	origin
)
	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

grandMasterOberonImmunity:register()