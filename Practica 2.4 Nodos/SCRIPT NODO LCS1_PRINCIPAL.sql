create table if not exists flotilla
(
    flotillaId     int auto_increment
        primary key,
    nombreEmpresa  varchar(100) not null,
    gestorFlotilla varchar(100) null,
    fechaCreacion  date         null
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
    fechaVerificacion date                         null,
    constraint vehiculo_ibfk_1
        foreign key (flotillaId) references flotilla (flotillaId)
            on delete cascade
)
    auto_increment = 127;

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
    auto_increment = 127;

create trigger after_delete_vehiculo
    after delete
    on vehiculo
    for each row
begin
    BEGIN
    -- Eliminar en el nodo mantenimiento
    DELETE FROM lcs2_mantenimiento.vehiculo
    WHERE vehiculoId = OLD.vehiculoId;

    DELETE FROM lcs3_rutas.vehiculo
    WHERE vehiculoId = OLD.vehiculoId;
END
    end;

create trigger after_insert_vehiculo
    after insert
    on vehiculo
    for each row
begin
    BEGIN
    INSERT INTO lcs2_mantenimiento.vehiculo (vehiculoId, flotillaId, tipo, modelo, marca, anio, estado, fechaVerificacion)
    VALUES (NEW.vehiculoId, NEW.flotillaId, NEW.tipo, NEW.modelo, NEW.marca, NEW.anio, NEW.estado, NEW.fechaVerificacion);

    INSERT INTO lcs3_rutas.vehiculo (vehiculoId, flotillaId, tipo, modelo, marca, anio, estado, fechaVerificacion)
    VALUES (NEW.vehiculoId, NEW.flotillaId, NEW.tipo, NEW.modelo, NEW.marca, NEW.anio, NEW.estado, NEW.fechaVerificacion);
END
    end;

create trigger after_update_vehiculo
    after update
    on vehiculo
    for each row
begin
    BEGIN
    -- Actualizar o insertar en el nodo mantenimiento
    INSERT INTO lcs2_mantenimiento.vehiculo (vehiculoId, flotillaId, tipo, modelo, marca, anio, estado, fechaVerificacion)
    VALUES (NEW.vehiculoId, NEW.flotillaId, NEW.tipo, NEW.modelo, NEW.marca, NEW.anio, NEW.estado, NEW.fechaVerificacion)
    ON DUPLICATE KEY UPDATE
        flotillaId = NEW.flotillaId,
        tipo = NEW.tipo,
        modelo = NEW.modelo,
        marca = NEW.marca,
        anio = NEW.anio,
        estado = NEW.estado,
        fechaVerificacion = NEW.fechaVerificacion;

    -- Actualizar o insertar en el nodo rutas
    INSERT INTO lcs3_rutas.vehiculo (vehiculoId, flotillaId, tipo, modelo, marca, anio, estado, fechaVerificacion)
    VALUES (NEW.vehiculoId, NEW.flotillaId, NEW.tipo, NEW.modelo, NEW.marca, NEW.anio, NEW.estado, NEW.fechaVerificacion)
    ON DUPLICATE KEY UPDATE
        flotillaId = NEW.flotillaId,
        tipo = NEW.tipo,
        modelo = NEW.modelo,
        marca = NEW.marca,
        anio = NEW.anio,
        estado = NEW.estado,
        fechaVerificacion = NEW.fechaVerificacion;
END
    end;

create trigger before_delete_vehiculo
    before delete
    on vehiculo
    for each row
begin
    BEGIN
    -- Eliminar registros dependientes en el nodo de mantenimiento
    DELETE FROM lcs2_mantenimiento.mantenimiento
    WHERE vehiculoId = OLD.vehiculoId;

    -- Eliminar registros dependientes en el nodo de rutas
    DELETE FROM lcs3_rutas.ruta
    WHERE vehiculoId = OLD.vehiculoId;

    DELETE FROM lcs3_rutas.transaccionCombustible
    WHERE vehiculoId = OLD.vehiculoId;

    -- Eliminar el vehículo en los otros nodos
    DELETE FROM lcs2_mantenimiento.vehiculo
    WHERE vehiculoId = OLD.vehiculoId;

    DELETE FROM lcs3_rutas.vehiculo
    WHERE vehiculoId = OLD.vehiculoId;
END
    end;

create procedure ObtenerVehiculosConUltimoMantenimiento()
BEGIN
    SELECT
        v.vehiculoId AS id_vehiculo,
        v.marca,
        v.modelo,
        v.anio,
        v.estado,
        m.fechaServicio AS ultimo_mantenimiento,
        m.tipoServicio AS tipo_mantenimiento,
        m.costo AS costo_mantenimiento
    FROM
        lcs1_principal.vehiculo v
    LEFT JOIN
        lcs2_mantenimiento.mantenimiento m ON v.vehiculoId = m.vehiculoId
    WHERE
        m.fechaServicio = (
            SELECT MAX(fechaServicio)
            FROM lcs2_mantenimiento.mantenimiento
            WHERE vehiculoId = v.vehiculoId
        )
    ORDER BY
        v.vehiculoId;
END;