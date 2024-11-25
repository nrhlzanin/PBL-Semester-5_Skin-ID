from django.core.management.base import BaseCommand
from api.models import SkinTone, Pengguna
from django.utils.crypto import get_random_string
from django.contrib.auth.hashers import make_password

class Command(BaseCommand):
    help = 'Seeder untuk menambah data skintone dan pengguna'

    def handle(self, *args, **kwargs):
        skintones = [
            {"skintone_name": "very_light", "skintone_description": "Rentan terhadap sengatan matahari"},
            {"skintone_name": "light", "skintone_description": "Mudah terbakar panas matahari"},
            {"skintone_name": "medium", "skintone_description": "Cenderung menjadi cokelat secara bertahap"},
            {"skintone_name": "olive", "skintone_description": "Kulit cenderung mudah menjadi coklat"},
            {"skintone_name": "brown", "skintone_description": "Jarang terbakar panas matahari"},
            {"skintone_name": "dark", "skintone_description": "Tidak akan terbakar panas matahari"},
        ]
        for skintone in skintones:
            SkinTone.objects.get_or_create(
                skintone_name=skintone['skintone_name'],
                skintone_description=skintone['skintone_description']
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
