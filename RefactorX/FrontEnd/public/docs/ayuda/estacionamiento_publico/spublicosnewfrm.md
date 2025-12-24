# Módulo de Alta de Nuevos Estacionamientos Públicos

## Información General

**Archivo:** spublicosnewfrm.pas
**Módulo:** Estacionamientos Públicos - Altas
**Propósito:** Registro de nuevos estacionamientos públicos en el padrón municipal

---

## ¿Qué hace este módulo?

Este módulo permite dar de **alta nuevos estacionamientos públicos** en el padrón del municipio. Es la puerta de entrada para registrar establecimientos que solicitan autorización para operar como estacionamiento público, vinculándolos con sus cuentas prediales y propietarios.

---

## ¿Para qué sirve?

### Funciones Principales

1. **Registro de Nuevos Estacionamientos**
   - Captura datos completos del establecimiento
   - Asigna número de estacionamiento consecutivo
   - Vincula con cuenta predial municipal
   - Asocia con propietario (RFC)

2. **Generación Automática de Adeudo Inicial**
   - Crea adeudo por concepto de solicitud/forma
   - Calcula costo según categoría asignada
   - Genera primer registro en el padrón de adeudos

3. **Impresión de Estado de Cuenta Inicial**
   - Genera estado de cuenta al momento del alta
   - Incluye adeudo por solicitud
   - Documento para entrega al contribuyente

4. **Validación de Datos Catastrales**
   - Verifica cuenta predial válida y activa
   - Consulta datos del predio en tiempo real
   - Obtiene ubicación y datos técnicos del predio

5. **Búsqueda de Propietarios**
   - Localiza propietarios por RFC
   - Permite búsqueda con caracteres comodín
   - Vincula persona física/moral con el estacionamiento

6. **Visualización Cartográfica**
   - Muestra ubicación del predio en mapa digital
   - Integración con visor cartográfico municipal
   - Verifica ubicación geográfica del establecimiento

---

## ¿Cómo funciona?

### Flujo Operativo Completo

```
1. INICIALIZACIÓN DEL FORMULARIO
   ↓
   - Sistema obtiene último número de estacionamiento
   - Propone número consecutivo automático
   - Carga catálogo de categorías
   - Limpia campos para nueva captura
   ↓
2. BÚSQUEDA DE PROPIETARIO
   ↓
   Usuario:
   - Captura mínimo 4 caracteres del RFC
   - Hace doble clic en campo RFC
   ↓
   Sistema:
   - Busca coincidencias en tabla de personas
   - Muestra listado de resultados
   - Permite selección del propietario correcto
   ↓
3. VALIDACIÓN DE CUENTA PREDIAL
   ↓
   Usuario:
   - Captura número de cuenta predial
   - Presiona botón de validación
   ↓
   Sistema:
   - Consulta datos del predio (SP)
   - Verifica que esté activo
   - Obtiene sector, zona, subzona
   - Carga datos de ubicación
   - Valida estatus del predio
   ↓
4. VISUALIZACIÓN DE UBICACIÓN (Opcional)
   ↓
   Usuario:
   - Presiona botón "Ver en Mapa"
   ↓
   Sistema:
   - Abre visor cartográfico
   - Muestra predio en mapa digital
   - Permite verificar ubicación física
   ↓
5. CAPTURA DE DATOS DEL ESTACIONAMIENTO
   ↓
   Usuario captura:
   - Categoría del estacionamiento
   - Número de cajones (cupo)
   - Calle y número exterior
   - Teléfono de contacto
   - Número de licencia (si aplica)
   - Número de solicitud
   - Número de control
   - Fecha de autorización
   - Fecha inicial de operación
   - Fecha de vencimiento
   ↓
6. VALIDACIONES PREVIAS AL ALTA
   ↓
   Sistema valida:
   ✓ Existe propietario seleccionado (RFC)
   ✓ Cuenta predial válida y mensaje = 'OK'
   ✓ Categoría asignada
   ✓ Número de cajones capturado
   ✓ Fechas válidas
   ↓
7. CONSULTA DE COSTO DE FORMA
   ↓
   - Obtiene costo de solicitud
   - Según tarifa vigente
   ↓
8. REGISTRO EN BASE DE DATOS
   ↓
   Sistema ejecuta:
   - INSERT en tabla principal (pubmain_esta)
   - Genera ID único del estacionamiento
   - Retorna número de ID generado
   ↓
9. GENERACIÓN DE ADEUDO INICIAL
   ↓
   - INSERT en tabla de adeudos (pubadeudos)
   - Concepto: "Solicitud: [número]"
   - Importe: Costo de forma
   - Año/Mes: Fecha de alta
   - Vincula con ID del estacionamiento
   ↓
10. IMPRESIÓN DE ESTADO DE CUENTA
   ↓
   - Genera reporte con datos completos
   - Incluye adeudo inicial
   - Imprime automáticamente
   ↓
11. PREPARACIÓN PARA SIGUIENTE ALTA
   ↓
   - Incrementa número de estacionamiento
   - Limpia campos del formulario
   - Cierra búsqueda de propietario
   - Retorna foco a primer campo
```

