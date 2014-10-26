package Anansi::Database::PostgreSQL;


=head1 NAME

Anansi::Database::PostgreSQL - A manager for PostgreSQL databases.

=head1 SYNOPSIS

    use Anansi::Database::PostgreSQL;
    if(Anansi::Database::PostgreSQL->validate(
        undef,
        DRIVER => 'PostgreSQL',
    )) {
        my $OBJECT = Anansi::Database::PostgreSQL->new();
        if($OBJECT->connect(
            undef,
            DATABASE => 'someDatabase',
            PASSWORD => 'somePassword',
            USERNAME => 'someUser',
        )) {
            my $records = $OBJECT->statement(
                undef,
                INPUT => [
                    {
                        DEFAULT => '0',
                        NAME => 'yetAnotherField',
                    }
                ],
                SQL => 'SELECT some_field, another_field FROM some_table WHERE yet_another_field = ?;',
                yetAnotherField => 123,
            );
            $OBJECT->disconnect();
            if(defined($records)) {
                if(ref($records) =~ /^ARRAY$/i) {
                    my $record = 0;
                    foreach my $record (@{$records}) {
                        next if(ref($record) !~ /^HASH$/i);
                        print "\n" if(0 < $record);
                        my $field = 0;
                        foreach my $key (keys(%{$record})) {
                            print ', ' if(0 < $field);
                            print '"'.$key.'" = "'.${record}{$key}.'"';
                            $field++;
                        }
                        $record++;
                    }
                    print "\n";
                }
            }
        }
    }

    use Anansi::Database;
    my $OBJECT = Anansi::Database->new();
    my $component = $OBJECT->addComponent(
        undef,
        DRIVER => 'PostgreSQL',
    );
    if(defined($component)) {
        if($OBJECT->channel(
            'CONNECT',
            $component,
            DATABASE => 'someDatabase',
            PASSWORD => 'somePassword',
            USERNAME => 'someUser',
        )) {
            my $records = $OBJECT->channel(
                'STATEMENT',
                $component,
                INPUT => [
                    {
                        DEFAULT => '0',
                        NAME => 'yetAnotherField',
                    }
                ],
                SQL => 'SELECT some_field, another_field FROM some_table WHERE yet_another_field = ?;',
                yetAnotherField => 123,
            );
            if(defined($records)) {
                if(ref($records) =~ /^ARRAY$/i) {
                    my $record = 0;
                    foreach my $record (@{$records}) {
                        next if(ref($record) !~ /^HASH$/i);
                        print "\n" if(0 < $record);
                        my $field = 0;
                        foreach my $key (keys(%{$record})) {
                            print ', ' if(0 < $field);
                            print '"'.$key.'" = "'.${record}{$key}.'"';
                            $field++;
                        }
                        $record++;
                    }
                    print "\n";
                }
            }
        }
    }

=head1 DESCRIPTION

Manages PostgreSQL databases allowing the opening and closing of PostgreSQL databases.
Uses L<Anansi::Actor>, L<Anansi::ComponentManager> I<(indirectly)>,
L<Anansi::DatabaseComponent> and L<base>.

=cut


our $VERSION = '0.02';

use base qw(Anansi::DatabaseComponent);


=head1 INHERITED METHODS

=cut


=head2 addChannel

Declared in L<Anansi::Component>.

=cut


=head2 autocommit

Declared in L<Anansi::DatabaseComponent>.

=cut


Anansi::Component::addChannel('Anansi::Database::PostgreSQL', 'AUTOCOMMIT' => 'Anansi::DatabaseComponent::autocommit');


=head2 bind

Declared in L<Anansi::DatabaseComponent>.

=cut


=head2 binding

Declared in L<Anansi::DatabaseComponent>.

=cut


=head2 channel

Declared in L<Anansi::Component>.

=cut


=head2 commit

Declared in L<Anansi::DatabaseComponent>.

=cut


Anansi::Component::addChannel('Anansi::Database::PostgreSQL', 'COMMIT' => 'Anansi::DatabaseComponent::commit');


=head2 componentManagers

Declared in L<Anansi::Component>.

=cut


