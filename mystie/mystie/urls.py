from django.conf.urls import include, url
from django.contrib import admin
from myweb import views

urlpatterns = [
    # Examples:
    # url(r'^$', 'mystie.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),

    url(r'^admin/', include(admin.site.urls)),
    url(r'^$', include('myweb.urls')),
    url(r'^search/', views.search, name="search"),
    url(r'^submit/', views.submit, name="submit"),
    url(r'^insert/', views.insert, name="insert"),   
]