### Validaciones del Sistema

#### Validación de RFC (Propietario)

```pascal
// Mínimo 4 caracteres
if Length(mxflatedit2.Text) > 3 then
   // Busca en tabla con LIKE 'RFC%'
else
   ShowMessage('Minimo 4 caracteres para realizar la Busqueda')
```

#### Validación de Cuenta Predial

```pascal
// Consulta procedimiento almacenado
sp_conspredio(opc:=2, dato:=cvecuenta)

// Valida respuesta
if sp_consprediomensaje.Value <> 'OK' then
   Error: 'Cuenta predial asignada incorrectamente'

if sp_consprediostatus.Value > 0 then
   Error: 'Cuenta Predial Incorrecta o Cancelada'
```

#### Validaciones Antes de Guardar

```pascal
// 1. Propietario
if QryPersonaRFCrfc.isnull = true then
   Error: 'No tiene el Propietario'

// 2. Cuenta Predial
if sp_consprediomensaje.Value <> 'OK' then
   Error: 'No tiene la cuenta predial asignada correctamente'

// 3. Categoría
if sDBLookupComboBox1.KeyValue = null then
   Error: 'No tiene asignada la categoria'

// 4. Cajones
if trim(mxFlatFloatEdit4.text) = '' then
   Error: 'No tiene asignada los cajones'
```

---

## ¿Qué necesita para funcionar?

### Datos de Entrada Obligatorios

#### 1. Datos del Propietario
- **RFC:** Registro Federal de Contribuyentes
- **Nombre:** Se obtiene automáticamente de la tabla de personas

#### 2. Datos del Predio
- **Cuenta Predial:** Número de cuenta catastral (cve_cuenta)
- El sistema obtiene automáticamente:
  - Sector (J=Juárez, R=Reforma, L=Libertad, H=Hidalgo)
  - Zona
  - Subzona
  - Calle
  - Número exterior
  - Clave catastral

#### 3. Datos del Estacionamiento
- **Número de Estacionamiento:** Generado automáticamente (consecutivo)
- **Categoría:** Selección del catálogo
  - Determina tipo de establecimiento
  - Define costos aplicables
- **Número de Cajones (Cupo):** Capacidad del estacionamiento
- **Teléfono:** Contacto del establecimiento
- **Calle y Número:** Ubicación física

#### 4. Datos Administrativos
- **Número de Solicitud:** Folio de trámite
- **Número de Control:** Folio de control interno
- **Número de Licencia:** Si ya tiene licencia asignada (opcional)
- **Año de Licencias:** Para control (opcional, default: 0)

#### 5. Fechas
- **Fecha de Autorización (fecha_at):** Cuándo se autorizó
- **Fecha Inicial (fecha_inicial):** Inicio de operaciones
- **Fecha de Vencimiento (fecha_vencimiento):** Vigencia

### Datos Automáticos del Sistema

- **Número de Estacionamiento:** Último + 1
- **Movimientos:** Inicializa en 1
- **Clave de Movimiento:** 'V' (Vigente)
- **Usuario:** ID del usuario conectado
- **ID único:** Generado por la base de datos (autoincremental)

### Permisos Requeridos

- Usuario autenticado en el sistema
- Permisos para módulo de Estacionamientos
- Permisos de alta/captura
- Acceso a recaudadora correspondiente

---

## ¿Qué tablas utiliza?

### Tablas Principales

#### 1. **`pubmain_esta`** - Tabla Maestra de Estacionamientos

**Campos que se insertan:**

