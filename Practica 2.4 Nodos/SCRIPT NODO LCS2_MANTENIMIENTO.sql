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

create table if not exists mantenimiento
(
    mantenimientoId int auto_increment
        primary key,
    vehiculoId      int                              not null,
    fechaServicio   date                             not null,
    tipoServicio    varchar(100)                     not null,
    descripcion     varchar(200)                     null,
    costo           decimal(10, 2)                   not null,
    estado          varchar(20) default 'Completado' null,
    constraint mantenimiento_ibfk_1
        foreign key (vehiculoId) references vehiculo (vehiculoId)
            on delete cascade
)
    auto_increment = 127;

create trigger after_insert_mantenimiento
    after insert
    on mantenimiento
    for each row
begin
    BEGIN
    UPDATE lcs1_principal.vehiculo
    SET fechaVerificacion = NEW.fechaServicio
    WHERE vehiculoId = NEW.vehiculoId;
END
    end;

