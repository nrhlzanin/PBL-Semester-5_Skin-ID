from django.core.management.base import BaseCommand
from api.models import SkinTone, Pengguna
from django.utils.crypto import get_random_string
from django.contrib.auth.hashers import make_password

class Command(BaseCommand):
    help = 'Seeder untuk menambah data skintone dan pengguna'

    def handle(self, *args, **kwargs):
        skintones = [
            {"skintone_id":"1","skintone_name": "very_light", "skintone_description": "Rentan terhadap sengatan matahari","hex_range_start":"#FFDFC4","hex_range_end":"#FFE3CB"},
            {"skintone_id":"2","skintone_name": "light", "skintone_description": "Mudah terbakar panas matahari","hex_range_start":"#F0D5BE","hex_range_end":"#FFD7B5"},
            {"skintone_id":"3","skintone_name": "medium", "skintone_description": "Cenderung menjadi cokelat secara bertahap","hex_range_start":"#D1A684","hex_range_end":"#E3AC90"},
            {"skintone_id":"4","skintone_name": "olive", "skintone_description": "Kulit cenderung mudah menjadi coklat","hex_range_start":"#A67C52","hex_range_end":"#B97D56"},
            {"skintone_id":"5","skintone_name": "brown", "skintone_description": "Jarang terbakar panas matahari","hex_range_start":"825C3A","hex_range_end":"#936B4F"},
            {"skintone_id":"6","skintone_name": "dark", "skintone_description": "Tidak akan terbakar panas matahari","hex_range_start":"#4A312C","hex_range_end":"5D3A35"},
        ]
        for skintone in skintones:
            SkinTone.objects.update_or_create(
                skintone_name=skintone['skintone_name'],
                skintone_description=skintone['skintone_description'],
                hex_range_start=skintone['hex_range_start'],
                hex_range_end=skintone['hex_range_end'],
            )
        self.stdout.write(self.style.SUCCESS("Skintones berhasil ditambahkan"))

        # Menambahkan data pengguna (contoh: admin atau pengguna pertama)
        pengguna_data = {
            'username': 'adminuser',
            'email': 'admin@example.com',
            'password': 'admin1234',  # Pastikan untuk hash password sebelum digunakan
            'jenis_kelamin': 'pria',  # Contoh jenis kelamin
        }
        pengguna_data['password'] = make_password(pengguna_data['password'])
        skintone_instance = SkinTone.objects.first()  # Mengambil skintone pertama sebagai contoh

        pengguna = Pengguna.objects.create(
            username=pengguna_data['username'],
            email=pengguna_data['email'],
            password=pengguna_data['password'],
            jenis_kelamin=pengguna_data['jenis_kelamin'],
            skintone=skintone_instance
        )
        self.stdout.write(self.style.SUCCESS(f"Pengguna {pengguna.username} berhasil ditambahkan"))
