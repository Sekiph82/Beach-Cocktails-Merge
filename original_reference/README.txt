Cocktail Merge - Godot 4.7.2
===========================

KURULUM:
1. Godot 4.7.2'yi ac, "Import" -> bu klasordeki project.godot'u sec.
2. F6 ile main.tscn sahnesini calistir (mobil test: Project > Project Settings
   > Display > Window > Size ayarlari 720x1280 portre, hazir).

4.7.2'YE OZEL NOTLAR:
- Fizik motoru: Jolt (4.6'dan beri varsayilan). PhysicsMaterial'deki bounce
  biraz daha canlidir; 0.35 degerleri ayarlanmis durumda.
- can_sleep = true ile 50+ nesne masada uyurken CPU neredeyse sifir.
- Rekor kaydi user://save.cfg (ConfigFile API).

DOSYALAR:
  scenes/main.tscn        - ana sahne (GameManager + Camera2D)
  scripts/game_manager.gd - skor, zincir carpani, olum cizgisi, duvarlar
  scripts/drink.gd        - kokteyl rigidbody (12 seviyeli zincir, JSON'dan)
  scripts/merge_queue.gd  - birlesme kuyrugu (fizik callback kilidi korumasi)
  scripts/shot_controller.gd - atis kontrolu (Model B hazir, Model A icin
                              _fire_model_a fonksiyonu iceride)
  data/drinks.json        - 12 seviyelik kokteyl zinciri

TEST SIRASI:
1. Bardaklar dusuyor, duvarlarda kaliyor mu?
2. Ayni seviye carpisinca frame sonunda birlesiyor mu?
3. Cizginin ustunde 1 sn kalinca oyun bitiyor mu?
4. 3'lu zincirde carpan artiyor mu?
