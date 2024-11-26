<<<<<<< HEAD
# Generated by Django 5.1.3 on 2024-11-25 02:03
=======
# Generated by Django 5.1.3 on 2024-11-24 22:45
>>>>>>> e2acc31009f302e9ad4096d45a3fdc52d6fc3e03

import django.core.validators
import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Brand',
            fields=[
                ('brand_id', models.AutoField(primary_key=True, serialize=False)),
                ('brand_name', models.CharField(max_length=50)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
            options={
                'db_table': 'Brand',
            },
        ),
        migrations.CreateModel(
            name='Category',
            fields=[
                ('category_id', models.AutoField(primary_key=True, serialize=False)),
                ('category_name', models.CharField(max_length=50)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
            options={
                'db_table': 'Category',
            },
        ),
        migrations.CreateModel(
            name='Role',
            fields=[
                ('role_id', models.AutoField(primary_key=True, serialize=False)),
                ('role_name', models.CharField(choices=[('pengguna', 'Pengguna'), ('admin', 'Admin')], max_length=20)),
            ],
            options={
                'db_table': 'Role',
            },
        ),
        migrations.CreateModel(
            name='SkinTone',
            fields=[
                ('skintone_id', models.AutoField(primary_key=True, serialize=False)),
                ('skintone_name', models.CharField(blank=True, max_length=20, null=True)),
                ('skintone_description', models.CharField(blank=True, max_length=255, null=True)),
                ('hex_range_start', models.CharField(blank=True, max_length=7, null=True)),
                ('hex_range_end', models.CharField(blank=True, max_length=7, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
            options={
                'db_table': 'SkinTone',
            },
        ),
        migrations.CreateModel(
            name='BrandCategory',
            fields=[
                ('brand_category_id', models.AutoField(primary_key=True, serialize=False)),
                ('brand', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='categories', to='api.brand')),
                ('category', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='brands', to='api.category')),
            ],
            options={
                'db_table': 'BrandCategory',
            },
        ),
        migrations.CreateModel(
            name='Product',
            fields=[
                ('product_id', models.AutoField(primary_key=True, serialize=False)),
                ('product_name', models.CharField(max_length=100)),
                ('description', models.TextField(blank=True, null=True)),
                ('price', models.DecimalField(decimal_places=2, max_digits=10)),
                ('image_url', models.URLField(blank=True, max_length=255, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('brand_category', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='products', to='api.brandcategory')),
            ],
            options={
                'db_table': 'Product',
            },
        ),
        migrations.CreateModel(
            name='Recommendation',
            fields=[
                ('recommendation_id', models.AutoField(primary_key=True, serialize=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('product', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='recommendations', to='api.product')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='recommendations', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'db_table': 'Recommendation',
            },
        ),
        migrations.CreateModel(
            name='Pengguna',
            fields=[
                ('user_id', models.AutoField(primary_key=True, serialize=False)),
                ('username', models.CharField(max_length=50, unique=True)),
                ('password', models.CharField(max_length=255, validators=[django.core.validators.MinLengthValidator(6)])),
                ('email', models.EmailField(max_length=100, unique=True)),
                ('jenis_kelamin', models.CharField(blank=True, choices=[('pria', 'pria'), ('wanita', 'wanita')], max_length=100, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('last_login', models.DateTimeField(blank=True, null=True)),
                ('is_active', models.BooleanField(default=True)),
                ('token', models.CharField(blank=True, max_length=255, null=True)),
                ('role', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='pengguna', to='api.role')),
                ('skintone', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='pengguna', to='api.skintone')),
            ],
            options={
                'db_table': 'Pengguna',
            },
        ),
    ]
