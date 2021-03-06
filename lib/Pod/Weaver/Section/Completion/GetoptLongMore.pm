package Pod::Weaver::Section::Completion::GetoptLongMore;

# DATE
# VERSION

use 5.010001;
use Moose;
with 'Pod::Weaver::Role::AddTextToSection';
with 'Pod::Weaver::Role::Section';
with 'Pod::Weaver::Role::SectionText::SelfCompletion';

use List::Util qw(first);

sub weave_section {
    my ($self, $document, $input) = @_;

    my $filename = $input->{filename} || 'file';

    my $command_name;
    if ($filename =~ m!^(bin|script)/(.+)$!) {
        $command_name = $2;
    } else {
        $self->log_debug(["skipped file %s (not an executable)", $filename]);
        return;
    }

    # file looks like a completer script, don't bother generating completer for
    # completer :)
    if ($command_name =~ /\A_/) {
        $self->log_debug(["skipped script %s (a completer itself)", $filename]);
        return;
    }

    # find file content in zilla object, not directly in filesystem, because the
    # file might be generated dynamically by dzil.
    my $file = first { $_->name eq $filename } @{ $input->{zilla}->files };
    unless ($file) {
        $self->log_fatal(["can't find file %s in zilla object", $filename]);
    }
    my $content = $file->content;
    #unless ($content =~ /\A#!.+perl/) {
    #    $self->log_debug(["skipped file %s (not a Perl script)",
    #                      $filename]);
    #    return;
    #}
    unless ($content =~ /(use|require)\s+Getopt::Long::More\b/) {
        $self->log_debug(["skipped file %s (does not use Getopt::Long::More)",
                          $filename]);
        return;
    }

    my $text = $self->section_text_self_completion({command_name=>$command_name});

    $self->add_text_to_section($document, $text, 'COMPLETION');
}

no Moose;
1;
# ABSTRACT: Add a COMPLETION section for Getopt::Long::More-based scripts

=for Pod::Coverage weave_section

=head1 SYNOPSIS

In your F<weaver.ini>:

 [Completion::GetoptLongMore]


=head1 DESCRIPTION

This section plugin adds a COMPLETION section for Getopt::Long::More-based
scripts. The section contains information on how to activate shell tab
completion for the scripts.


=head1 SEE ALSO

L<Getopt::Long::More>

=cut
