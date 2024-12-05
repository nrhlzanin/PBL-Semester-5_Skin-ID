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
                    {
                        "skintone_id": "1",
                        "skintone_name": "very_light",
                        "skintone_description": "Kulit yang sangat cerah dan lembut, sering kali terlihat seperti porselen dengan kadar melanin yang sangat rendah. Kulit kamu sangat sensitif terhadap sinar UV dan rentan terhadap eritema atau luka bakar akibat paparan sinar matahari. Perlindungan terhadap sinar matahari dengan SPF tinggi atau selalu memakai tabir surya setiap kali keluar rumah sangat dianjurkan ya.",
                        "hex_range_start": "#FFDFC4",
                        "hex_range_end": "#FFE3CB",
                    },
                    {
                        "skintone_id": "2",
                        "skintone_name": "light",
                        "skintone_description": "Kulit cerah yang memancarkan keindahan alami. Namun, kulit ini cukup sensitif terhadap sinar matahari karena kadar melanin rendah hingga sedang yang kulit kamu miliki. Kulit kamu cenderung mudah terbakar oleh sinar UV namun dapat mengembangkan tan ringan setelah paparan matahari yang berkepanjangan. Penggunaan perlindungan matahari rutin sangat disarankan untuk mencegah kerusakan kulitmu okeey.",
                        "hex_range_start": "#F0D5BE",
                        "hex_range_end": "#FFD7B5",
                    },
                    {
                        "skintone_id": "3",
                        "skintone_name": "medium",
                        "skintone_description": "Kulitmu memiliki rona yang hangat dan seimbang, memberikan kesan bercahaya alami. Kadar melanin yang kamu miliki relatif sedang dengan risiko terbakar matahari lebih rendah dibandingkan tipe kulit terang. Tetapi kulitmu tetap membutuhkan perlindungan terhadap sinar UV. Kulitmu bisa berubah menjadi cokelat dengan cantik saat terkena matahari, tapi tetap butuh perlindungan ekstra.",
                        "hex_range_start": "#D1A684",
                        "hex_range_end": "#E3AC90",
                    },
                    {
                        "skintone_id": "4",
                        "skintone_name": "olive",
                        "skintone_description": "Kulit eksotis yang terlihat bercahaya alami dengan warna zaitun yang khas. Kulitmu memiliki kandungan melanin yang lebih tinggi dibandingkan kulit medium. Kulit mu jarang terbakar matahari dan cenderung langsung mengembangkan tan gelap setelah paparan UV. Tapi perlindungan matahari tetap disarankan untuk mencegah penuaan dini dan kerusakan akibat sinar matahari dan agar selalu terlihat segar!",
                        "hex_range_start": "#A67C52",
                        "hex_range_end": "#B97D56",
                    },
                    {
                        "skintone_id": "5",
                        "skintone_name": "brown",
                        "skintone_description": "Kulit coklat yang kuat dan elegan dengan kadar melanin tinggi, jarang terbakar matahari, dan selalu terlihat memukau. Kulitmu  memiliki perlindungan alami yang baik terhadap sinar UV, jarang terbakar, dan dengan cepat mengembangkan tan. Namun, kerusakan kulit akibat sinar UV tetap dapat terjadi, terutama dalam bentuk hiperpigmentasi. Pastikan tetap menjaga hidrasi kulit untuk mempertahankan kilau alaminya.",
                        "hex_range_start": "#825C3A",
                        "hex_range_end": "#936B4F",
                    },
                    {
                        "skintone_id": "6",
                        "skintone_name": "dark",
                        "skintone_description": "Kulit gelap yang memukau dengan kilau sehat yang alami kulitmu memiliki kadar melanin yang sangat tinggi. Kulit ini hampir tidak pernah terbakar oleh sinar UV dan memiliki perlindungan alami yang signifikan. Namun, sinar matahari tetap dapat menyebabkan kerusakan kulit, termasuk risiko hiperpigmentasi dan kerusakan jangka panjang. Sehingga kulitmu tetap butuh perawatan dan pelembap agar selalu terlihat flawless.",
                        "hex_range_start": "#4A312C",
                        "hex_range_end": "#5D3A35",
                    },
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
            self.stdout.write(self.style.SUCCESS(f"Pengguna {pengguna['username']} berhasil ditambahkan"))
