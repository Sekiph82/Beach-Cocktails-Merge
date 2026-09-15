Cocktail Merge - Godot 4.7.x - Playable Prototype
===================================================

BU BUILD NE YAPIYOR?
--------------------
Bu proje, verilen ilk dosyalar temel alinarak oynanabilir hale getirildi.
Harici sprite/audio gerektirmez; icecekler simdilik renkli placeholder dairelerdir.

KURULUM
-------
1. Godot 4.7.x ac.
2. Import > bu klasordeki project.godot dosyasini sec.
3. Projeyi ac.
4. F6 yerine F5 (Run Project) kullanabilirsin. Ana sahne zaten scenes/main.tscn.
5. Desktop test penceresi 405x720 acilir; oyun mantigi sabit 720x1280 portre viewport kullanir ve pencereye olceklenir.

KONTROLLER
----------
Windows/macOS/Linux:
- Sol mouse tusuna bas.
- Fareyi saga/sola surukleyerek icecegin X konumunu ayarla.
- Mouse tusunu birakinca icecek yukari firlar.

Mobil:
- Dokun ve saga/sola surukle.
- Parmagini kaldirinca icecek yukari firlar.

OYUN AKISI
----------
- Yeni atislar sadece level 1-3 arasindan gelir.
- Ayni level iki icecek temas edince bir sonraki levele birlesir.
- 12 level zinciri data/drinks.json dosyasindan okunur.
- Level 12 + Level 12 artik yok olmaz; max level sabit kalir.
- Birlesmeler zincir halinde 0.8 sn icinde olursa skor carpani artar.
- Bir icecegin ust kenari kirmizi olum cizgisinin ustunde kesintisiz 1 sn kalirsa oyun biter.
- Rekor user://save.cfg dosyasina kaydedilir.
- Game Over ekraninda TEKRAR OYNA butonu vardir.

DUZELTILEN KRITIK SORUNLAR
---------------------------
1. Tum Drink nesneleri artik tek World node'u altinda; merge ve death-line taramasi ayni agaci gorur.
2. Drink.merged sinyali her spawn/merge sonrasinda MergeQueue'ya baglanir.
3. Merge islemleri physics contact callback'i icinde degil, deferred kuyrukta yapilir.
4. Level 12 + Level 12 silinme bug'i kaldirildi.
5. Mouse ve touch input birlikte desteklenir.
6. Atis hizi, gravity_scale=2 ile tum oyun alanina erisecek sekilde 2000 px/s yapildi.
7. Sabit oyun alani icin gereksiz Camera2D kaldirildi.
8. Score, Best, Next, Chain, Game Over ve Restart UI eklendi.
9. drinks.json okuma/level sinirlari icin hata kontrolleri eklendi.
10. README'deki Jolt 2D ifadesi kaldirildi. Bu proje RigidBody2D/GodotPhysics2D kullanir.

DOSYA YAPISI
------------
project.godot
scenes/
  main.tscn
scripts/
  game_manager.gd
  drink.gd
  merge_queue.gd
  shot_controller.gd
data/
  drinks.json

ILK TEST CHECKLIST
------------------
[ ] Proje import edilirken parse error yok.
[ ] F5 ile pencere aciliyor.
[ ] Mouse ile X konumu degisiyor ve birakinca firliyor.
[ ] Mobil touch ayni davranisi veriyor.
[ ] Ayni level icecekler birlesiyor.
[ ] Yeni birlesmis icecek tekrar birlesebiliyor.
[ ] Level 12'ler birbirine dokununca kaybolmuyor.
[ ] Skor ve zincir ekranda guncelleniyor.
[ ] Kirmizi cizginin ustunde 1 sn doluluk Game Over yapiyor.
[ ] Rekor kapanip acinca korunuyor.
[ ] Tekrar Oyna yeni oyun baslatiyor.

NOT
---
Bu surum oynanabilir gameplay prototipidir. Gercek kokteyl sprite'lari, sesler,
animasyonlar, ana menu ve mobil export ayarlari sonraki polish katmanidir.
