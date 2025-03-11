create table if not exists conductor
(
    conductorId         int auto_increment
        primary key,
    nombre              varchar(100)                 not null,
    numeroLicencia      varchar(50)                  not null,
    vencimientoLicencia date                         not null,
    estado              varchar(20) default 'Activo' null
)
    auto_increment = 128;

create table if not exists flotilla
(
    flotillaId     int auto_increment
        primary key,
    nombreEmpresa  varchar(100) not null,
    gestorFlotilla varchar(100) null,
    fechaCreacion  date         null
)
    auto_increment = 128;

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
    fechaVerificacion date                         null,
    constraint vehiculo_ibfk_1
        foreign key (flotillaId) references flotilla (flotillaId)
            on delete cascade
)
    auto_increment = 128;

create table if not exists documento
(
    documentoId      int auto_increment
        primary key,
    vehiculoId       int                           not null,
    tipo             varchar(50)                   not null,
    fechaVencimiento date                          not null,
    estado           varchar(20) default 'Vigente' null,
    rutaArchivo      varchar(255)                  null,
    constraint documento_ibfk_1
        foreign key (vehiculoId) references vehiculo (vehiculoId)
            on delete cascade
)
    auto_increment = 128;

create index idx_documento_vehiculo
    on documento (vehiculoId);

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
    auto_increment = 128;

create index idx_mantenimiento_vehiculo
    on mantenimiento (vehiculoId);

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
    auto_increment = 128;

create index idx_ruta_conductor
    on ruta (conductorId);

create index idx_ruta_vehiculo
    on ruta (vehiculoId);

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
    auto_increment = 128;

create index idx_transaccion_conductor
    on transaccioncombustible (conductorId);

create index idx_transaccion_vehiculo
    on transaccioncombustible (vehiculoId);

create index idx_vehiculo_flotilla
    on vehiculo (flotillaId);

create or replace view fragmento_conductores_activos as
select `sistemagestionflotillas`.`conductor`.`conductorId`         AS `conductorId`,
       `sistemagestionflotillas`.`conductor`.`nombre`              AS `nombre`,
       `sistemagestionflotillas`.`conductor`.`numeroLicencia`      AS `numeroLicencia`,
       `sistemagestionflotillas`.`conductor`.`vencimientoLicencia` AS `vencimientoLicencia`,
       `sistemagestionflotillas`.`conductor`.`estado`              AS `estado`
from `sistemagestionflotillas`.`conductor`
where (`sistemagestionflotillas`.`conductor`.`estado` = 'Activo');

create or replace view fragmento_conductores_inactivos as
select `sistemagestionflotillas`.`conductor`.`conductorId`         AS `conductorId`,
       `sistemagestionflotillas`.`conductor`.`nombre`              AS `nombre`,
       `sistemagestionflotillas`.`conductor`.`numeroLicencia`      AS `numeroLicencia`,
       `sistemagestionflotillas`.`conductor`.`vencimientoLicencia` AS `vencimientoLicencia`,
       `sistemagestionflotillas`.`conductor`.`estado`              AS `estado`
from `sistemagestionflotillas`.`conductor`
where (`sistemagestionflotillas`.`conductor`.`estado` = 'Inactivo');

create or replace view fragmento_conductores_transacciones as
select `c`.`conductorId`      AS `conductorId`,
       `c`.`nombre`           AS `nombre`,
       `c`.`numeroLicencia`   AS `numeroLicencia`,
       `t`.`transaccionId`    AS `transaccionId`,
       `t`.`monto`            AS `monto`,
       `t`.`cantidad`         AS `cantidad`,
       `t`.`tipoCombustible`  AS `tipoCombustible`,
       `t`.`fechaTransaccion` AS `fechaTransaccion`
from (`sistemagestionflotillas`.`conductor` `c` join `sistemagestionflotillas`.`transaccioncombustible` `t`
      on ((`c`.`conductorId` = `t`.`conductorId`)));

create or replace view fragmento_conductores_transacciones_ciudad as
select `c`.`conductorId`      AS `conductorId`,
       `c`.`nombre`           AS `nombre`,
       `t`.`transaccionId`    AS `transaccionId`,
       `t`.`monto`            AS `monto`,
       `t`.`tipoCombustible`  AS `tipoCombustible`,
       `t`.`fechaTransaccion` AS `fechaTransaccion`,
       `t`.`ubicacion`        AS `ubicacion`
from (`sistemagestionflotillas`.`conductor` `c` join `sistemagestionflotillas`.`transaccioncombustible` `t`
      on ((`c`.`conductorId` = `t`.`conductorId`)))
where (`t`.`ubicacion` = 'Estación Mobil - Guadalajara');

create or replace view fragmento_conductores_vigentes as
select `sistemagestionflotillas`.`conductor`.`conductorId`         AS `conductorId`,
       `sistemagestionflotillas`.`conductor`.`nombre`              AS `nombre`,
       `sistemagestionflotillas`.`conductor`.`numeroLicencia`      AS `numeroLicencia`,
       `sistemagestionflotillas`.`conductor`.`vencimientoLicencia` AS `vencimientoLicencia`,
       `sistemagestionflotillas`.`conductor`.`estado`              AS `estado`
from `sistemagestionflotillas`.`conductor`
where ((`sistemagestionflotillas`.`conductor`.`estado` = 'Activo') and
       (`sistemagestionflotillas`.`conductor`.`vencimientoLicencia` > curdate()));

