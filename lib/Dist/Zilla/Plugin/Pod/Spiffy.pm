package Dist::Zilla::Plugin::Pod::Spiffy;

use strict;
use warnings;

# VERSION

use Moose;
with qw/Dist::Zilla::Role::FileMunger/;
use namespace::autoclean -also => qr/^__/;

sub munge_file {
        my ($self, $file) = @_;
        return unless $file->name =~ /\.(?:p[lm]|t)$/;

        my $content = $file->content;
        $content =~ s/
            ^=for\s+  pod_spiffy  \s+ (?<args>.+?) (?=\n\n)
            |
            ^=begin\s+ pod_spiffy \s+ (?<args>.+?) ^=end\s+ pod_spiffy \s+\n
        / __munge_args( $+{args} ) /sexmg;

        $file->content( $content );

        return;
}

sub __munge_args {
    my $in = shift;
    $in =~ s/\s+/ /g;
    my @ins = split /\s*\|\s*/, $in;

    my $mungings = __mungings('http://zcms');
    my $out;
    for ( @ins ) {
        s/^\s+|\s+$//g;
        tr/ /_/;
        next unless $mungings->{$_};
        $out .= ' ' . $mungings->{$_};
    }

    return '=for html ' . $out;
}

sub __mungings {
    my $theme = shift;
    return {
        in_no_args  => qq{<img alt="" src="$theme/in-no-args.png">},
        out_error_undef_list
            => qq{<img alt="" src="$theme/out-error-undef-list.png">},
    };
}

q|
Creativity is the feeling you get when you realize
your project is due tomorrow
|;

__END__

=encoding utf8

=head1 NAME

Dist::Zilla::Plugin::Pod::Spiffy - make your documentation look spiffy as HTML

=for test_synopsis BEGIN { die "SKIP: Not needed\n"; }

=head1 SYNOPSIS

In your POD:

    =head2 C<my_super_function>

    =for pod_spiffy in no args | out error undef/list|out hashref

    This function takes two arguments, one of them is mandatory. On
    error it returns either undef or an empty list, depending on the
    context. On success, it returns a hashref.

    ...

    =head1 REPOSITORY

    =for pod_spiffy git https://github.com/zoffixznet/Dist-Zilla-Plugin-Pod-Spiffy

    ...

    =head1 AUTHORS

    =for pod_spiffy pause_authors ZOFFIX JOE SHMOE

    =head1 CONTRIBUTORS

    =for pod_spiffy pause_authors SOME CONTRIBUTOR


In your C<dist.ini>:

    [Pod::Spiffy]

=head1 DESCRIPTION

This L<Dist::Zilla> plugin lets you make your documentation look
spiffy as HTML, by adding meaningful icons. If you're viewing this document
as HTML, you can see available icons below.

The main idea behind this module isn't so much the looks, however, but
the provision of visual hints and clues about various sections of your
documentation, and more importantly the arguments and return values
of the methods/functions.

=head1 HISTORY

I was impressed by L<ETHER>'s work on
L<Acme::CPANAuthors::Nonhuman> (the including author avatars in the docs
part) and appreciated the added value HTML content can bring to
the POD in my L<Acme::Dump::And::Dumper>.

While working on the implementation of the horribly inconsistent
L<WWW::Goodreads>, I wanted my users to not have to remember the
type of return values for 74+ methods. That's when I thought up the idea
of including icons to give hints of the return types.