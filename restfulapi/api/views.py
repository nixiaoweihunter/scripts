from django.shortcuts import render
from django.http import HttpResponse,JsonResponse

# Create your views here.


def api_list(request):
	if request.method == 'GET':
		return JsonResponse("{'Alice': '2341', 'Beth': '9102', 'Cecil': '3258'}",safe=False)
