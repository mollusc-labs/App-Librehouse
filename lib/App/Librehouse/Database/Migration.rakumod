use v6.d;

unit class App::Librehouse::Database::Migration is export;


my @used_ids;

has $.id is required;
has $.up is Str:D;
has $.down is Str:D;

method TWEAK {
    die "Your id is aleady in use" if @used_ids.first: * eq $!id;
    @used_ids.push($!id);
}


our @migrations is export = (
    Migration.new( 
        id => "init_user_table", 
        up => "CREATE TABLE IF NOT EXISTS usr (
               id VARCHAR PRIMARY KEY,
               picture VARCHAR DEFAULT '/static/usercontent/default.png',
               name VARCHAR(30) UNIQUE,
               email VARCHAR UNIQUE,
               password VARCHAR,
               reputation INT DEFAULT 0,
               last_login TIMESTAMP,
               created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);", 
        down => "DROP TABLE IF EXISTS usr CASCADE;" 
    ),
    Migration.new( 
        id => "init_board_table",
        up =>   "CREATE TABLE IF NOT EXISTS board (
               id VARCHAR(30) PRIMARY KEY,
               name VARCHAR(30) UNIQUE NOT NULL,
               slug VARCHAR(30) UNIQUE NOT NULL,
               description VARCHAR(255),
               creator VARCHAR NOT NULL,
               created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
               archived BOOLEAN DEFAULT FALSE,
               FOREIGN KEY (creator) REFERENCES usr(id)
               );",
        down => "DROP TABLE IF EXISTS board CASCADE;"
    ),
    Migration.new(
        id => "init_post_table",
        up => "CREATE TABLE IF NOT EXISTS post (
               id SERIAL PRIMARY KEY,
               title VARCHAR NOT NULL,
               content VARCHAR NOT NULL,
               creator VARCHAR NOT NULL,
               views INT DEFAULT 0,
               created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
               board VARCHAR NOT NULL,
               FOREIGN KEY (board) REFERENCES board(id),
               FOREIGN KEY (creator) REFERENCES usr(id)
               );",
        down => "DROP TABLE IF EXISTS post CASCADE;"
    ),
    Migration.new(
        id => "init_reply_table",
        up => "CREATE TABLE IF NOT EXISTS reply (
           id SERIAL PRIMARY KEY,
           content VARCHAR NOT NULL,
           creator VARCHAR NOT NULL,
           created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
           post INT,
           parent INT NOT NULL,
           FOREIGN KEY (parent) REFERENCES reply(id),
           FOREIGN KEY (post) REFERENCES post(id),
           FOREIGN KEY (creator) REFERENCES usr(id)
           );", 
        
        down => "DROP TABLE IF EXISTS reply CASCADE;"
    ),
    Migration.new(
        id => "add_bio_column_to_usr",
        up => "ALTER TABLE usr ADD COLUMN IF NOT EXISTS bio VARCHAR(255) DEFAULT 'This user has no bio...';",
        down => "ALTER TABLE usr DROP COLUMN bio CASCADE;" 
    ),
    Migration.new(
        id => "add_name_idx_to_usr",
        up => "CREATE UNIQUE INDEX IF NOT EXISTS usr_name_idx ON usr (name);", 
        down => "DROP INDEX usr_name_idx CASCADE;" 
    ),

    Migration.new(
        id => "add_is_admin_to_usr",
        up => "ALTER TABLE usr ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;",
        down => "ALTER TABLE usr DROP COLUMN is_admin CASCADE;"
    ),

    Migration.new(
        id => "add_slug_idx_to_board",
        up => "CREATE UNIQUE INDEX IF NOT EXISTS board_slug_idx ON board (slug);",
        down => "DROP INDEX board_slug_idx CASCADE;"
    ),
    
    Migration.new(
        id => "add_archived_to_post",
        up => "ALTER TABLE post ADD COLUMN IF NOT EXISTS archived BOOLEAN DEFAULT FALSE;",
        down => "ALTER TABLE post DROP COLUMN archived CASCADE;"
    ),
    Migration.new(
        id => "add_banned_to_usr",
        up => "ALTER TABLE usr ADD COLUMN IF NOT EXISTS banned BOOLEAN DEFAULT FALSE;",
        down => "ALTER TABLE usr DROP COLUMN banned CASCADE;"
    )
);

