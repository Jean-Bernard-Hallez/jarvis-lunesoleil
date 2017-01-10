#!/bin/bash
# Here you can create functions which will be available from the commands file
# You can also use here user variables defined in your config file
# - Enregistrer variable radio pour l'ouvrir si le nom n'est pas prononcé
# - Allume radio sans rien derrière... ouvre GOTO pour quelle radio ? la dernière
# - je tappe 3 fois dans les mains pour arrêter la radio... là dans Led clignotante mettre mpd stop

jv_pg_ct_lune () {
varlunesoleil="$jv_dir/plugins/jarvis-lunesoleil/phaselune.txt"
varlunesoleilannee=`$(echo date "+%Y")`
varlunesoleilanneep=$(($varlunesoleilannee+1))
varlunesoleilmois=`$(echo date "+%B")`
jv_pg_ct_lunerechernet
jv_pg_ct_soleiltest
local ligne=$(sed -n "/$varlunesoleilmois/=" $varlunesoleil)
local ligne1=$(sed -n "$ligne p;" $varlunesoleil | sed -e "s/\(.*\) .*/\1/" | sed  -e "s/>/\ /g")
Prochainepleinelune=`echo $ligne1 | cut -d ' ' -f4-5`
local varlunesoleiljour=`echo $ligne1 | cut -d ' ' -f4`
local datejourlune=`$(echo date "+%d")`
testdatejourlune=$(($varlunesoleiljour-$datejourlune))
if [ "$testdatejourlune" -gt "0" ]; then
say "La prochaine pleine lune aura lieu le $Prochainepleinelune soit dans $testdatejourlune jour. Actuellement la lune est visible à $lune pourcent."
fi 
if [ "$testdatejourlune" -eq "0" ]; then
say "C'est aujourd'hui la pleine lune."
fi
if [ "$testdatejourlune" -lt "0" ]; then
say "La prochaine pleine est passé le $Prochainepleinelune soit il y a $testdatejourlune jour. Actuellement la lune est visible à $lune pourcent."
fi
}

jv_pg_ct_lunerechernet () {
if [ -f "$varlunesoleil" ]; then
# fichier existe
local c="ok"
else
echo "Téléchargement des phases de la lune pour l'année...$varlunesoleilannee"

wget -q http://www.calendrier-365.fr/lune/phases-de-la-lune.html  -O $varlunesoleil
local chaine1="Premier quartier.*$varlunesoleilanneep</b></td><td><b>" 
local chaine=$(grep -o "$chaine1" $varlunesoleil)
echo $chaine > $varlunesoleil
sed -i -e "s/<tr>/ /g" $varlunesoleil
sed -i -e "s/<\/tr>/ /g" $varlunesoleil
sed -i -e "s/<td>/ /g" $varlunesoleil
sed -i -e "s/<\/td>/ /g" $varlunesoleil
sed -i -e "s/<h1>/ /g" $varlunesoleil
sed -i -e "s/<\/h1>/ /g" $varlunesoleil
sed -i -e "s/<p>/ /g" $varlunesoleil
sed -i -e "s/<\/p>/ /g" $varlunesoleil
sed -i -e "s/<a>/ /g" $varlunesoleil
sed -i -e "s/<\/a>/ /g" $varlunesoleil
sed -i -e "s/<b>/ /g" $varlunesoleil
sed -i -e "s/<\/b>/ /g" $varlunesoleil
sed -i -e "s/<td data-/ /g" $varlunesoleil
sed -i -e "s/<\/tbody.*/ /g" $varlunesoleil
sed -i -e 's/<td class="mo">/ /g' $varlunesoleil
sed -i -e "s/<value=.*>/ /g" $varlunesoleil
sed -i -e 's/<td class="mo" data-/ /g' $varlunesoleil
sed -i -e 's/value=/ /g' $varlunesoleil
sed -i -e "s+     +\n+g" $varlunesoleil
sed -i -e "s/\(.*\)$varlunesoleilannee.*/\1/$varlunesoleilannee" $varlunesoleil
sed -i -n -e '/Pleine lune/p' $varlunesoleil
fi
}

jv_pg_ct_soleil () {
jv_pg_ct_soleiltest
say "Le soleil se lèvera à $leverH heure $leverM et il se couchera à $coucherH heure $coucherM."
}


jv_pg_ct_soleiltest () {
atrier=`echo "$(curl -s "http://api.wunderground.com/api/$weather_wunderground_key/forecast/lang:$weather_wunderground_language/astronomy/q/$weather_wunderground_city.json")"`
leverH=`echo "$atrier" | jq -r '.sun_phase.sunrise.hour' | sed "s/ºC/degrés/g"`
leverM=`echo "$atrier" | jq -r '.sun_phase.sunrise.minute'` 
coucherH=`echo "$atrier" | jq -r '.sun_phase.sunset.hour'`
coucherM=`echo "$atrier" | jq -r '.sun_phase.sunset.minute'`
lune=`echo "$atrier" |jq -r '.moon_phase.percentIlluminated'`

}