# Historial de Bloqueo de Domicilios

## Descripcion General

### Que hace este modulo
El modulo de Historial de Bloqueo de Domicilios permite consultar el registro historico de todos los domicilios que han sido bloqueados en el sistema. Mantiene un log completo de bloqueos, con informacion sobre quien los registro, cuando se hicieron, que modificaciones tuvieron y el motivo de cada movimiento.

### Para que sirve en el proceso administrativo
Este modulo sirve para:
- Consultar historial completo de bloqueos de domicilios
- Auditar cambios y movimientos en bloqueos
- Rastrear quien registro o modifico bloqueos
- Identificar patrones de bloqueos por calle o zona
- Generar reportes historicos para auditoria
- Exportar datos historicos a Excel para analisis
- Consultar motivos de bloqueos pasados
- Verificar cumplimiento de procedimientos

### Quienes lo utilizan
- Auditores internos que revisan movimientos
- Supervisores que verifican acciones de personal
- Personal de sistemas para analisis de datos
- Direccion para reportes ejecutivos
- Personal juridico para verificar antecedentes
- Inspectores que investigan historial de domicilios

## Proceso Administrativo

### Como funciona el proceso paso a paso

**Consulta del Historial:**

1. **Apertura del Modulo:**
   - Al abrir se carga automaticamente el historial completo
   - Se ordenan por defecto por calle y numero exterior

2. **Opciones de Ordenamiento:**
   Usuario puede elegir como ordenar los datos:
   - Por Calle y Numero: Agrupacion geografica
   - Por Fecha descendente: Movimientos mas recientes primero
   - Por Capturista: Quien registro el bloqueo
   - Por Usuario que Modifico: Quien hizo cambios

3. **Visualizacion de Informacion:**
   El sistema muestra para cada registro:
   - Domicilio completo (calle, numero, colonia)
   - Folio del bloqueo
   - Fecha y hora del registro
   - Vigencia del bloqueo
   - Observaciones originales
   - Capturista que lo registro
   - Fecha y motivo del movimiento (si hay)
   - Tipo de movimiento
   - Usuario que modifico
   - Procedencia del movimiento (calculado)

4. **Busqueda de Registros:**
   - Usuario puede hacer click en titulos de columnas
   - Sistema activa busqueda en esa columna
   - Permite localizar registros especificos rapidamente

5. **Interpretacion de Movimientos:**
   El sistema traduce codigos de movimiento:
   - "EL" = Eliminado al Desbloquear de Licencia
   - "ED" = Eliminado desde Bloqueo de Domicilios
   - "MD" = Modificado en bloqueo de Domicilio

**Generacion de Reportes:**

1. Usuario selecciona ordenamiento deseado
2. Selecciona un registro del listado
3. Presiona "Imprimir"
4. Sistema filtra todos los registros del mismo criterio:
   - Si ordenado por calle: todos de esa calle
   - Si ordenado por fecha: todos de esa fecha
   - Si ordenado por capturista: todos de ese capturista
   - Si ordenado por modifico: todos de ese usuario
5. Sistema genera reporte impreso con filtro aplicado

**Exportacion a Excel:**

1. Usuario presiona "Excel"
2. Sistema aplica mismo filtro que impresion
3. Abre dialogo de guardar archivo
4. Usuario elige nombre y ubicacion
5. Sistema exporta a formato Excel
6. Archivo queda disponible para analisis

### Que informacion requiere el usuario

**Datos de Entrada:**
- Ninguno requerido
- El historial se carga automaticamente
- Usuario solo selecciona forma de visualizacion

**Informacion que se Visualiza:**
- Cuenta catastral (cvecuenta)
- Clave de calle (cvecalle)
- Nombre de la calle
- Numero exterior
- Letra exterior
- Numero interior
- Letra interior
- Folio del bloqueo
- Fecha del bloqueo
- Hora del bloqueo
- Vigencia (V = Vigente, otra = No vigente)
- Observacion del bloqueo
- Capturista que registro
- Fecha de movimiento (si hay)
- Motivo del movimiento
- Tipo de movimiento (EL, ED, MD)
- Usuario que modifico
- Procedencia del movimiento (descripcion amigable)

