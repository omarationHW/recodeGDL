# CuotasEnergiaMntto.pas - Sistema de Mercados de Guadalajara

## Información General
**Módulo:** Mantenimiento de Cuotas de Energía
**Archivo:** CuotasEnergiaMntto.pas
**Tipo:** Formulario Modal de Mantenimiento
**Fecha de Análisis:** 2025-11-04

## Propósito
Formulario modal para insertar y modificar las cuotas de energía eléctrica. Permite capturar el año, periodo bimestral e importe de la tarifa de kilowatts aplicable a los mercados.

---

## Estructura de Datos

### Tabla de Operación
- **ta_11_kilowhatts**: Tabla de cuotas de energía eléctrica

### Campos Manejados
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id_kilowhatts | Integer | Identificador único (autoincremental) |
| axo | SmallInt | Año de aplicación |
| periodo | SmallInt | Periodo bimestral (1-6) |
| importe | Currency | Importe de la cuota de energía |
| fecha_alta | DateTime | Fecha y hora de registro (current) |
| id_usuario | Integer | Usuario que registra |

---

## Componentes del Formulario

### Controles de Entrada
1. **FlatSpinEditaxo**: SpinEdit para capturar año
2. **FlatSpinEditperiodo**: SpinEdit para capturar periodo (1-6)
3. **FlatEdtCuota**: Edit para capturar importe de la cuota
4. **FlatEdtControl**: Edit (solo lectura) muestra el ID de control

### Botones
1. **FlatButton1**: Botón "Aceptar" - Graba los datos
2. **FlatButton2**: Botón "Cancelar" - Cierra sin grabar

### Paneles
- **FlatPnlSup**: Panel superior con controles de entrada
- **FlatPnlInf**: Panel inferior con botones de acción

---

## Variables Globales del Módulo

```pascal
var
  Lcontrol: integer;      // ID de control (para modificación)
  Laxo, Lperiodo: integer; // Año y periodo
  Limporte: double;        // Importe de la cuota
  Lopc: string;           // Opción: 'I'=Insertar, 'M'=Modificar
  alo, mes, dia: word;    // Fecha actual decodificada
```

---

## Funcionalidad Principal

### Procedimientos y Funciones

#### `Inicio` - Método de Invocación
```pascal
procedure TFrmCuotasEnergiaMntto.Inicio(control:integer; axo,periodo:integer;
                                        importe:double; opc:string);
```
**Propósito:** Método público para iniciar el formulario
**Parámetros:**
- `control`: ID del registro (0 para insertar)
- `axo`: Año de la cuota
- `periodo`: Periodo bimestral
- `importe`: Importe de la cuota (0 para insertar)
- `opc`: Modo de operación ('I' o 'M')

**Proceso:**
1. Asigna parámetros a variables locales
2. Crea instancia del formulario
3. Muestra formulario como modal (ShowModal)

#### `FormShow`
```pascal
procedure TFrmCuotasEnergiaMntto.FormShow(Sender: TObject);
```
**Propósito:** Configura el formulario al mostrarse
**Proceso:**

**Para Modo Insertar ('I'):**
1. Obtiene fecha actual del sistema (DMGral.FechaHora)
2. Establece año actual por defecto
3. Establece mes actual por defecto
4. Recibe año y periodo calculados desde formulario padre
5. Deshabilita campo de control

**Para Modo Modificar ('M'):**
1. Carga el ID de control
2. Carga año y periodo
3. Carga importe actual
4. Deshabilita campo de control
5. Deshabilita campos de año y periodo (no modificables)

#### `FlatButton1Click` - Grabar Datos
```pascal
procedure TFrmCuotasEnergiaMntto.FlatButton1Click(Sender: TObject);
```
**Propósito:** Procesa la grabación de datos

**Validaciones:**
1. Verifica que la cuota no esté vacía
2. Verifica que la cuota no sea cero
3. Muestra mensaje de error si falla validación

**Para Modo Insertar ('I'):**
```sql
INSERT INTO ta_11_kilowhatts VALUES (
  0,                              -- id_kilowhatts (autoincremental)
  [Año],                          -- axo
  [Periodo],                      -- periodo
  [Importe],                      -- importe
  current,                        -- fecha_alta
  [GloId_usuario]                 -- id_usuario
)
```

**Para Modo Modificar ('M'):**
```sql
UPDATE ta_11_kilowhatts SET
  importe = [Nuevo Importe],
  fecha_alta = current,
  id_usuario = [GloId_usuario]
WHERE id_kilowhatts = [Control]
  AND axo = [Año]
  AND periodo = [Periodo]
```

**Control Transaccional:**
1. Inicia transacción: `DMGral.DbIngresos.StartTransaction`
2. Ejecuta SQL
3. Si tiene éxito: `DMGral.DbIngresos.Commit`
4. Si falla: `DMGral.DbIngresos.Rollback` y muestra error
5. Cierra el formulario

#### `FlatButton2Click` - Cancelar
```pascal
procedure TFrmCuotasEnergiaMntto.FlatButton2Click(Sender: TObject);
```
**Propósito:** Cancela la operación
**Proceso:**
- Cierra el formulario sin grabar cambios

#### `FormClose`
```pascal
procedure TFrmCuotasEnergiaMntto.FormClose(Sender: TObject; var Action: TCloseAction);
```
**Propósito:** Limpia recursos al cerrar
**Proceso:**
1. Cierra el query si está activo
2. Libera el formulario (caFree)

