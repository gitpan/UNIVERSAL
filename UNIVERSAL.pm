package UNIVERSAL;

sub FileHandle::is_instance {$_[0] ne 'FileHandle'}
sub FileHandle::class {'FileHandle'}

sub is_instance {ref($_[0]) ? 1 : ''}
sub class {ref($_[0]) || $_[0]}

1;
__END__

=head1 NAME

UNIVERSAL - default general behaviour for all objects.

=head1 SYNOPSIS

Usage:

    require UNIVERSAL;
    
    $class = $any_object->class();
    $bool = $any_object->is_instance();

=head1 DESCRIPTION

Provides general default methods which any object can call.

=over 4

=item ->class()

This method returns the class of its object.

=item ->is_instance()

This method returns true if its object is an instance of some
class, false if its object is the class (package) itself. i.e.
if 'A' is a package, then 'A->is_instance()' is false,
but '$a = bless [],A; $a->is_instance()' is true.

=back

=head1 EXAMPLE

The following illustrates the methods, and can be executed
using C<perl -x UNIVERSAL.pm>

#!perl
    

    require UNIVERSAL;
    package C;
    sub new {bless []}
    
    package main;
    sub test {
       my($obj,$meth,@args) = @_;
       print $obj,'->',$meth,'(',@args,") gives '",
        	join(',',$obj->$meth(@args)),"'\n"
    }
    
    test(C,'is_instance'); 			#C->is_instance()
    test(C->new(),'is_instance'); 		#C->new()->is_instance()
    
    test(C,'class'); 				#C->class()
    test(C->new(),'class'); 			#C->new()->class()
    
__END__

=head1 MODIFICATION HISTORY

Base version, 1.0, 18th May 1995 - JS.

=cut
