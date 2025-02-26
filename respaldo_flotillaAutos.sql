create table if not exists conductor
(
    idConductor int         not null
        primary key,
    nombre      varchar(80) not null,
    apellido    varchar(80) not null
);

create table if not exists mecanico
(
    idMecanico   int         not null
        primary key,
    nombre       varchar(80) not null,
    especialidad varchar(80) not null,
    telefono     varchar(80) not null
);

create table if not exists vehiculo
(
    idVehiculo  int         not null
        primary key,
    marca       varchar(80) not null,
    modelo      varchar(80) not null,
    anio        int         not null,
    color       varchar(80) not null,
    idConductor int         null,
    constraint vehiculo_ibfk_2
        foreign key (idConductor) references conductor (idConductor)
);

create table if not exists detalle_combustible
(
    idDetalleCombustible int   not null
        primary key,
    fechaCarga           date  not null,
    cantidadLitros       float not null,
    precioPorLitro       float not null,
    totalCosto           float not null,
    idVehiculo           int   not null,
    constraint detalle_combustible_ibfk_1
        foreign key (idVehiculo) references vehiculo (idVehiculo)
);

create index idVehiculo
    on detalle_combustible (idVehiculo);

create trigger CalcularTotalCombustible
    before insert
    on detalle_combustible
    for each row
begin
    BEGIN
    SET NEW.totalCosto = NEW.cantidadLitros * NEW.precioPorLitro;
END
    end;

create table if not exists documentos
(
    idDocumento     int         not null
        primary key,
    tipo            varchar(80) not null,
    fechaEmision    date        not null,
    fechaExpiracion date        not null,
    idVehiculo      int         not null,
    constraint documentos_ibfk_1
        foreign key (idVehiculo) references vehiculo (idVehiculo)
);

create index idVehiculo
    on documentos (idVehiculo);

create table if not exists mantenimiento
(
    idMantenimiento int          not null
        primary key,
    fecha           date         not null,
    tipo            varchar(80)  not null,
    costo           float        not null,
    descripcion     varchar(255) not null,
    idMecanico      int          not null,
    idVehiculo      int          not null,
    constraint mantenimiento_ibfk_1
        foreign key (idMecanico) references mecanico (idMecanico),
    constraint mantenimiento_ibfk_2
        foreign key (idVehiculo) references vehiculo (idVehiculo)
);

create index idMecanico
    on mantenimiento (idMecanico);

create index idVehiculo
    on mantenimiento (idVehiculo);

create table if not exists registrolaboral
(
    idTrabajo     int auto_increment
        primary key,
    idConductor   int         not null,
    fechaTrabajo  date        not null,
    horaEntrada   time        not null,
    horaSalida    time        not null,
    tipoTrabajo   varchar(80) not null,
    idVehiculo    int         null,
    observaciones text        null,
    constraint registrolaboral_ibfk_1
        foreign key (idConductor) references conductor (idConductor),
    constraint registrolaboral_ibfk_2
        foreign key (idVehiculo) references vehiculo (idVehiculo)
)
    auto_increment = 6;

create index idConductor
    on registrolaboral (idConductor);

create index idVehiculo
    on registrolaboral (idVehiculo);

create trigger ValidarHorasTrabajo
    before insert
    on registrolaboral
    for each row
begin
    BEGIN
    IF NEW.horaSalida <= NEW.horaEntrada THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La hora de salida debe ser mayor que la hora de entrada';
    END IF;
END
    end;

create index idConductor
    on vehiculo (idConductor);

create function CalcularCostoTotalCombustible(p_idVehiculo int) returns float
    deterministic
BEGIN
    DECLARE total FLOAT;
    SELECT SUM(totalCosto) INTO total
    FROM detalle_combustible
    WHERE idVehiculo = p_idVehiculo;
    RETURN COALESCE(total, 0);
END;

create procedure ConductoresFrecuentes()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE conductor_id INT;
    DECLARE cur CURSOR FOR
        SELECT idConductor FROM RegistroLaboral
        GROUP BY idConductor
        HAVING COUNT(*) > 3;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO conductor_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT * FROM Conductor WHERE idConductor = conductor_id;
    END LOOP;

    CLOSE cur;
END;

create function ContarMantenimientos(p_idVehiculo int) returns int
    deterministic
BEGIN
    DECLARE cantidad INT;
    SELECT COUNT(*) INTO cantidad
    FROM Mantenimiento
    WHERE idVehiculo = p_idVehiculo;
    RETURN cantidad;
END;

create procedure InsertarConductor(IN p_idConductor int, IN p_nombre varchar(80), IN p_apellido varchar(80))
BEGIN
        INSERT INTO Conductor (idConductor, nombre, apellido)
        VALUES (p_idConductor, p_nombre, p_apellido);
    END;

create procedure ObtenerRegistroLaboral(IN p_idConductor int, IN p_fecha date)
BEGIN
    SELECT * FROM RegistroLaboral
    WHERE idConductor = p_idConductor AND fechaTrabajo = p_fecha;
END;

create procedure VerificarConductorAsignado(IN p_idVehiculo int)
BEGIN
    DECLARE conductorAsignado INT;

    SELECT idConductor INTO conductorAsignado
    FROM Vehiculo
    WHERE idVehiculo = p_idVehiculo;

    IF conductorAsignado IS NOT NULL THEN
        SELECT 'El vehículo tiene un conductor asignado' AS Mensaje;
    ELSE
        SELECT 'El vehículo NO tiene un conductor asignado' AS Mensaje;
    END IF;
END;

