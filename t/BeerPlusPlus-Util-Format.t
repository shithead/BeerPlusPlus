#! /usr/bin/env perl

use strict;
use warnings;

use feature 'say';


use Test::More 'no_plan';
BEGIN { use_ok('BeerPlusPlus::Util::Format') }


use Time::Piece;


my $PARSE_FORMAT = '%d-%m-%Y %T';


test_get_elapsed_in_words(
	'27-03-2016 19:22:03',
	'27-03-2016 23:22:41',
	'at 19:22',
	'same day',
);

test_get_elapsed_in_words(
	'27-03-2016 23:22:41',
	'28-03-2016 02:16:41',
	'at 23:22',
	'next day, within 3h',
);

test_get_elapsed_in_words(
	'28-03-2016 02:16:41',
	'29-03-2016 02:13:00',
	'yesterday, 02:16',
	'next day',
);

test_get_elapsed_in_words(
	'28-03-2016 02:16:41',
	'29-03-2016 23:17:00',
	'yesterday, 02:16',
	'(rather) next day',
);

test_get_elapsed_in_words(
	'28-03-2016 02:16:41',
	'30-03-2016 02:13:00',
	'2 days ago, 02:16',
	'(almost) 2 days after',
);

test_get_elapsed_in_words(
	'28-03-2016 02:16:41',
	'30-03-2016 02:17:22',
	'2 days ago, 02:16',
	'2 days after',
);

test_get_elapsed_in_words(
	'28-03-2016 02:16:41',
	'31-03-2016 19:17:22',
	'3 days ago, 02:16',
	'3 days after',
);

test_get_elapsed_in_words(
	'28-03-2016 02:16:41',
	'02-04-2016 19:17:22',
	'on 28.03., 02:16',
	'several days after, same year',
);

test_get_elapsed_in_words(
	'28-03-2016 02:16:41',
	'02-04-2017 19:17:22',
	'on 28.03.16, 02:16',
	'next year',
);


sub test_get_elapsed_in_words {
	my $then = to_epoch(shift);
	my $now  = to_epoch(shift);
	my $expected = shift;
	my $description = shift;

	my $got = get_elapsed_in_words($then, $now);

	is($got, $expected, $description);
}

sub to_epoch {
	return localtime->strptime(shift, $PARSE_FORMAT)->epoch;
}

