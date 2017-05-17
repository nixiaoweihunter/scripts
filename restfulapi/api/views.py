from rest_framework.authentication import SessionAuthentication, BasicAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.views import APIView

@api_view(['GET'])
def api_list(request, format=None):
    content = {
        'user': unicode(request.user),  # `django.contrib.auth.User` instance.
    }
    return Response(content)


