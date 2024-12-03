# Generated by Django 5.1.3 on 2024-12-02 14:50

import django.core.validators
import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
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
            name='Product',
            fields=[
                ('product_id', models.AutoField(primary_key=True, serialize=False)),
                ('product_name', models.CharField(max_length=100)),
                ('brand', models.CharField(blank=True, max_length=255, null=True)),
                ('product_type', models.CharField(blank=True, max_length=255, null=True)),
                ('description', models.TextField(blank=True, null=True)),
                ('image_url', models.URLField(blank=True, max_length=1000, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
            ],
            options={
                'db_table': 'Product',
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
            name='ProductColor',
            fields=[
                ('color_id', models.AutoField(primary_key=True, serialize=False)),
                ('hex_value', models.CharField(max_length=7)),
                ('color_name', models.CharField(blank=True, max_length=255, null=True)),
                ('product', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='colors', to='api.product')),
            ],
            options={
                'db_table': 'ProductColor',
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
                ('profile_picture', models.ImageField(blank=True, null=True, upload_to='profile_pictures/')),
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
        migrations.CreateModel(
            name='Recommendation',
            fields=[
                ('recommendation_id', models.AutoField(primary_key=True, serialize=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('color', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='makeup_recommendations', to='api.productcolor')),
                ('product', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='makeup_recommendations', to='api.product')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='makeup_recommendations', to='api.pengguna')),
                ('skintone', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='makeup_recommendations', to='api.skintone')),
            ],
            options={
                'db_table': 'Recommendation',
            },
        ),
    ]