```sql
INSERT INTO pubmain_esta (
    pubcategoria_id,    -- ID de categoría
    numesta,            -- Número de estacionamiento
    sector,             -- Sector catastral (J/R/L/H)
    zona,               -- Zona catastral
    subzona,            -- Subzona catastral
    numlicencia,        -- Número de licencia (opcional)
    axolicencias,       -- Año de licencia (default: 0)
    cvecuenta,          -- Cuenta predial
    nombre,             -- Nombre del propietario
    calle,              -- Calle
    numext,             -- Número exterior
    telefono,           -- Teléfono
    cupo,               -- Número de cajones
    fecha_at,           -- Fecha de autorización
    fecha_inicial,      -- Fecha inicial
    fecha_vencimiento,  -- Fecha de vencimiento
    rfc,                -- RFC del propietario
    solicitud,          -- Número de solicitud
    control,            -- Número de control
    movtos_no,          -- Contador de movimientos (1)
    movto_cve,          -- Clave de movimiento ('V')
    movto_usr           -- Usuario que registró
) VALUES (...)
```

#### 2. **`pubadeudos`** - Adeudos de Estacionamientos

**Registro inicial generado:**

```sql
INSERT INTO pubadeudos (
    pubmain_id,         -- ID del estacionamiento recién creado
    axo,                -- Año actual (de fecha_inicial)
    mes,                -- Mes actual (de fecha_inicial)
    concepto,           -- 'Solicitud: [número]'
    ade_importe,        -- Costo de forma
    ade_descto,         -- 0
    ade_recgos,         -- 0
    id_usuario          -- Usuario que registró
)
```

#### 3. **`pubcategorias`** - Catálogo de Categorías

**Campos consultados:**
- `id` - ID de categoría
- `tipo` - Tipo de categoría
- `categoria` - Nombre corto
- `descripcion` - Descripción completa

#### 4. **`personas_rfc`** o similar - Padrón de Personas

**Campos consultados:**
- `id_esta_persona` - ID único
- `rfc` - RFC de la persona
- `nombre` - Nombre completo

### Tablas de Consulta (No se modifican)

#### 5. **Tabla de Costos de Formas**

**Query:** `qry_costoforma`

```sql
SELECT costo_forma
FROM [tabla_costos]
WHERE [condiciones_vigencia]
```

Obtiene el costo actual de la forma/solicitud que se cobrará como primer adeudo.

#### 6. **Procedimiento de Consulta de Predio**

**SP:** `sp_conspredio`

**Parámetros:**
- `opc`: 2 (consulta por cuenta)
- `dato`: Número de cuenta predial

**Retorna:**
- `cvecuenta` - Cuenta predial
- `recaud` - ID recaudadora (1=Juárez, 2=Reforma, 3=Libertad, 4=Hidalgo)
- `tipo` - Tipo de predio
- `cuenta` - Número de cuenta
- `cvecatastral` - Clave catastral
- `subpredio` - Subpredio
- `contribuyente` - Nombre del contribuyente
- `calle` - Calle del predio
- `numext` - Número exterior
- `numint` - Número interior
- `zona` - Zona catastral
- `subzona` - Subzona catastral
- `status` - Estatus (0=OK, >0=Error)
- `mensaje` - Mensaje descriptivo

---

## ¿Qué procedimientos almacenados consume?

### 1. **`sp_conspredio`**

**Función:** Consulta información de un predio en el sistema catastral

**Parámetros de Entrada:**
- `@opc INT` - Opción: 2 = Consulta por cuenta predial
- `@dato VARCHAR` - Número de cuenta predial a consultar

**Retorna:** ResultSet con todos los datos del predio

**Uso en el Módulo:**

```pascal
sp_conspredio.Close;
sp_conspredio.ParamByName('opc').AsInteger := 2;
sp_conspredio.ParamByName('dato').AsString := mxFlatFloatEdit1.Text;
sp_conspredio.Open;

// Valida respuesta
if sp_consprediostatus.Value > 0 then
   ShowMessage('Cuenta Predial Incorrecta o Cancelada')
else
   // Procesa datos del predio
```

---

## ¿Qué tablas afecta?

### Modificaciones Directas

#### 1. **`pubmain_esta`** - INSERT

**Operación:** Alta de nuevo estacionamiento

