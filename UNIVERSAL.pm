#

package UNIVERSAL;

=head1 NAME

    UNIVERSAL - Default general behaviour for all objects.

=head1 SYNOPSIS

    use UNIVERSAL;

    if($obj->isa('IO::Handle')) {
    	...
    }

    $func = $obj->can('some_method_name');

    $class = $obj->class;

    if($var->is_instance) {
    	...
    }

=head1 DESCRIPTION

The C<UNIVERSAL> package defines methods that are inherited by all other
classes. These methods are

=over 4

=item isa( CLASS )

C<isa> returns I<true> if its object is blessed into a sub-class of C<CLASS>

C<isa> is also exportable and can be called as a sub with two arguments. This
allows the ability to check what a reference points to. Example

    use UNIVERSAL qw(isa);

    if(isa($ref, 'ARRAY')) {
    	...
    }

=item can( METHOD )

C<can> checks to see if its object has a method called C<METHOD>,
if it does then a reference to the sub is returned, if it does not then
I<undef> is returned.

=item class()

C<class> returns the class name of its object.

=item is_instance()

C<is_instance> returns true if its object is an instance of some
class, false if its object is the class (package) itself. Example

    A->is_instance();       # Flase
    
    $var = 'A';
    $var->is_instance();    # False
    
    $ref = bless [], 'A';
    $ref->is_instance();    # True

=back

=head1 NOTE

C<isa> and C<can> are implemented in XS code. C<can> directly uses perl's
internal code for method lookup, and C<isa> uses a very similar method and
cache-ing strategy. This may cause strange effects if the perl code
dynamically changes @ISA in any package.

=head1 AUTHOR

Graham Barr <Graham.Barr@tiuk.ti.com>

=head1 COPYRIGHT

Copyright (c) 1995 Graham Barr. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

=head1 REVISION

$Revision: 1.2 $

=cut

$VERSION  = sprintf("%d.%02d", q$Revision: 1.2 $ =~ /(\d+)\.(\d+)/);

require DynaLoader;
require Exporter;

@ISA = qw(Exporter DynaLoader);
@EXPORT_OK = qw(isa);

bootstrap UNIVERSAL $VERSION;

sub is_instance {
    ref($_[0]) ? 1 : ''
}

sub class {
    ref($_[0]) || $_[0]
}

1;