create or replace view fragmento_mantenimientos_costosos_pendientes as
select `sistemagestionflotillas`.`mantenimiento`.`mantenimientoId` AS `mantenimientoId`,
       `sistemagestionflotillas`.`mantenimiento`.`vehiculoId`      AS `vehiculoId`,
       `sistemagestionflotillas`.`mantenimiento`.`fechaServicio`   AS `fechaServicio`,
       `sistemagestionflotillas`.`mantenimiento`.`tipoServicio`    AS `tipoServicio`,
       `sistemagestionflotillas`.`mantenimiento`.`descripcion`     AS `descripcion`,
       `sistemagestionflotillas`.`mantenimiento`.`costo`           AS `costo`,
       `sistemagestionflotillas`.`mantenimiento`.`estado`          AS `estado`
from `sistemagestionflotillas`.`mantenimiento`
where ((`sistemagestionflotillas`.`mantenimiento`.`estado` <> 'Completado') and
       (`sistemagestionflotillas`.`mantenimiento`.`costo` > 500));

create or replace view fragmento_rutas_conductores_licencia_vencida as
select `r`.`rutaId`              AS `rutaId`,
       `r`.`vehiculoId`          AS `vehiculoId`,
       `r`.`horaInicio`          AS `horaInicio`,
       `r`.`horaFin`             AS `horaFin`,
       `c`.`conductorId`         AS `conductorId`,
       `c`.`nombre`              AS `nombre`,
       `c`.`vencimientoLicencia` AS `vencimientoLicencia`
from (`sistemagestionflotillas`.`ruta` `r` join `sistemagestionflotillas`.`conductor` `c`
      on ((`r`.`conductorId` = `c`.`conductorId`)))
where ((`r`.`estado` = 'Completada') and (`c`.`vencimientoLicencia` < curdate()));

create or replace view fragmento_rutas_largas_en_curso as
select `sistemagestionflotillas`.`ruta`.`rutaId`          AS `rutaId`,
       `sistemagestionflotillas`.`ruta`.`vehiculoId`      AS `vehiculoId`,
       `sistemagestionflotillas`.`ruta`.`conductorId`     AS `conductorId`,
       `sistemagestionflotillas`.`ruta`.`horaInicio`      AS `horaInicio`,
       `sistemagestionflotillas`.`ruta`.`horaFin`         AS `horaFin`,
       `sistemagestionflotillas`.`ruta`.`distancia`       AS `distancia`,
       `sistemagestionflotillas`.`ruta`.`ubicacionInicio` AS `ubicacionInicio`,
       `sistemagestionflotillas`.`ruta`.`ubicacionFin`    AS `ubicacionFin`,
       `sistemagestionflotillas`.`ruta`.`estado`          AS `estado`
from `sistemagestionflotillas`.`ruta`
where ((`sistemagestionflotillas`.`ruta`.`estado` = 'Pendiente') and
       (`sistemagestionflotillas`.`ruta`.`distancia` > 50));

create or replace view fragmento_vehiculos_activos_verificados as
select `sistemagestionflotillas`.`vehiculo`.`vehiculoId`        AS `vehiculoId`,
       `sistemagestionflotillas`.`vehiculo`.`flotillaId`        AS `flotillaId`,
       `sistemagestionflotillas`.`vehiculo`.`tipo`              AS `tipo`,
       `sistemagestionflotillas`.`vehiculo`.`modelo`            AS `modelo`,
       `sistemagestionflotillas`.`vehiculo`.`marca`             AS `marca`,
       `sistemagestionflotillas`.`vehiculo`.`anio`              AS `anio`,
       `sistemagestionflotillas`.`vehiculo`.`estado`            AS `estado`,
       `sistemagestionflotillas`.`vehiculo`.`fechaVerificacion` AS `fechaVerificacion`
from `sistemagestionflotillas`.`vehiculo`
where ((`sistemagestionflotillas`.`vehiculo`.`estado` = 'Activo') and
       (`sistemagestionflotillas`.`vehiculo`.`fechaVerificacion` >= (curdate() - interval 1 year)));

create or replace view fragmento_vehiculos_mantenimientos as
select `v`.`vehiculoId`      AS `vehiculoId`,
       `v`.`tipo`            AS `tipo`,
       `v`.`modelo`          AS `modelo`,
       `v`.`marca`           AS `marca`,
       `m`.`mantenimientoId` AS `mantenimientoId`,
       `m`.`fechaServicio`   AS `fechaServicio`,
       `m`.`tipoServicio`    AS `tipoServicio`,
       `m`.`costo`           AS `costo`,
       `m`.`estado`          AS `estado`
from (`sistemagestionflotillas`.`vehiculo` `v` join `sistemagestionflotillas`.`mantenimiento` `m`
      on ((`v`.`vehiculoId` = `m`.`vehiculoId`)));

create or replace view fragmento_vehiculos_mantenimientos_costosos as
select `v`.`vehiculoId`      AS `vehiculoId`,
       `v`.`tipo`            AS `tipo`,
       `v`.`modelo`          AS `modelo`,
       `m`.`mantenimientoId` AS `mantenimientoId`,
       `m`.`fechaServicio`   AS `fechaServicio`,
       `m`.`tipoServicio`    AS `tipoServicio`,
       `m`.`costo`           AS `costo`
from (`sistemagestionflotillas`.`vehiculo` `v` join `sistemagestionflotillas`.`mantenimiento` `m`
      on ((`v`.`vehiculoId` = `m`.`vehiculoId`)))
where ((`m`.`fechaServicio` >= (curdate() - interval 2 year)) and (`m`.`costo` > 1000));

