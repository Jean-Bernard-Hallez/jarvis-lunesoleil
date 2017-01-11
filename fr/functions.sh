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
say "La prochaine pleine est passé le $Prochainepleinelune soit il y a $testdatejourlune jour. Actuellement la lune est visible à $lune pourcents."
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

jv_pg_ct_histoiredelune () {
histoiredelunetrouve=`(echo "$bhistoirenum" | grep ".*sommeil")` && ecoutehistoire="1"
histoiredelunetrouve=`(echo "$bhistoirenum" | grep ".*ongle")` && ecoutehistoire="2"
histoiredelunetrouve=`(echo "$bhistoirenum" | grep ".*cheveux")` && ecoutehistoire="2"
histoiredelunetrouve=`(echo "$bhistoirenum" | grep ".*linge")` && ecoutehistoire="3"
histoiredelunetrouve=`(echo "$bhistoirenum" | grep ".*irritabilité")` && ecoutehistoire="4"
histoiredelunetrouve=`(echo "$bhistoirenum" | grep ".*accouchement")` && ecoutehistoire="5"
histoiredelunetrouve=`(echo "$bhistoirenum" | grep ".*libido")` && ecoutehistoire="6"
histoiredelunetrouve=`(echo "$bhistoirenum" | grep ".*animaux")` && ecoutehistoire="7"
histoiredelunetrouve=`(echo "$bhistoirenum" | grep ".*hazard")` && ecoutehistoire=$((1 + RANDOM%(7-1+1)))

citations=(" " "C'est ce que semble montrer une étude réalisée par des chercheurs suisses. Le cycle lunaire semble vraiment affecter le sommeil humain."
"Vos ongles et vos cheveux pousseraient plus vite. Pendant la période de lune montante, jusqu'à la pleine lune, la taille des vaisseaux capillaires augmenteraient légèrement."
"Les lingères d’antan avaient aussi pour habitude d’étendre leurs draps sur l’herbe à la pleine lune pour les rendre plus blancs que blancs."
"Les gens se sentent de plus en plus nerveux à cause de la pression qui accroît dans leur tête, la Lune affecte les marées terrestres et les gens aussi qui sont majoritairement composés d'eau."
"Les accouchements seraient plus nombreux que la moyenne. On dit également que le nombre de fausses-couches, césariennes, naissance de jumeaux et même de malformations croîtrait ces nuits-là."
"Elle influencerait grandement votre libido par le rayonnement électromagnétique qui augmente la production d’hormones dans le corps, notamment la testostérone, et donc le désir sexuel."
"Le cycle lunaire joue sur les marées et influencerait le comportement de certains animaux,  dont les chats, les chiens, les poissons et les oiseaux.")
# "----------------longueur max d'un texte prononcé par Jarvis-------------------------------------------------------------------------------------------------------------------------------------------"
say "${citations[$ecoutehistoire]}"

}

jv_pg_ct_verihistoiredelune () {
bhistoirenum=""
themehistoirelune=""
bhistoirenum=`echo "$order"| sed 's/.*lune//'`
if [[ "$bhistoirenum" == "" ]]; then 
themehistoirelune="Ennoncez le thème qui vous plairait: le sommeil, les ongles, les cheveux, le linge, l'iritabilité, la libido, les animaux, au hazard"
else
jv_pg_ct_histoiredelune
fi
}

