#!perl -w

use Mojolicious::Lite;
use Mojo::Upload;
use v5.14;

get '/' => 'page';
post '/' => sub {
   my $self = shift;
   my @files;
   for my $file (@{$self->req->uploads('files')}) {
     my $size = $file->size;
     my $name = $file->filename;

     push @files, "$name ($size)";
     $file->move_to("/tmp/".$name);
   }
   $self->render(text => "@files");
} => 'save';

app->start;

__DATA__

@@ page.html.ep
<!DOCTYPE html>
<html>
   <body>
   <form action="<%=/ProcessingFolder/%>" method="POST"
enctype="multipart/form-data">
     <input name="files" type="file" enctype="multipart/form-data" multiple="multiple">
     <button type="submit">Upload</button>
   </form>
   </body>
</html>