=head2 connect

    if(Anansi::Database::PostgreSQL::connect(
        $OBJECT,
        undef,
        DATABASE => 'someDatabase',
        PASSWORD => 'somePassword',
        USERNAME => 'someUser',
    ));

    if($OBJECT->connect(
        undef,
        DATABASE => 'someDatabase',
        PASSWORD => 'somePassword',
        USERNAME => 'someUser',
    ));

=over 4

=item self I<(Blessed Hash, Required)>

An object of this namespace.

=item channel I<(String, Required)>

The abstract identifier of a subroutine.

=item parameters I<(Hash, Optional)>

Named parameters.

=over 4

=item AutoCommit I<(String, Optional)>

Defines whether the PostgreSQL driver automatically saves any changes made to the
B<DATABASE>.  A value of B<1> I<(one)> means changes will be saved, a value of
B<0> I<(zero)> means changes will need to be manually saved.  Changes are not
saved by default.

=item DATABASE I<(String, Optional)>

The name of the PostgreSQL database.  The content of the I<PGDATABASE>
environment variable is used by default.

=item HOSTNAME I<(String, Optional)>

The IP address of the computer where the PostgreSQL B<DATABASE> is hosted.  
Either the content of the I<PGHOST> environment variable or a value of
B<127.0.0.1> is used by default.

=item PASSWORD I<(String, Optional)>

The password of the B<USERNAME> that is accessing the PostgreSQL database.  The
content of the I<PGPASSWORD> environment variable is used by default.

=item PORT I<(String, Optional)>

The IP address port number of the computer where the PostgreSQL B<DATABASE> is
hosted.  Either the content of the I<PGPORT> environment variable or a value of
B<5432> I<(five four three two)> is used by default.

=item PrintError I<(String, Optional)>

Defines whether the PostgreSQL driver will use the B<warn> function.  A value of B<1>
I<(one)> means errors will be output using B<warn>, a value of B<0> I<(zero)>
means errors will not be output in this way.  Errors are output by default.

=item RaiseError I<(String, Optional)>

Defines whether the PostgreSQL driver will use the B<die> function.  A value of B<1>
I<(one)> means errors will be output using B<die>, a value of B<0> I<(zero)>
means errors will not be output in this way.  Errors are output by default.

=item USERNAME I<(String, Optional)>

The user that is accessing the PostgreSQL database.  The content of the
I<PGUSER> environment variable is used by default.

=back

=back

Declared in L<Anansi::DatabaseComponent>.  Overridden by this module.

=cut


sub connect {
    my ($self, $channel, %parameters) = @_;
    return $self->SUPER::connect(
        undef,
        INPUT => [
            {
                INPUT => [
                    'dbi:Pg:dbname=', {
                        DEFAULT => $ENV{'PGDATABASE'} || '',
                        NAME => 'DATABASE',
                        REF => '',
                    },
                    ';host=', {
                        DEFAULT => $ENV{'PGHOST'} || '127.0.0.1',
                        NAME => 'HOSTNAME',
                        REF => '',
                    },
                    ';port=', {
                        DEFAULT => $ENV{'PGPORT'} || '5432',
                        NAME => 'PORT',
                        REF => '',
                    }
                ],
                REF => '',
            }, {
                DEFAULT => $ENV{'PGUSER'} || undef,
                NAME => 'USERNAME',
                REF => '',
            }, {
                DEFAULT => $ENV{'PGPASSWORD'} || undef,
                NAME => 'PASSWORD',
                REF => '',
            }, {
                INPUT => [
                    {
                        DEFAULT => 0,
                        NAME => 'AutoCommit',
                        REF => '',
                    }, {
                        DEFAULT => 1,
                        NAME => 'PrintError',
                        REF => '',
                    }, {
                        DEFAULT => 1,
                        NAME => 'RaiseError',
                        REF => '',
                    }
                ],
                REF => 'HASH',
            }
        ],
        (%parameters),
    );
}

Anansi::Component::addChannel('Anansi::Database::PostgreSQL', 'CONNECT' => 'connect');


=head2 disconnect

Declared in L<Anansi::DatabaseComponent>.

=cut


