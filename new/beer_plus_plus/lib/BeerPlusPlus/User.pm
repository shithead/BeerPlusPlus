package BeerPlusPlus::User;
use Mojo::Base 'Mojolicious::Controller';

#FIXME path should be absolute and in config
my $DATADIR = '../../users';

sub user_exists
{
	my ($self, $username) = @_;
	return 0 unless $username;
	my %users = map { $_ => 1 } ( $self->get_users );
	return 1 if (exists $users{$username});
	return 0;
}

sub init
{
	my $self = shift;
	$self->res->headers->cache_control('max-age=1, no_cache');
	my $user = $self->session->{user};
	if ( $self->user->user_exists($user) ) {
		my $hash = $self->json2hash($user);
		$self->session(counter => $hash->{counter});
		$self->session(expected_pass => $hash->{pass});
		return $hash;
	}
	return undef;
}

sub json2hash
{
	my $self = shift;
	my $filename = shift;
	my $path = "$DATADIR/$filename.json";
	# TODO put more error handling instead of just dying
	open my $fh, '<', $path or die qq/cannot open $path: $!/;
	$/ = undef;
	my $data = <$fh>;
	close $fh;
	my $json = Mojo::JSON->new;
	my $hashref = $json->decode($data);
	return $hashref;
}

sub get_users
{
	my $self = shift;
	#TODO path to user files should be read from config
	my @userlist = grep { s/(.*\/|\.json$)//g } glob "$DATADIR/*.json";
	return wantarray ? @userlist : \@userlist;
}

sub persist
{
	my $self = shift;
	my $user = $self->session->{user};
	my $json = Mojo::JSON->new;
	my $tmp = $self->session->{expected_pass};
	delete $self->session->{expected_pass};
	my $data = $json->encode($self->session);
	open my $fh, '>', "$DATADIR/$user.json" || die "cannot open $!";
	print {$fh} $data;
	close $fh;
	$self->session->{expected_pass} = $tmp;
	return 0;
}

sub register
{
	my $self = shift;
	return 0 if $self->param('passwd') ne $self->param('passwd2');
	$self->check($self->param('passwd'), $self->param('passwd2'));
	my $newph = sha1_base64($self->param('passwd'));
	$self->session->{pass} = $newph;
	$self->persist;
	$self->init;
	$self->redirect_to('/welcome');
}

sub check
{
	my $self = shift;
	my $newpw = shift;
	$self->render(text => qq/come on .../) if (length($newpw) < 8);
	return 0;
}

1;
