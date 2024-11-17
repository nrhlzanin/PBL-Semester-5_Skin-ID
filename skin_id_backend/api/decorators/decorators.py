from django.http import JsonResponse
from functools import wraps

def admin_only(view_func):
    @wraps(view_func)
    def _wrapped_view(request, *args, **kwargs):
        if not request.user.is_authenticated:
            return JsonResponse({'error': 'User not authenticated'}, status=401)

        # Hanya admin yang bisa mengakses
        if request.user.pengguna.role_id.role_name != 'admin':
            return JsonResponse({'error': 'Access forbidden: Admins only'}, status=403)
        
        return view_func(request, *args, **kwargs)
    return _wrapped_view

def user_only(view_func):
    def _wrapped_view(request, *args, **kwargs):
        if not request.user.is_authenticated or request.user.role_id.role_name != 'pengguna':
            return JsonResponse({'error': 'User access only'}, status=403)
        return view_func(request, *args, **kwargs)
    return _wrapped_view

def user_or_admin(view_func):
    @wraps(view_func)
    def _wrapped_view(request, *args, **kwargs):
        if not request.user.is_authenticated:
            return JsonResponse({'error': 'User not authenticated'}, status=401)

        # Pengguna atau admin bisa mengakses
        role = request.user.pengguna.role_id.role_name
        if role not in ['pengguna', 'admin']:
            return JsonResponse({'error': 'Access forbidden: Users or Admins only'}, status=403)

        return view_func(request, *args, **kwargs)
    return _wrapped_view