Anansi::Component::addChannel('Anansi::Database::PostgreSQL', 'DISCONNECT' => 'Anansi::DatabaseComponent::disconnect');


=head2 finalise

Declared in L<Anansi::DatabaseComponent>.

=cut


=head2 finish

Declared in L<Anansi::DatabaseComponent>.

=cut


Anansi::Component::addChannel('Anansi::Database::PostgreSQL', 'FINISH' => 'Anansi::DatabaseComponent::finish');


=head2 handle

Declared in L<Anansi::DatabaseComponent>.

=cut


Anansi::Component::addChannel('Anansi::Database::PostgreSQL', 'HANDLE' => 'Anansi::DatabaseComponent::handle');


=head2 implicate

Declared in L<Anansi::Class>.

=cut


=head2 import

Declared in L<Anansi::Class>.

=cut


=head2 initialise

Declared in L<Anansi::DatabaseComponent>.

=cut


=head2 old

Declared in L<Anansi::Class>.

=cut


=head2 prepare

Declared in L<Anansi::DatabaseComponent>.

=cut


Anansi::Component::addChannel('Anansi::Database::PostgreSQL', 'PREPARE' => 'Anansi::DatabaseComponent::prepare');


=head2 removeChannel

Declared in L<Anansi::Component>.

=cut


=head2 rollback

Declared in L<Anansi::DatabaseComponent>.

=cut


Anansi::Component::addChannel('Anansi::Database::PostgreSQL', 'ROLLBACK' => 'Anansi::DatabaseComponent::rollback');


=head2 statement

Declared in L<Anansi::DatabaseComponent>.

=cut


Anansi::Component::addChannel('Anansi::Database::PostgreSQL', 'STATEMENT' => 'Anansi::DatabaseComponent::statement');


=head2 used

Declared in L<Anansi::Class>.

=cut


=head2 uses

Declared in L<Anansi::Class>.

=cut


=head2 validate

    if(1 == Anansi::Database::PostgreSQL::validate($OBJECT, undef));

    if(1 == Anansi::Database::PostgreSQL::channel($OBJECT, 'VALIDATE_AS_APPROPRIATE'));

    if(1 == Anansi::Database::PostgreSQL->validate(undef));

    if(1 == Anansi::Database::PostgreSQL->channel('VALIDATE_AS_APPROPRIATE'));

    if(1 == $OBJECT->validate(undef, DRIVER => 'PostgreSQL'));

    if(1 == $OBJECT->channel('VALIDATE_AS_APPROPRIATE', DRIVER => 'PostgreSQL'));

    if(1 == Anansi::Database::PostgreSQL->validate(undef, DRIVER => 'PostgreSQL'));

    if(1 == Anansi::Database::PostgreSQL->channel('VALIDATE_AS_APPROPRIATE', DRIVER => 'PostgreSQL'));

=over 4

=item self I<(Blessed Hash B<or> String, Required)>

Either an object or a string of this namespace.

=item channel I<(String, Required)>

The abstract identifier of a subroutine.

=item parameters I<(Hash, Optional)>

Named parameters.

=over 4

=item DRIVER

When the B<DRIVER> parameter is defined as either I<Pg>, I<Postgres> or
I<PostgreSQL> then this database driver component will be used otherwise an
attempt will be made to use this driver.

=back

=back

Declared in L<Anansi::DatabaseComponent>.  Overridden by this module.

=cut


sub validate {
    my ($self, $channel, %parameters) = @_;
    $parameters{DRIVERS} = [
        'Pg',
        'Postgres',
        'PostgreSQL'
    ];
    return $self->SUPER::validate(undef, (%parameters));
}


Anansi::Component::addChannel('Anansi::Database::PostgreSQL', 'VALIDATE_AS_APPROPRIATE' => 'validate');


=head1 METHODS

=cut


=head1 NOTES

This module is designed to make it simple, easy and quite fast to code your
design in perl.  If for any reason you feel that it doesn't achieve these goals
then please let me know.  I am here to help.  All constructive criticisms are
also welcomed.

=cut


=head1 AUTHOR

Kevin Treleaven <kevin I<AT> treleaven I<DOT> net>

=cut


1;
