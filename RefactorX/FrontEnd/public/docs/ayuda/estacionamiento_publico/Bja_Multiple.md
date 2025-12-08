# Bja_Multiple - Sistema de Estacionamientos

## Proposito Administrativo

Procesar bajas masivas de folios mediante carga de archivos, permitiendo cancelar multiples infracciones en una sola operacion. Util para cancelaciones por revision administrativa o errores de captura masivos.

## Funcionalidad Principal

Importar archivo Excel con listado de folios a dar de baja, validar datos, cargar a tabla temporal, ejecutar procedimiento de baja masiva y generar reporte de incidencias.

## Proceso de Negocio

### Que hace
- Carga archivo Excel con folios a cancelar
- Muestra datos en hoja de calculo para revision
- Graba registros en tabla temporal
- Ejecuta procedimiento almacenado que procesa bajas
- Genera reporte de incidencias (errores, validaciones fallidas)
- Imprime listado de folios no procesados

### Para que
- Agilizar cancelaciones masivas de folios por errores administrativos
- Procesar lotes de folios invalidados por resolucion judicial
- Aplicar bajas por condonaciones masivas
- Corregir errores de captura en bloque

### Como funciona
1. Usuario genera archivo Excel con columnas: PLACA, FOLIO, FECHA, ANOMALIA, TARIFA, REFERENCIA
2. Abre modulo y selecciona archivo
3. Sistema carga datos a componente cxSpreadSheet
4. Usuario revisa datos cargados
5. Presiona grabar: sistema inserta registros en tabla temporal con nombre de archivo
6. Presiona aplicar: ejecuta procedimiento almacenado sp14_ejecuta_sp
7. Procedimiento procesa cada folio: valida y da de baja
8. Sistema genera reporte de incidencias con folios rechazados
9. Usuario imprime reporte para revision

### Que necesita
- Archivo Excel (.xls/.xlsx) con estructura definida
- Campos requeridos: placa, folio, fecha_archivo, anomalia, referencia
- Procedimiento sp14_ejecuta_sp configurado en base de datos
- Permisos para insertar en tablas temporales
- Tabla de incidencias para registrar errores

## Datos y Tablas

### Tablas afectadas
- **Tabla temporal de carga**: almacena folios del archivo antes de procesar
- **ta14_folios_adeudo**: se eliminan o marcan folios
- **ta14_incidencias**: registra folios rechazados con motivo

### Estructura del archivo Excel
- **Columna 1 - PLACA**: placa del vehiculo (texto)
- **Columna 2 - FOLIO**: numero de folio (entero)
- **Columna 3 - FECHA**: fecha del archivo (fecha)
- **Columna 4 - ANOMALIA**: motivo de baja (texto)
- **Columna 5 - TARIFA**: monto (decimal)
- **Columna 6 - REFERENCIA**: numero de referencia del archivo (entero)

### Datos clave
- Nombre del archivo procesado
- Cantidad de registros cargados
- Folios procesados exitosamente
- Folios con error y motivo

## Impacto y Repercusiones

### Impacto operativo
- ALTO: Permite cancelar cientos de folios en minutos
- Reduce tiempo vs cancelacion individual
- Requiere validacion previa del archivo

### Repercusiones
- Error en archivo puede cancelar folios incorrectos (CRITICO)
- No hay confirmacion individual por folio
- Proceso es irreversible una vez ejecutado el procedimiento
- Errores en validacion dejan folios sin procesar
- Reporte de incidencias es crucial para corregir

## Validaciones

1. Archivo Excel tiene estructura correcta (6 columnas)
2. Datos numericos son validos (folio, referencia, tarifa)
3. Fecha en formato correcto
4. Placa y folio existen en sistema
5. Folio esta en estado que permite baja
6. No hay registros duplicados en archivo

## Casos de Uso

### Caso 1: Baja por error administrativo
1. Se detecta que 500 folios se capturaron con tarifa incorrecta
2. Administrador genera Excel con listado
3. Indica anomalia: "Tarifa incorrecta, recapturar"
4. Carga archivo en sistema
5. Revisa datos en pantalla
6. Ejecuta grabacion y aplicacion
7. Sistema procesa 498 exitosos, 2 con error
8. Imprime incidencias: 2 folios ya estaban pagados
9. Manualmente verifica esos 2 folios

### Caso 2: Condonacion masiva
1. Gobierno autoriza condonacion a 1000 vehiculos
2. Area juridica entrega listado oficial
3. Operador transcribe a Excel
4. Anomalia: "Condonacion decreto 123/2024"
5. Carga y procesa
6. Todos exitosos
7. Guarda reporte vacio (sin incidencias) como evidencia

### Caso 3: Error en archivo
1. Usuario carga archivo con formato incorrecto
2. Columna FOLIO tiene texto en vez de numeros
3. Sistema intenta grabar primer registro
4. Falla conversion a entero
5. Muestra error, no graba nada
6. Usuario corrige archivo y recarga

## Usuarios del Modulo

- Supervisores administrativos: autorizan y ejecutan bajas masivas
- Personal de sistemas: valida estructura de archivos
- Auditores: revisan reportes de incidencias
- Area juridica: solicita bajas por resoluciones

## Relaciones con Otros Modulos

- DsDBGasto: conexion a base de datos
- sp14_ejecuta_sp: procedimiento almacenado que ejecuta la baja
- cxSpreadSheet: componente para mostrar datos tipo Excel
- ppRepIncidencias: reporte de folios no procesados
- QryIncidencias: consulta folios con error

## Notas Importantes

- Archivo debe tener encabezados en primera fila
- Sistema NO valida si folios ya fueron dados de baja previamente
- Cada ejecucion debe usar nombre de archivo unico para rastreo
- Reporte de incidencias muestra: placa, folio, fecha, anomalia, referencia
- NO hay opcion de deshacer, proceso es definitivo
- Referencia es numero secuencial del lote de bajas
- Anomalia es texto libre, usar nomenclatura estandar
- Procedimiento sp14_ejecuta_sp debe manejar validaciones de negocio
- Sistema usa transacciones: si falla un folio continua con siguiente
- Al cerrar sin generar archivo .txt, se borran datos cargados