### Que validaciones se realizan

1. **Traduccion de Tipos de Movimiento:**
   - Sistema convierte codigos tecnicos a texto descriptivo
   - Se calcula en tiempo real al visualizar
   - Campo calculado "procedenciamov"

2. **Ordenamiento Inteligente:**
   - Cada opcion de ordenamiento tiene query especifico
   - Garantiza visualizacion logica de datos

3. **Filtrado Contextual:**
   - Impresion y exportacion filtran segun registro seleccionado
   - Evita generar reportes masivos sin criterio

4. **Busqueda en Grid:**
   - Componente DBGridSearch permite buscar en columna
   - Busqueda dinamica conforme usuario escribe

### Que documentos genera

1. **Reporte Impreso:**
   - Formato oficial con logo
   - Listado de bloqueos filtrado segun criterio
   - Incluye todos los campos del historial
   - Agrupado segun ordenamiento seleccionado
   - Fecha de emision
   - Paginacion automatica

2. **Archivo Excel:**
   - Exportacion completa de registros filtrados
   - Formato tabular para analisis
   - Todas las columnas del historial
   - Listo para graficas y tablas dinamicas
   - Compatible con herramientas de BI

## Tablas de Base de Datos

### Tabla Principal
- **h_bloqueo_dom (historial de bloqueo de domicilios):** Tabla historica que almacena TODOS los movimientos de bloqueos, incluyendo creacion, modificacion y eliminacion

### Tablas Relacionadas

**Tablas que Consulta:**
- **h_bloqueo_dom:** Unica tabla consultada
- **calles:** Para desplegar nombre de calle (via join implicito con cvecalle)

**Tablas que Modifica:**
- **Ninguna:** Modulo de solo lectura, no modifica historial

## Stored Procedures
- **Ninguno:** No ejecuta procedimientos, solo consultas SELECT

## Impacto y Repercusiones

### Que registros afecta
- **Ninguno:** Es un modulo de auditoria y consulta
- No modifica, no inserta, no elimina
- Solo lectura del historial

### Que cambios de estado provoca
- **Ninguno:** No provoca cambios en ningun sistema
- Es transparente a la operacion
- No afecta bloqueos activos

### Que documentos/reportes genera
- Reportes de auditoria de bloqueos
- Exportaciones para analisis externo
- Evidencia documental para casos especiales

### Que validaciones de negocio aplica

1. **Rastreabilidad Completa:**
   - Cada registro historico mantiene:
     - Quien lo creo
     - Cuando se creo
     - Quien lo modifico
     - Cuando se modifico
     - Por que se modifico

2. **Integridad del Historial:**
   - Los registros nunca se eliminan de h_bloqueo_dom
   - Queda evidencia permanente de todos los movimientos

3. **Traduccion de Codigos:**
   - Convierte codigos tecnicos a lenguaje comprensible
   - Facilita interpretacion por personal no tecnico

## Flujo de Trabajo

### Descripcion del flujo completo del proceso

**Caso de Uso: Auditoria de Bloqueos por Capturista**

```
1. PREPARACION:
   a. Auditor recibe instruccion de verificar trabajo de capturista
   b. Abre modulo de Historial de Bloqueo de Domicilios

2. CONFIGURACION DE VISTA:
   c. Selecciona RadioButton "Capturista, Fecha desc"
   d. Sistema reordena datos por capturista y fecha

3. BUSQUEDA:
   e. Hace click en titulo de columna "Capturista"
   f. DBGridSearch se activa
   g. Escribe nombre del capturista a auditar
   h. Sistema filtra y posiciona en primer registro

4. REVISION:
   i. Revisa observaciones registradas
   j. Verifica fechas y horarios de captura
   k. Identifica patrones o irregularidades
   l. Nota folios de interes

5. GENERACION DE REPORTE:
   m. Selecciona un registro del capturista
   n. Presiona "Imprimir"
   o. Sistema genera reporte con TODOS los bloqueos de ese capturista
   p. Imprime para expediente de auditoria

6. ANALISIS DETALLADO:
   q. Presiona "Excel"
   r. Guarda archivo con nombre descriptivo
   s. Abre en Excel
   t. Genera graficas de bloqueos por fecha
   u. Analiza distribucion geografica
   v. Prepara informe de auditoria
```

