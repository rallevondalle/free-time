# Free Time – spørgsmål og svar

[English version](FAQ.md)

Kontakt: **freetime@rassta.dk**

## Hvad er Free Time?

Free Time er det modsatte af en app, der vil have din opmærksomhed. Den giver
dig point for den tid, din telefon ligger uberørt. Jo mere "væk" telefonen er,
jo flere point. Og du kan konkurrere med venner om, hvem der lægger den mest.

## Hvorfor findes den?

Fordi telefonen er blevet en gæst, der aldrig går hjem. Den ligger på bordet til
middagen, den er med i sengen, den afbryder samtaler, og den tager de små
pauser, hvor tankerne ellers ville vandre.

Free Time er et forsøg på at vende det om: at gøre tilstedeværelse til det, der
belønnes, og gøre skærmen lidt mindre invaderende i hverdagen. Ikke med forbud,
men med et lille, venligt regnskab.

## Hvordan tæller den?

**Android:** en lille tæller kører i baggrunden hele tiden. Når skærmen låses
eller slukkes, starter en session. Når du låser op, slutter den. Det kræver
ingen tryk.

**iPhone:** Apple tillader ikke den slags baggrundsmåling. Der trykker du "Læg
telefonen fra dig", når du lægger den, og "Stop", når du tager den igen. Appen
tjekker bagefter, om telefonen faktisk lå stille, og om den blev brugt imens.

## Hvordan fordeles pointene?

Du får 1 point pr. minut, telefonen ligger. Det ganges med en faktor for, hvor
"væk" den er:

| Tilstand              | Faktor      |
|-----------------------|-------------|
| Lyd på                | 1×          |
| Vibrer                | 1,5×        |
| Lydløs                | 2×          |
| Forstyr ikke / Fokus  | 2,5×        |
| Flytilstand, wifi tændt | 3×        |
| Flytilstand, bluetooth tændt | 4×   |
| Flytilstand, alt slukket | 5×       |
| Slukket               | 10×         |
| Genstart              | +50 point   |
| Skærm tændt, men låst | ×0,5        |
| I lommen / i bevægelse| ×0,5        |

Faktorerne ganges sammen, så lydløs i lommen giver 2 × 0,5 = 1×.

Eksempler: en time lydløs på bordet giver 120 point. En time i flytilstand med
alt slukket giver 300. En nat slukket giver omkring 4.800.

## Hvad er dagsmålet?

Dagsmålet er dit eget. Standard er 600 point, hvilket svarer til fem timer
lydløs eller to timer i flytilstand. Du kan ændre det under "Mere" i
appen. Målet påvirker kun ringen på forsiden, ikke stillingen blandt venner.

## Kan man snyde?

Ja, hvis man vil. Man kan lægge telefonen hjemme og gå på arbejde. Men så har
man jo faktisk været uden telefon, og det er hele pointen.

Appen bruger telefonens sensorer til at se, om den lå stille, og om skærmen blev
brugt, og giver færre point, når den ikke kan bekræfte det. Men det er en app
mellem venner, ikke en domstol.

## Hvorfor er iPhone anderledes end Android?

Apple lader ikke apps læse lydløs-knappen, flytilstand eller om telefonen er
låst, og apps må ikke køre i baggrunden i timevis. Derfor starter og stopper du
sessioner selv på iPhone og fortæller selv, om den var på lydløs eller i
flytilstand. Android giver adgang til det hele, så der måles det automatisk.

## Hvilke data gemmer appen?

Kun det, der skal til: hvornår en session startede og sluttede, hvilken
tilstand telefonen var i (lyd, lydløs, fly, slukket), om den lå stille, og om
skærmen var tændt.

Appen ser ikke, hvilke apps du bruger, hvem du skriver med, eller hvor du er.
Dine venner kan se dine ugepoint og din samlede tid uden telefon, ikke de
enkelte sessioner.

## Hvorfor beder appen om tilladelser?

**Android:** "Kør i baggrunden" så tælleren ikke bliver slået ihjel af
batterioptimering, og "Notifikationer" fordi Android kræver en synlig
notifikation for baggrundstjenester.

**iPhone:** begge er valgfri. «Fokus» for at give bonus for Forstyr ikke, og
«Skærmtid» for at verificere, at telefonen ikke blev brugt under en session. Alt
aflæses på telefonen og deles aldrig; skift mening under Mere → Tilladelser.

## Bruger den meget batteri?

Nej. Tælleren lytter kun efter systemhændelser (skærm, lydprofil, flytilstand)
og bruger telefonens lavstrøms-bevægelsessensor. Den måler ikke løbende.

## Hvad er planen fremad?

Grupper og udfordringer ("ingen skærm før kl. 9"), streaks, en widget til
hjemmeskærmen, og en web-version af stillingen. Forslag er velkomne.

## Hvem står bag?

Free Time er et lille, uafhængigt projekt uden reklamer og uden salg af data.
Skriv til **freetime@rassta.dk** med spørgsmål, fejl eller idéer.
