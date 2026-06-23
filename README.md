# 📻 Naxi Radio — macOS Menu Bar App

Nativna macOS aplikacija koja pušta **Naxi Radio 96.9 MHz** direktno iz menu bara. Muzika počinje automatski čim otvorite aplikaciju.

## Mogućnosti

- **Auto-play** — muzika počinje odmah pri pokretanju
- **Sada svira** — prikazuje pevača, pesmu i naziv emisije (osvežava se svakih 30 sekundi)
- **Play / Pause** sa slajderom za jačinu zvuka
- **Pokreni pri startu Maca** — opcija da se app automatski otvori pri paljenju računara
- **Menu bar** — živi u traci menija, ne zauzima Dock ni prostor na radnoj površini
- **O aplikaciji** — About prozor sa svim informacijama

## Zahtevi

- macOS 13 Ventura ili noviji
- Aktivan internet

## Instalacija

### Preuzimanje gotove aplikacije

**[⬇ Preuzmi NaxiRadio-1.0.dmg](https://github.com/DejanVukovar/naxi-radio-mac/releases/download/v1.0.0/NaxiRadio-1.0.dmg)**

1. Otvori preuzeti `NaxiRadio-1.0.dmg`
2. Prevuci `NaxiRadio.app` u `Applications` folder
3. **Desni klik → Open** (samo prvi put — macOS Gatekeeper zahteva ovo za nepotpisane aplikacije)
4. Aplikacija se pojavljuje u menu baru (ikona radio talasa)

### Buildovanje iz koda

Potrebno: macOS 13+, Xcode Command Line Tools (`xcode-select --install`)

```bash
git clone https://github.com/DejanVukovar/naxi-radio-mac.git
cd naxi-radio-mac
./build.sh
cp -r NaxiRadio.app /Applications/
open /Applications/NaxiRadio.app
```

## Stream

Aplikacija koristi zvanični Naxi Radio stream:
```
https://naxi128ssl.streaming.rs:9152/;stream.nsv
```

## Autor

**Dejan Njegić**  
Nezavisni macOS Developer

## Licenca

MIT License — slobodno koristite, menjajte i delite.
