from django.core.management.base import BaseCommand
from api.models import SkinTone, Pengguna, Role
from django.utils.crypto import get_random_string
from django.contrib.auth.hashers import make_password

class Command(BaseCommand):
    help = 'Seeder untuk menambah data skintone dan pengguna'

    def handle(self, *args, **kwargs):
        role_data = [
            {'role_id':'1','role_name':'pengguna'},
            {'role_id':'2','role_name':'admin'},
        ]
        for role in role_data:
            Role.objects.update_or_create(
                role_id=role['role_id'],
                role_name=role['role_name'],
            )
        self.stdout.write(self.style.SUCCESS("Role berhasil ditambahkan"))
        
        skintones = [
            {"skintone_id":"1","skintone_name": "very_light", "skintone_description": "Rentan terhadap sengatan matahari","hex_range_start":"#FFDFC4","hex_range_end":"#FFE3CB"},
            {"skintone_id":"2","skintone_name": "light", "skintone_description": "Mudah terbakar panas matahari","hex_range_start":"#F0D5BE","hex_range_end":"#FFD7B5"},
            {"skintone_id":"3","skintone_name": "medium", "skintone_description": "Cenderung menjadi cokelat secara bertahap","hex_range_start":"#D1A684","hex_range_end":"#E3AC90"},
            {"skintone_id":"4","skintone_name": "olive", "skintone_description": "Kulit cenderung mudah menjadi coklat","hex_range_start":"#A67C52","hex_range_end":"#B97D56"},
            {"skintone_id":"5","skintone_name": "brown", "skintone_description": "Jarang terbakar panas matahari","hex_range_start":"#825C3A","hex_range_end":"#936B4F"},
            {"skintone_id":"6","skintone_name": "dark", "skintone_description": "Tidak akan terbakar panas matahari","hex_range_start":"#4A312C","hex_range_end":"#5D3A35"},
        ]
        for skintone in skintones:
            SkinTone.objects.update_or_create(
                skintone_name=skintone['skintone_name'],
                skintone_description=skintone['skintone_description'],
                hex_range_start=skintone['hex_range_start'],
                hex_range_end=skintone['hex_range_end'],
            )
        self.stdout.write(self.style.SUCCESS("Skintones berhasil ditambahkan"))

        pengguna_data = [
            {'username': 'user','email': 'user@example.com','password': '123456', 'jenis_kelamin': 'pria', 'role_id':'1','skintone_id':'3',},
            {'username': 'user2','email': 'user2@mail.com','password': '123456', 'jenis_kelamin': 'pria', 'role_id':'1','skintone_id':'2',},
            {'username': 'user3','email': 'user3@gmail.com','password': '123456', 'jenis_kelamin': '', 'role_id':'1','skintone_id':'',},
        ]
        
        for pengguna in pengguna_data:
            pengguna['password'] = make_password(pengguna['password'])
            Pengguna.objects.create(
                username=pengguna['username'],
                email=pengguna['email'],
                password=pengguna['password'],
                jenis_kelamin=pengguna['jenis_kelamin'],
                skintone_id=pengguna['skintone_id'],
                role_id=pengguna['role_id']
            )
            self.stdout.write(self.style.SUCCESS(f"Pengguna {pengguna.username} berhasil ditambahkan"))