**Datos insertados:**
- Todos los datos capturados del formulario
- Datos obtenidos del predio (sector, zona, subzona)
- Datos del propietario (RFC, nombre)
- Datos administrativos (fechas, folios)
- Datos de control (usuario, movimientos, clave)

**Retorna:**
- `result` - 0=Éxito, otro=Error
- `resultstr` - Mensaje descriptivo
- `idnvo` - ID del nuevo registro (clave primaria generada)

#### 2. **`pubadeudos`** - INSERT

**Operación:** Generación de primer adeudo

**Datos insertados:**

```pascal
QryAltaForma.ParamByName('pubmain_id').AsInteger := Query1idnvo.Value;
QryAltaForma.ParamByName('axo').AsString := FormatDateTime('yyyy', sDateEdit1.Date);
QryAltaForma.ParamByName('mes').AsString := FormatDateTime('mm', sDateEdit1.Date);
QryAltaForma.ParamByName('concepto').AsString := 'Solicitud : ' + mxFlatFloatEdit6.Text;
QryAltaForma.ParamByName('ade_importe').AsInteger := qry_costoformacosto_forma.AsInteger;
QryAltaForma.ParamByName('id_usuario').AsInteger := undatos.id_usuario;
QryAltaForma.ExecSQL;
```

**Efecto:**
- Se crea adeudo inicial por costo de forma
- Vinculado al estacionamiento recién creado
- Año y mes de la fecha de alta
- Concepto descriptivo con número de solicitud

---

## Repercusiones en el Sistema

### Impacto Administrativo

#### 1. **Padrón de Estacionamientos**
- **Incrementa:** El padrón activo crece en una unidad
- **Consecutivo:** Número de estacionamiento se incrementa
- **Control:** Se inicia historial de movimientos del establecimiento

#### 2. **Recaudación**
- **Genera Adeudo Inicial:** Por costo de forma/solicitud
- **Crea Base Imponible:** Para futuros cobros periódicos
- **Activa Facturación:** El establecimiento entra al ciclo de facturación

#### 3. **Vínculo Catastral**
- **Enlaza Predio:** Establece relación con cuenta predial
- **Ubicación Geográfica:** Registra ubicación física
- **Validación:** Verifica que predio esté activo

#### 4. **Registro de Propietarios**
- **Identifica Responsable:** Vincula RFC con establecimiento
- **Base de Notificaciones:** Para futuros avisos y requerimientos

### Impacto Operativo

#### Después del Alta

1. **Estado de Cuenta:**
   - Se imprime automáticamente
   - Contiene adeudo inicial
   - Documento oficial para el contribuyente

2. **Seguimiento:**
   - El establecimiento entra al padrón de cobro
   - Se generarán adeudos según periodicidad
   - Aparecerá en reportes y consultas

3. **Licencia:**
   - Si se capturó número de licencia, queda vinculada
   - Si no, puede vincularse posteriormente

4. **Multas:**
   - Se podrán registrar infracciones
   - Se vincularán al número de estacionamiento

### Validaciones de Integridad

#### Durante el Alta

✓ **No Duplicados:** Sistema valida número único de estacionamiento
✓ **Predio Válido:** Cuenta predial debe existir y estar activa
✓ **Propietario Registrado:** RFC debe estar en tabla de personas
✓ **Categoría Válida:** Debe existir en catálogo
✓ **Fechas Lógicas:** Fecha inicial ≤ Fecha vencimiento

#### Después del Alta

✓ **Adeudo Creado:** Se verifica generación de adeudo inicial
✓ **ID Generado:** Se confirma que se obtuvo ID del nuevo registro
✓ **Consecutivo Actualizado:** Número para siguiente alta se incrementa

---

## Proceso de Búsqueda de Propietario

### ¿Cómo funciona?

1. **Usuario captura en campo RFC**
   - Mínimo 4 caracteres
   - Puede ser inicio del RFC

2. **Usuario hace doble clic en campo RFC**
   - Se abre panel de búsqueda
   - Se muestra en parte superior del formulario

3. **Sistema ejecuta búsqueda**

```pascal
QryPersonaRFC.Active := false;
QryPersonaRFC.ParamByName('rfc').AsString := trim(mxFlatEdit2.Text) + '%';
QryPersonaRFC.Active := true;
```

4. **Se muestra grid con resultados**
   - Columnas: RFC, Nombre
   - Usuario puede navegar por registros

