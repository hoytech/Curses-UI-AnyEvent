package Curses::UI::AnyEvent;

our $VERSION = '0.100';

use strict;

use AnyEvent;
use base qw( Curses::UI );



sub startAsync {
    my $self = shift;

    $self->do_one_event;

    $self->{_async_watcher} = AE::io \*STDIN, 0, sub {
        $self->do_one_event;
    };
}

sub stopAsync {
    my $self = shift;

    delete $self->{_async_watcher};
}

sub mainloop {
    my $self = shift;

    $self->startAsync();

    $self->{_cv} = AE::cv;
    $self->{_cv}->recv;
    delete $self->{_cv};

    $self->stopAsync();
}

sub mainloopExit {
    my $self = shift;

    if (exists $self->{_cv}) {
        $self->{_cv}->send();
    } else {
        warn "Called mainloopExit but mainloop wasn't running";
    }
}

sub char_read {
    my $self = shift;

    $self->Curses::UI::Common::char_read(0); ## Ignore timeout passed in to us, hard-code to 0
}


1;



__END__

=encoding utf-8

=head1 NAME

Curses::UI::AnyEvent - Sub-class of Curses::UI for AnyEvent

=head1 SYNOPSIS

    use strict;

    use Curses::UI::AnyEvent;

    my $cui = Curses::UI::AnyEvent->new(-color_support => 1);

    $cui->set_binding(sub { exit }, "\cC");
    $cui->set_binding(sub { $cui->mainloopExit() }, "q");
   
    my $win = $cui->add('win', 'Window',
                        -border => 1,
                        -bfg  => 'red',
                       );


    my $textviewer = $win->add('mytextviewer', 'TextViewer',
                               -text => '',
                              );

    my $watcher = AE::timer 1, 1, sub {
        $textviewer->{-text} = localtime() . "\n" . $textviewer->{-text};
        $textviewer->draw;
    };

    $textviewer->focus();

    $cui->mainloop();

=head1 DESCRIPTION

Very simple integration with L<Curses::UI> and L<AnyEvent>. Just create a C<Curses::UI::AnyEvent> object instead of a C<Curses::UI> one and use it as normal.

You'll probably want to install some AnyEvent watchers before you call C<mainloop()>.

Seems to work well but there is probably some stuff missing. I haven't tested mouse integration yet for example. L<Curses::UI::POE> seems to do a lot more stuff for some reason...

=head1 SEE ALSO

L<Curses-UI-AnyEvent github repo|https://github.com/hoytech/Curses-UI-AnyEvent>

L<Curses::UI>

L<AnyEvent>

L<Curses::UI::POE>

=head1 AUTHOR

Doug Hoyte, C<< <doug@hcsw.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2016 Doug Hoyte.

This module is licensed under the same terms as perl itself.