**Caso de Uso: Investigacion de Domicilio Especifico**

```
1. SOLICITUD:
   a. Area juridica solicita historial de bloqueos en domicilio
   b. Usuario abre modulo

2. BUSQUEDA POR CALLE:
   c. Selecciona ordenamiento "Calle, Numero"
   d. Click en titulo "Calle"
   e. Escribe nombre de la calle
   f. Localiza domicilio especifico

3. REVISION DE HISTORIAL:
   g. Observa todos los bloqueos en ese domicilio
   h. Revisa fechas y motivos
   i. Identifica quien realizo cada bloqueo
   j. Verifica movimientos (modificaciones, eliminaciones)

4. DOCUMENTACION:
   k. Genera reporte de todos los bloqueos de esa calle
   l. O exporta a Excel si requiere analisis detallado
   m. Entrega documentacion a area juridica
```

## Notas Importantes

### Consideraciones especiales

1. **Naturaleza del Historial:**
   - Esta tabla es append-only (solo agregar)
   - Nunca se eliminan registros
   - Proporciona pista de auditoria completa

2. **Diferencia con Modulo de Bloqueos Activos:**
   - Modulo de bloqueos activos: operacion en vivo
   - Este modulo: consulta historica y auditoria
   - Ambos son complementarios

3. **Campos Calculados:**
   - "procedenciamov" se calcula en tiempo real
   - No esta almacenado en BD
   - Se genera para facilitar comprension

4. **Multiples Vistas del Mismo Dato:**
   - Ordenamientos diferentes revelan diferentes perspectivas
   - Mismo dato, diferentes insights
   - Usuario elige vista segun necesidad

5. **Filtrado Inteligente en Reportes:**
   - Sistema deduce intencion del usuario
   - Filtra automaticamente segun contexto
   - Evita reportes innecesariamente grandes

### Restricciones

1. **Solo Lectura:**
   - No permite modificar historial
   - No permite eliminar registros
   - Protege integridad de auditoria

2. **Sin Filtros Personalizados:**
   - Filtros estan predefinidos
   - No permite rangos de fechas custom
   - Usuario debe usar ordenamiento y busqueda

3. **Reporte de Grupo Completo:**
   - No permite seleccionar registros individuales para reporte
   - Imprime/exporta grupo completo segun filtro

### Permisos necesarios

- **Consulta del Historial:** Lectura en h_bloqueo_dom
- **Consulta de Calles:** Lectura en tabla de calles
- **Generacion de Reportes:** Acceso a motor de reportes
- **Exportacion a Excel:** Permisos de escritura en sistema de archivos

### Interpretacion de Movimientos

**Tipo "EL" - Eliminado al Desbloquear de Licencia:**
- El bloqueo se levanto desde el modulo de licencias
- Ocurre cuando se desbloquea una licencia
- Indica proceso normal de desbloqueo

**Tipo "ED" - Eliminado desde Bloqueo de Domicilios:**
- El bloqueo se elimino directamente en modulo de bloqueos
- Decision administrativa explicita
- Requiere justificacion en observaciones

**Tipo "MD" - Modificado en bloqueo de Domicilio:**
- Los datos del bloqueo se modificaron
- Puede ser cambio de vigencia, observaciones, etc.
- Usuario que modifico queda registrado

### Importancia para el Sistema

1. **Auditoria:** Evidencia de todas las acciones
2. **Transparencia:** Cualquier movimiento es rastreable
3. **Responsabilidad:** Identifica autores de acciones
4. **Legalidad:** Respaldo documental para casos juridicos
5. **Control:** Supervisa operacion del sistema
