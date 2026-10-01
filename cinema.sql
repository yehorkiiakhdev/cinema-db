create table cinemas
(
    cinema_id  bigint unsigned auto_increment
        primary key,
    name       varchar(150)                            not null,
    city       varchar(100)                            not null,
    address    varchar(255)                            not null,
    timezone   varchar(64) default 'Europe/Tallinn'    not null,
    created_at datetime    default current_timestamp() not null,
    constraint uq_cinemas_name_city_address
        unique (name, city, address)
);

create table genres
(
    genre_id bigint unsigned auto_increment
        primary key,
    name     varchar(60) not null,
    constraint uq_genres_name
        unique (name)
);

create table halls
(
    hall_id   bigint unsigned auto_increment
        primary key,
    cinema_id bigint unsigned not null,
    name      varchar(80)     not null,
    constraint uq_halls_cinema_name
        unique (cinema_id, name),
    constraint fk_halls_cinema
        foreign key (cinema_id) references cinemas (cinema_id)
            on update cascade
);

create table movies
(
    movie_id         bigint unsigned auto_increment
        primary key,
    title            varchar(255)                         not null,
    original_title   varchar(255)                         null,
    description      text                                 null,
    duration_minutes smallint unsigned                    not null,
    release_date     date                                 null,
    age_rating       varchar(10)                          null,
    language_code    char(2)  default 'et'                not null,
    poster_url       text                                 null,
    created_at       datetime default current_timestamp() not null,
    constraint chk_movies_duration
        check (`duration_minutes` > 0)
);

create table movie_genres
(
    movie_id bigint unsigned not null,
    genre_id bigint unsigned not null,
    primary key (movie_id, genre_id),
    constraint fk_movie_genres_genre
        foreign key (genre_id) references genres (genre_id)
            on update cascade,
    constraint fk_movie_genres_movie
        foreign key (movie_id) references movies (movie_id)
            on update cascade on delete cascade
);

create table screenings
(
    screening_id  bigint unsigned auto_increment
        primary key,
    movie_id      bigint unsigned                 not null,
    hall_id       bigint unsigned                 not null,
    starts_at     datetime                        not null,
    format        varchar(20) default '2d'        not null,
    base_price    decimal(8, 2)                   not null,
    currency_code char(3)     default 'EUR'       not null,
    status        varchar(20) default 'scheduled' not null,
    constraint uq_screenings_id_hall
        unique (screening_id, hall_id),
    constraint fk_screenings_hall
        foreign key (hall_id) references halls (hall_id)
            on update cascade,
    constraint fk_screenings_movie
        foreign key (movie_id) references movies (movie_id)
            on update cascade,
    constraint chk_screenings_format
        check (`format` in ('2d', '3d', 'imax', 'vip')),
    constraint chk_screenings_price
        check (`base_price` >= 0),
    constraint chk_screenings_status
        check (`status` in ('scheduled', 'cancelled', 'completed'))
);

create index ix_screenings_hall_start
    on screenings (hall_id, starts_at);

create index ix_screenings_movie_start
    on screenings (movie_id, starts_at);

create table seats
(
    seat_id     bigint unsigned auto_increment
        primary key,
    hall_id     bigint unsigned                not null,
    row_label   varchar(5)                     not null,
    seat_number smallint unsigned              not null,
    seat_type   varchar(20) default 'standard' not null,
    constraint uq_seats_hall_row_number
        unique (hall_id, row_label, seat_number),
    constraint uq_seats_id_hall
        unique (seat_id, hall_id),
    constraint fk_seats_hall
        foreign key (hall_id) references halls (hall_id)
            on update cascade,
    constraint chk_seats_number
        check (`seat_number` > 0),
    constraint chk_seats_type
        check (`seat_type` in ('standard', 'premium', 'accessible', 'double'))
);

create table users
(
    user_id       bigint unsigned auto_increment
        primary key,
    email         varchar(254)                         not null,
    password_hash varchar(255)                         not null,
    display_name  varchar(100)                         not null,
    birth_date    date                                 null,
    created_at    datetime default current_timestamp() not null,
    constraint uq_users_email
        unique (email)
);

create table bookings
(
    booking_id    bigint unsigned auto_increment
        primary key,
    user_id       bigint unsigned                         null,
    contact_email varchar(254)                            not null,
    status        varchar(20) default 'pending'           not null,
    created_at    datetime    default current_timestamp() not null,
    expires_at    datetime                                null,
    constraint fk_bookings_user
        foreign key (user_id) references users (user_id)
            on update cascade on delete set null,
    constraint chk_bookings_status
        check (`status` in ('pending', 'confirmed', 'cancelled', 'expired'))
);

create index ix_bookings_user_created
    on bookings (user_id, created_at);

