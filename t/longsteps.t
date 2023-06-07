use Test2::V0;
use Schedule::LongSteps;

{
    package MyProcess;
    use Moose;
    extends qw/Schedule::LongSteps::Process/;

    use DateTime;
    sub build_first_step{
        my ($self) = @_;
        return $self->new_step({ what => 'do_stuff1', run_at => DateTime->now() });
    }

    sub do_stuff1{
        my ($self) = @_;
        return $self->final_step({ state => { the => 'final', state => 1 }  }) ;
    }
}


ok( my $long_steps = Schedule::LongSteps->new() );

ok( my $process = $long_steps->instantiate_process('MyProcess', undef, { beef => 'saussage' }) );
ok( $process->id() );

is( $process->what() , 'do_stuff1' );
is( $process->state() , { beef => 'saussage' });

{
    ok( my $loaded_process = $long_steps->load_process( $process->id() ),
        'can load a process' );
    my $stored_process = $loaded_process->stored_process;
    is( $process->id(),   $stored_process->id(),   'same process: id' );
    is( $process->what(), $stored_process->what(), 'same process: what' );
    is( $process->state(), $stored_process->state(), 'same process: state' );
}

# Time to run!
ok( $long_steps->run_due_processes() );

# And check the step properties have been
is( $process->state(), { the => 'final', state => 1 });
is( $process->status() , 'terminated' );
is( $process->run_at() , undef );

{
    ok( my $loaded_process = $long_steps->load_process( $process->id() ),
        'can load a process' );
    my $stored_process = $loaded_process->stored_process;
    is( $process->id(),   $stored_process->id(),   'same process: id' );
    is( $process->what(), $stored_process->what(), 'same process: what' );
    is( $process->state(), $stored_process->state(), 'same process: state' );
}
# Check no due step have run again
ok( ! $long_steps->run_due_processes() );

done_testing();