#### `FlatEdtCuotaKeyPress` - Validación de Entrada
```pascal
procedure TFrmCuotasEnergiaMntto.FlatEdtCuotaKeyPress(Sender: TObject; var Key: Char);
```
**Propósito:** Valida entrada numérica del importe
**Proceso:**
- Utiliza `DMGral.NInvalidVal` para validar formato numérico
- Parámetros: 10 dígitos enteros, 6 decimales
- Bloquea teclas no válidas

---

## Flujo de Trabajo

### Inserción de Nueva Cuota
```
1. Usuario abre desde CuotasEnergia con siguiente periodo
   ↓
2. FormShow configura año/periodo calculado
   ↓
3. Usuario captura importe
   ↓
4. Usuario hace clic en Aceptar
   ↓
5. Sistema valida que importe no sea cero
   ↓
6. Ejecuta INSERT con transacción
   ↓
7. Si OK: Commit y cierra
   Si Error: Rollback y muestra mensaje
```

### Modificación de Cuota Existente
```
1. Usuario selecciona cuota desde CuotasEnergia
   ↓
2. FormShow carga datos actuales
   ↓
3. Año y periodo bloqueados (no modificables)
   ↓
4. Usuario modifica importe
   ↓
5. Usuario hace clic en Aceptar
   ↓
6. Sistema valida que importe no sea cero
   ↓
7. Ejecuta UPDATE con transacción
   ↓
8. Si OK: Commit y cierra
   Si Error: Rollback y muestra mensaje
```

---

## Validaciones Implementadas

### Validación de Datos
1. **Cuota no vacía**: `FlatEdtCuota.Text <> ''`
2. **Cuota no cero**: `FlatEdtCuota.Text <> '0'`
3. **Formato numérico**: Validación en KeyPress (10 enteros, 6 decimales)

### Mensajes de Error
- "La Cuota no contiene Información" - Campo vacío o cero
- "Error al Grabar Cuota de Energia" - Error en INSERT
- "Error al modificar la Cuota de Energia Electrica" - Error en UPDATE

---

## Control Transaccional

### Manejo de Transacciones
```pascal
try
  DMGral.DbIngresos.StartTransaction;
  // Ejecuta SQL
  QryCuotaEnergiaMntto.ExecSQL;
  DMGral.DbIngresos.Commit;
except
  DMGral.DbIngresos.Rollback;
  ShowMessage('Error...');
end;
```

**Beneficios:**
- Garantiza consistencia de datos
- Permite rollback en caso de error
- Protege integridad de la base de datos

---

## Modelo de Datos

### Estructura de ta_11_kilowhatts
```
┌─────────────────┬──────────┬─────────┬──────────┬─────────────┬────────────┐
│ id_kilowhatts   │ axo      │ periodo │ importe  │ fecha_alta  │ id_usuario │
├─────────────────┼──────────┼─────────┼──────────┼─────────────┼────────────┤
│ INTEGER (PK)    │ SMALLINT │ SMALLINT│ CURRENCY │ DATETIME    │ INTEGER    │
└─────────────────┴──────────┴─────────┴──────────┴─────────────┴────────────┘
```

### Reglas de Negocio
1. **Periodo válido**: 1-6 (bimestral)
2. **Importe obligatorio**: Debe ser > 0
3. **No duplicados**: Un solo registro por año/periodo
4. **Auditoría**: Registra usuario y fecha

---

## Dependencias

### Units Utilizados
- **ModuloBD**: Acceso a base de datos y funciones globales
- **DBTables**: Componentes de base de datos
- **TFlatPanel, TFlatButton, TFlatEdit**: Componentes visuales

### Variables Globales
- **GloId_usuario**: ID del usuario actual (desde módulo principal)
- **DMGral**: Módulo de datos general

---

## Notas Técnicas

### Formato de Entrada Numérica
- **Enteros**: Hasta 10 dígitos
- **Decimales**: Hasta 6 posiciones
- **Validación**: En tiempo real (evento KeyPress)

### Uso de CURRENT
La palabra clave `current` de Firebird/Interbase obtiene:
- Fecha y hora actual del servidor
- Garantiza consistencia en fecha de registro
- No depende del reloj de la estación de trabajo

### Campos No Modificables
En modo Modificar:
- **Año**: No se puede cambiar
- **Periodo**: No se puede cambiar
- **Razón**: Son parte de la clave natural del registro

---

## Seguridad

### Auditoría
- **id_usuario**: Registra quién capturó/modificó
- **fecha_alta**: Registra cuándo se hizo el cambio
- **Nota**: En modificación, se actualiza fecha y usuario

---

## Mejoras Sugeridas

1. **Validación de Periodo**: Verificar que esté entre 1 y 6
2. **Comparación con Anterior**: Mostrar cuota del periodo anterior
3. **Calculadora de Incremento**: Aplicar % de incremento automático
4. **Validación de Duplicados**: Verificar que no exista el registro antes de insertar
5. **Historial de Cambios**: Registrar modificaciones en tabla de auditoría
6. **Confirmación de Cambios**: Diálogo de confirmación antes de grabar
7. **Formato Moneda**: Mostrar símbolo de moneda en el campo de importe

---

## Conclusión
El módulo **CuotasEnergiaMntto** proporciona una interfaz sencilla y eficiente para el mantenimiento de las tarifas de energía eléctrica. Su diseño modal, validaciones en tiempo real y manejo transaccional garantizan la integridad de los datos capturados.