5. **Usuario selecciona propietario correcto**
   - Hace clic en botón "Seleccionar"

6. **Sistema aplica selección**

```pascal
mxFlatFloatEdit2.Text := QryPersonaRFCrfc.Value;
sPanel3.Visible := false;  // Cierra panel de búsqueda
mxFlatFloatEdit4.SetFocus;  // Pasa a siguiente campo
```

### Query de Búsqueda

```sql
SELECT
    id_esta_persona,
    rfc,
    nombre
FROM personas_rfc
WHERE rfc LIKE :rfc
ORDER BY rfc
```

---

## Proceso de Validación de Predio

### ¿Cómo funciona?

1. **Usuario captura cuenta predial**
2. **Usuario presiona botón "Validar"**
3. **Sistema ejecuta SP de consulta**

```pascal
sp_conspredio.Close;
sp_conspredio.ParamByName('opc').AsInteger := 2;
sp_conspredio.ParamByName('dato').AsString := mxFlatFloatEdit1.Text;
sp_conspredio.Open;
```

4. **Sistema valida respuesta**

```pascal
if sp_consprediostatus.Value > 0 then
    ShowMessage('Cuenta Predial Incorrecta o Cancelada')
else
begin
    // Asigna sector según recaudadora
    if sp_conspredioRecaud.Value = 1 then
        sLabel20.Caption := 'Sector: Juarez';
    if sp_conspredioRecaud.Value = 2 then
        sLabel20.Caption := 'Sector: Reforma';
    if sp_conspredioRecaud.Value = 3 then
        sLabel20.Caption := 'Sector: Libertad';
    if sp_conspredioRecaud.Value = 4 then
        sLabel20.Caption := 'Sector: Hidalgo';

    // Carga datos de ubicación
    sEdit1.Text := sp_consprediocalle.Value;
    sEdit2.Text := sp_conspredionumext.Value;
end;
```

5. **Se habilita botón "Ver en Mapa"** (opcional)

---

## Visualización Cartográfica

### Acceso al Visor

**Botón:** "Ver en Mapa"

**Funcionalidad:**

```pascal
spanel4.Align := alClient;
spanel4.Visible := true;
WebBrowser1.Navigate('http://192.168.4.20:8080/Visor/index.html#user=123&session=se123&clavePredi0=' +
    sp_consprediocvecatastral.Value);
```

**Componentes:**
- Panel que ocupa todo el formulario
- WebBrowser embebido
- URL del visor cartográfico municipal
- Parámetro: Clave catastral del predio

**Para cerrar:**
- Botón "Cerrar Mapa"
- Regresa al formulario de captura

---

## Generación de Estado de Cuenta Inicial

### ¿Cuándo se genera?

Inmediatamente después de registrar el alta exitosa

### Datos Incluidos

**Encabezado:**
- Datos del estacionamiento
- Número asignado
- Nombre del propietario
- Ubicación

**Adeudos:**
- Concepto: "Solicitud: [número]"
- Año/Mes: Fecha de alta
- Importe: Costo de forma

### Proceso

```pascal
with spubreports.pubreportsFrm do
begin
    // Consulta datos del estacionamiento
    qry_esta.Close;
    qry_esta.ParamByName('numesta').AsInteger := StrToInt(mxFlatFloatEdit3.Text);
    qry_esta.Open;

    // Consulta adeudos
    Qry_adeudo.Close;
    Qry_adeudo.ParamByName('opc').Value := 2;
    Qry_adeudo.ParamByName('pubid').Value := Query1idnvo.Value;
    Qry_adeudo.ParamByName('axo').Value := FormatDateTime('yyyy', Date);
    Qry_adeudo.ParamByName('mes').Value := 12;
    Qry_adeudo.Open;

    // Imprime reporte
    ppPubEdoCta.Print;
end;
```

---

## Manejo de Número Consecutivo

### Al Iniciar Formulario

```pascal
if query2.Active = false then
    query2.Active := true;

// Obtiene último número y propone siguiente
mxFlatFloatEdit3.Text := IntToStr((query2numesta.Value + 1));

// Muestra en etiqueta
sLabel16.Caption := 'Ultimo No.Estacionamiento: ' + Query2numesta.AsString;

query2.Active := false;
```

### Query de Último Número

```sql
SELECT MAX(numesta) as numesta
FROM pubmain_esta
```

