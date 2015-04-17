from sys import argv  
import os  
  
def split(filename, chunksize):  
 statinfo = os.stat(filename)  
 print "file size: %d(mb)" % (statinfo.st_size/(1024*1024))  
 with open(filename, "rb") as f:  
  index = 0  
  while True:  
   chunk = f.read(chunksize)  
   if(chunk):  
    fn = "%s.part.%d" % (filename, index)  
    index = index + 1  
    print "creating", fn  
    with open(fn, "wb") as fw:  
     fw.write(chunk)  
   else:  
    break  
    
def main():  
 filename = argv[1]  
 chunksize =  int(argv[2]) * 1024 * 1024  
 print "file name:", filename  
 print "chunk size: %d(mb)" % (chunksize/(1024*1024))  
 split(filename, chunksize)  
  
if __name__ == '__main__':
    main()
