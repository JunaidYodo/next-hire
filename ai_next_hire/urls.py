"""
URL configuration for ai_next_hire project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from django.http import JsonResponse
import os

# def health_check(request):
#     return JsonResponse({"status": "healthy", "message": "Service is running"})

def health_check(request):
    if os.getenv('FORCE_HEALTH_FAIL', 'false').lower() == 'true':
        return JsonResponse({
            'status': 'unhealthy',
            'message': 'Forced failure for testing'
        }, status=503)
    
    return JsonResponse({
        'status': 'healthy',
        'version': os.getenv('BUILD_VERSION', 'unknown')
    }, status=200)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health_check, name='health_check'),
]