### Después de Alta Exitosa

```pascal
// Actualiza número para siguiente registro
if query2.Active = false then
    query2.Active := true;

mxFlatFloatEdit3.Text := IntToStr((query2numesta.Value + 1));
sLabel16.Caption := 'Ultimo No.Estacionamiento: ' + Query2numesta.AsString;

query2.Active := false;
```

---

## Cálculo de Costo de Forma

### Consulta de Tarifa

```pascal
if qry_costoforma.Active = false then
    qry_costoforma.Active := true;
```

### Uso en Alta

```pascal
QryAltaForma.ParamByName('ade_importe').AsInteger :=
    qry_costoformacosto_forma.AsInteger;
```

**Nota:** El costo es determinado por una tabla de tarifas vigentes, puede variar según ejercicio fiscal.

---

## Usuarios del Sistema

### Usuario Operativo (Ventanilla)
- Recibe solicitudes de estacionamientos
- Captura datos del trámite
- Valida documentación
- Genera estado de cuenta inicial

**Requisitos:**
- Conocimiento de catálogo de categorías
- Capacidad de validar documentos
- Manejo de cuenta predial
- Interpretación de RFC

### Usuario Administrativo
- Supervisa altas correctas
- Verifica vinculación con predios
- Autoriza casos especiales
- Valida datos técnicos

---

## Consideraciones Especiales

### 1. **Fecha de Vencimiento**

Originalmente estaba fija:
```pascal
// Versión original
query1.ParamByName('fecha_vencimiento').AsDate := StrToDate('31/12/2012');
```

Modificado a:
```pascal
// Modificado por Gilberto Moreno 29/11/2016
query1.ParamByName('fecha_vencimiento').AsDate := sDateEdit3.Date;
```

Ahora es configurable por el usuario.

### 2. **Número de Licencia**

Es opcional en el alta:
- Se puede capturar si ya se tiene asignada
- Se puede dejar en 0 y asignar después
- Campo `axolicencias` se inicializa en 0

### 3. **Sector Catastral**

Se determina automáticamente según la recaudadora del predio:
- 1 → 'J' (Juárez)
- 2 → 'R' (Reforma)
- 3 → 'L' (Libertad)
- 4 → 'H' (Hidalgo)

### 4. **Categoría**

Debe seleccionarse del catálogo, determina:
- Tipo de establecimiento
- Posibles costos futuros
- Clasificación para reportes

### 5. **Cupo (Cajones)**

- Campo obligatorio
- Número entero
- Representa capacidad del estacionamiento
- Puede modificarse después con oficios

---

## Mensajes del Sistema

### Mensajes de Validación

- "Minimo 4 caracteres para realizar la Busqueda"
- "No tiene le Propietario"
- "No tiene la cuenta predial asignada correctamente, verifique"
- "No tiene asignada la categoria, verifique"
- "No tiene asignada los cajones, verifique"
- "Cuenta Predial Incorrecta o Cancelada"

### Mensajes de Confirmación

- Resultado del Query1resultstr.Value
  * Si éxito: "Alta realizada correctamente" (o similar)
  * Si error: Mensaje descriptivo del error

---

## Resumen Ejecutivo

Este módulo es el **punto de entrada** al padrón de estacionamientos públicos. Su correcto funcionamiento es crítico para:

**Aspectos Clave:**
- Asignación única de número de estacionamiento
- Validación de cuenta predial activa
- Vinculación correcta con propietario
- Generación automática de primer adeudo
- Integración con sistema catastral

**Beneficios:**
- Proceso ordenado y sistematizado
- Validaciones que previenen errores
- Generación automática de documentos
- Trazabilidad desde el origen
- Vinculación multi-sistema (catastro, licencias, personas)

**Recomendaciones Operativas:**
- Verificar documentación antes de capturar
- Validar que cuenta predial corresponda a la ubicación física
- Confirmar identidad del propietario (RFC correcto)
- Asignar categoría correcta desde el inicio
- Entregar estado de cuenta al contribuyente
- Archivar solicitud con número asignado

**Impacto a Futuro:**
- Los datos capturados aquí serán base para todas las operaciones futuras
- Errores en el alta pueden requerir modificaciones complejas
- La vinculación con predio es crítica para ubicación y facturación
- El número de estacionamiento es permanente e identificador único
