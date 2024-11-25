from django.db import migrations

def add_default_skintones(apps, schema_editor):
    SkinTone = apps.get_model('api', 'SkinTone')
    skintones = [
        {"skintone_name": "very_light", "skintone_description": "Rentan terhadap sengatan matahari"},
        {"skintone_name": "ligt", "skintone_description": "Mudah terbakar panas matahari"},
        {"skintone_name": "medium", "skintone_description": "Cenderung menjadi cokelat secara bertahap"},
        {"skintone_name": "olive", "skintone_description": "Kulit cenderung mudah menjadi coklat"},
        {"skintone_name": "brown", "skintone_description": "Jarang terbakar panas matahari"},
        {"skintone_name": "dark", "skintone_description": "Tidak akan terbakar panas matahari"},
    ]
    for skintone in skintones:
        SkinTone.objects.create(**skintone)

class Migration(migrations.Migration):

    dependencies = [
        ('api', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(add_default_skintones),
    ]
