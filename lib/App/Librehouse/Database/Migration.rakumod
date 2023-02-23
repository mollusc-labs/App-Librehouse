use v6.d;
use Slang::SQL

unit class App::Librehouse::Database::Migration is export;


my @used_ids;

has $.id is required;
has &.up is required;
has &.down is required;

method TWEAK {
    die "Your id is aleady in use" if @used_ids.first: * eq $!id;
    @used_ids.push($!id);
}

our @migrations is export = (
    Migration.new( 
        id => "init_user_table", 
        up => { sql create table if not exists usr (
            id varchar primary key,
            picture varchar default '/static/usercontent/default.png',
            name varchar(30) unique,
            email varchar unique,
            password varchar,
            reputaion int default 0,
            last_login timestamp,
            created timestamp not null default current_timestamp
            );
        },
        down => { sql drop table if exists usr cascade; }
    ),
    Migration.new( 
        id => "init_board_table",
        up => { sql create table if not exists board (
            id varchar(30) primary key,
            name varchar(30) unique not null,
            slug varchar(30) unique not null,
            description varchar(255),
            creator varchar not null,
            created timestamp not null default current_timestamp,
            archived boolean default false,
            foreign key (creator) references usr(id));
        },
        down => { sql drop table if exists board cascade; }
    ),
    Migration.new(
        id => "init_post_table",
        up => { sql create table if not exists post (
            id serial primary key,
            title varchar not null,
            content varchar not null,
            creator varchar not null,
            views int default 0,
            created timestamp not null default current_timestamp,
            board varchar not null,
            foreign key (board) references board(id),
            foreign key (creator) references usr(id));
        },
        down => { sql drop table if exists post cascade; }
    ),
    Migration.new(
        id => "init_reply_table",
        up => { sql create table if not exists reply (
            id serial primary key,
            content varchar not null,
            creator varchar not null,
            created timestamp not null default current_timestamp,
            post int,
            parent int not null,
            foreign key (parent) references reply(id),
            foreign key (post) references post(id),
            foreign key (creator) references usr(id));
        },
        down => { sql drop table if exists reply cascade; }
    ),
    Migration.new(
        id => "add_bio_column_to_usr",
        up => { sql alter table usr add column if not exists bio varchar(255) default 'This user has no bio...'; },
        down => { sql alter table usr drop column bio cascade; }
    ),
    Migration.new(
        id => "add_name_idx_to_usr",
        up => { sql create unique index if not exists usr_name_idx on usr (name); },
        down => { sql drop index usr_name_idx cascade; }
    ),




