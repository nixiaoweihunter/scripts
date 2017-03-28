#coding:utf-8
#/usr/bin/env python

from elasticsearch import Elasticsearch

es = Elasticsearch("10.10.3.115:9200")

results = es.search(
        index="logstash-2015.04.22",
        body={
           'query':{
            'match':{
		"server_name":"assist38"
             }        
            }
        }
)
 
print results['hits']['total']
