#coding:utf-8
from django.shortcuts import render
import MySQLdb
from django.http.response import HttpResponseRedirect



# Create your views here.

def index(request):
    return render(request,'index.html')

def search(request):
    if 'text' in request.GET:
        mytext = request.GET['text']
        
        conn = MySQLdb.connect(host="",user="",passwd="",db="",charset="utf8")
        cursor=conn.cursor()
        
        sql="select content from q_query where match(title)against(%s in boolean mode)"
        n = cursor.execute(sql,mytext)
        
        result = cursor.fetchmany(n)
            
        context = {'resultarr': result}
        
        return render(request,'search.html',context)
    
def submit(request):
    return render(request,'submit.html')

def insert(request):
    if request.method == "POST":
        text = request.POST['title']
        textarea = request.POST['content']
        
        conn = MySQLdb.connect(host="",user="",passwd="",db="",charset="utf8")
        cursor=conn.cursor()
        
        sql = "insert into q_query(title,content) values(%s,%s)"
        param = (text,textarea)
        n = cursor.execute(sql,param)
        
    return HttpResponseRedirect('/')
