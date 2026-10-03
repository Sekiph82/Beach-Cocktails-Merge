from __future__ import annotations
import hashlib, json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[6]
OUTER = HERE / 'all_island_surfaces'
SRC = OUTER / 'source_941x1672'
PREVIEW = OUTER / 'review_720x1280'
PREVIEW.mkdir(parents=True, exist_ok=True)
ITEMS = [
 ('sunny_cove','Sunny Cove'),('tiki_island','Tiki Island'),('azure_bay','Azure Bay'),('coconut_beach','Coconut Beach'),
 ('sunset_island','Sunset Island'),('party_beach','Party Beach'),('frozen_paradise','Frozen Paradise'),('volcano_bay','Volcano Bay'),
 ('billionaire_island','Billionaire Island'),('final_island','Final Island')]

def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main() -> None:
    variants=[]
    thumbs=[]
    for slug,label in ITEMS:
        source=SRC/f'{slug}_941x1672.png'
        im=Image.open(source).convert('RGB')
        if im.size != (941,1672):
            raise ValueError(f'{source} must be 941x1672; got {im.size}')
        out=im.resize((720,1280),Image.Resampling.LANCZOS)
        target=PREVIEW/f'{slug}_720x1280.png'
        out.save(target,'PNG',optimize=True)
        variants.append({'island':label,'source_file':source.relative_to(HERE).as_posix(),'source_sha256':sha(source),'source_dimensions_px':list(im.size),'review_file':target.relative_to(HERE).as_posix(),'review_sha256':sha(target),'review_dimensions_px':list(out.size)})
        thumbs.append((label,out.resize((180,320),Image.Resampling.LANCZOS)))
    sheet=Image.new('RGB',(950,700),(22,30,38)); draw=ImageDraw.Draw(sheet)
    try: font=ImageFont.truetype(r'C:\Windows\Fonts\arial.ttf',13)
    except OSError: font=ImageFont.load_default()
    for i,(label,thumb) in enumerate(thumbs):
        x=(i%5)*190+5; y=(i//5)*350+4
        sheet.paste(thumb,(x,y+20)); draw.text((x,y+2),label,fill=(250,245,230),font=font)
    contact=HERE/'all_islands_contact_sheet_v07_r04_r02.png'; sheet.save(contact,'PNG',optimize=True)
    ref=SRC/'sunny_cove_941x1672.png'
    canonical=HERE/'sunny_cove_master_surface_source_v07_r04_r02.png'
    metadata={
      'task':'BCM-M21-001 + BCM-M21-006 owner-requested all-island format extension',
      'format_reference':'all_island_surfaces/source_941x1672/sunny_cove_941x1672.png',
      'format_reference_sha256':sha(ref),'approved_source_sha256':sha(canonical),
      'source_resolution_px':[941,1672],'review_resolution_px':[720,1280],
      'variants':variants,'contact_sheet_file':contact.name,
      'common_visual_rules':{
        'same_portrait_close_player_facing_table_composition':True,
        'longitudinal_planks':True,
        'only_island_background_and_wood_material_or_pattern_vary':True,
        'ui_or_cocktails_included':False,'deadline_included':False,
        'vertical_guide_or_trajectory_included':False,
        'production_geometry_or_runtime_binding_changed':False,
        'production_asset_status':'visual review candidate only; not V2-fitted or promoted'
      }
    }
    manifest=HERE/'all_islands_manifest_v07_r04_r02.json'; manifest.write_text(json.dumps(metadata,indent=2)+'\n',encoding='utf-8')
    if metadata['format_reference_sha256'] != metadata['approved_source_sha256']:
        raise ValueError('Sunny Cove reference no longer byte-matches the owner-approved source')
    print(f'variants={len(variants)} source={ref.size if False else Image.open(ref).size}')
    print(f'previews={len(list(PREVIEW.glob("*_720x1280.png")))} contact={contact}')
    print(f'manifest={manifest} owner_reference_byte_match=true')

if __name__ == '__main__': main()
