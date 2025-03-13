create table if not exists conductor
(
    conductorId         int auto_increment
        primary key,
    nombre              varchar(100)                 not null,
    numeroLicencia      varchar(50)                  not null,
    vencimientoLicencia date                         not null,
    estado              varchar(20) default 'Activo' null
)
    auto_increment = 127;

create table if not exists vehiculo
(
    vehiculoId        int auto_increment
        primary key,
    flotillaId        int                          not null,
    tipo              varchar(50)                  not null,
    modelo            varchar(50)                  not null,
    marca             varchar(50)                  not null,
    anio              int                          not null,
    estado            varchar(20) default 'Activo' null,
    fechaVerificacion date                         null
)
    auto_increment = 127;

create table if not exists ruta
(
    rutaId          int auto_increment
        primary key,
    vehiculoId      int                             not null,
    conductorId     int                             not null,
    horaInicio      datetime                        not null,
    horaFin         datetime                        null,
    distancia       decimal(10, 2)                  null,
    ubicacionInicio varchar(100)                    not null,
    ubicacionFin    varchar(100)                    not null,
    estado          varchar(20) default 'Pendiente' null,
    constraint ruta_ibfk_1
        foreign key (vehiculoId) references vehiculo (vehiculoId)
            on delete cascade,
    constraint ruta_ibfk_2
        foreign key (conductorId) references conductor (conductorId)
            on delete cascade
)
    auto_increment = 127;

create table if not exists transaccioncombustible
(
    transaccionId    int auto_increment
        primary key,
    vehiculoId       int            not null,
    conductorId      int            not null,
    monto            decimal(10, 2) not null,
    cantidad         decimal(10, 2) not null,
    tipoCombustible  varchar(20)    not null,
    fechaTransaccion datetime       not null,
    ubicacion        varchar(100)   null,
    constraint transaccioncombustible_ibfk_1
        foreign key (vehiculoId) references vehiculo (vehiculoId)
            on delete cascade,
    constraint transaccioncombustible_ibfk_2
        foreign key (conductorId) references conductor (conductorId)
            on delete cascade
)
    auto_increment = 127;

