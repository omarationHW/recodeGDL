# CuotasEnergia.pas - Sistema de Mercados de Guadalajara

## Información General
**Módulo:** Cuotas de Energía Eléctrica
**Archivo:** CuotasEnergia.pas
**Tipo:** Formulario de Consulta
**Fecha de Análisis:** 2025-11-04

## Propósito
Formulario para la gestión y visualización de las cuotas de energía eléctrica (kilowatts) aplicables en los mercados. Permite consultar, insertar y modificar los importes de energía eléctrica por año y periodo bimestral.

---

## Estructura de Datos

### Tabla Principal
- **ta_11_kilowhatts**: Tabla de cuotas de energía eléctrica

### Campos del Query Principal (QryCuotaEnergia)
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id_kilowhatts | Integer | Identificador único |
| axo | SmallInt | Año de aplicación |
| periodo | SmallInt | Periodo bimestral (1-6) |
| importe | Currency | Importe de la cuota |
| fecha_alta | DateTime | Fecha de registro |
| id_usuario | Integer | Usuario que registró |
| usuario | String | Nombre del usuario |

---

## Componentes del Formulario

### Componentes Visuales
1. **ExDBGrid1**: Grilla con listado de cuotas de energía
2. **FlatButton1**: Botón "Nuevo" - Inserta nueva cuota
3. **FlatButton2**: Botón "Modificar" - Edita cuota seleccionada
4. **FlatButton3**: Botón "Salir" - Cierra el formulario
5. **AutorizaEnergia**: Control de autorización de usuario

### Paneles
- **FlatPnlInferior**: Panel inferior con botones
- **FlatPnlCentral**: Panel central con grid de datos

---

## Funcionalidad Principal

### Procedimientos y Funciones

#### `FormCreate`
```pascal
procedure TFrmCuotasEnergia.FormCreate(Sender: TObject);
```
**Propósito:** Inicializa el formulario al crearlo
**Proceso:**
- Ejecuta el procedimiento `refresco` para cargar datos

#### `FormShow`
```pascal
procedure TFrmCuotasEnergia.FormShow(Sender: TObject);
```
**Propósito:** Configura el formulario al mostrarlo
**Proceso:**
- Establece el ID de usuario actual
- Valida autorización del usuario

#### `FormActivate`
```pascal
procedure TFrmCuotasEnergia.FormActivate(Sender: TObject);
```
**Propósito:** Refresca datos al activar el formulario
**Proceso:**
- Ejecuta `refresco` para actualizar la información

#### `refresco`
```pascal
procedure TFrmCuotasEnergia.refresco;
```
**Propósito:** Actualiza los datos del query
**Proceso:**
1. Cierra el query si está activo
2. Abre el query para cargar datos actualizados

#### `FlatButton1Click` - Insertar Nueva Cuota
```pascal
procedure TFrmCuotasEnergia.FlatButton1Click(Sender: TObject);
```
**Propósito:** Inicia el proceso de inserción de una nueva cuota
**Lógica:**
1. Se posiciona en el primer registro
2. Calcula el siguiente periodo:
   - Si periodo ≤ 5: Incrementa periodo en 1
   - Si periodo > 5: Periodo = 1 y año + 1
3. Llama al formulario de mantenimiento con modo 'I' (Insertar)
4. Refresca los datos

**Ejemplo:**
- Si último registro es: Año 2024, Periodo 3
- Nueva cuota será: Año 2024, Periodo 4
- Si último registro es: Año 2024, Periodo 6
- Nueva cuota será: Año 2025, Periodo 1

#### `FlatButton2Click` - Modificar Cuota
```pascal
procedure TFrmCuotasEnergia.FlatButton2Click(Sender: TObject);
```
**Propósito:** Permite modificar una cuota existente
**Proceso:**
1. Obtiene datos del registro seleccionado
2. Llama al formulario de mantenimiento con modo 'M' (Modificar)
3. Pasa parámetros: id_kilowhatts, año, periodo, importe
4. Refresca los datos al regresar

#### `FlatButton3Click` - Salir
```pascal
procedure TFrmCuotasEnergia.FlatButton3Click(Sender: TObject);
```
**Propósito:** Cierra el formulario
**Proceso:**
1. Cierra el query
2. Cierra el formulario

#### `FormClose`
```pascal
procedure TFrmCuotasEnergia.FormClose(Sender: TObject; var Action: TCloseAction);
```
**Propósito:** Limpia recursos al cerrar
**Proceso:**
1. Cierra el query si está activo
2. Habilita el menú principal (JvLookOut1)
3. Libera el formulario (caFree)

---

## Flujo de Trabajo

### Consulta de Cuotas
```
1. Usuario abre el formulario
   ↓
2. Sistema valida autorización
   ↓
3. Se cargan las cuotas de energía en el grid
   ↓
4. Usuario visualiza año, periodo e importes
```

### Inserción de Nueva Cuota
```
1. Usuario hace clic en "Nuevo"
   ↓
2. Sistema calcula siguiente periodo
   ↓
3. Abre formulario de mantenimiento (modo Insertar)
   ↓
4. Usuario captura importe
   ↓
5. Sistema graba en ta_11_kilowhatts
   ↓
6. Refresca listado
```

### Modificación de Cuota
```
1. Usuario selecciona cuota en grid
   ↓
2. Usuario hace clic en "Modificar"
   ↓
3. Abre formulario de mantenimiento (modo Modificar)
   ↓
4. Usuario edita importe
   ↓
5. Sistema actualiza ta_11_kilowhatts
   ↓
6. Refresca listado
```

---

## Modelo de Datos

### Periodos Bimestrales
- **Periodo 1**: Enero-Febrero
- **Periodo 2**: Marzo-Abril
- **Periodo 3**: Mayo-Junio
- **Periodo 4**: Julio-Agosto
- **Periodo 5**: Septiembre-Octubre
- **Periodo 6**: Noviembre-Diciembre

---

## Dependencias

### Units Utilizados
- **ModuloBD**: Módulo de base de datos
- **Menu**: Menú principal del sistema
- **CuotasEnergiaMntto**: Formulario de mantenimiento de cuotas
- **Autoriza**: Control de autorización de usuarios

### Componentes de Terceros
- **TFlatPanel**: Paneles planos
- **TFlatButton**: Botones planos
- **ExDBGrid**: Grid extendido para bases de datos
- **TAutoriza**: Componente de autorización

---

## Seguridad

### Control de Acceso
- **Autorización por Usuario**: El componente `AutorizaEnergia` valida permisos
- **Validación en FormShow**: Se verifica autorización antes de mostrar datos
- **Auditoría**: Cada registro guarda id_usuario y fecha_alta

---

## Notas Técnicas

### Gestión de Consultas
- Query principal se cierra/abre en cada operación para garantizar datos actuales
- Uso del procedimiento `refresco` centraliza la actualización de datos

### Cálculo de Periodos
La lógica de cálculo del siguiente periodo garantiza:
- Continuidad en la secuencia de periodos
- Cambio automático de año al completar 6 periodos
- Facilita la captura secuencial de cuotas

### Integración con Otros Módulos
- Este formulario define las cuotas base
- El módulo **EmisionEnergia** utiliza estas cuotas para generar recibos
- Las cuotas se aplican en el módulo de **Adeudos de Energía**

---

## Mejoras Sugeridas

1. **Validación de Duplicados**: Verificar que no exista cuota para mismo año/periodo
2. **Rango de Periodos**: Validar que periodo esté entre 1 y 6
3. **Confirmación de Modificación**: Agregar diálogo de confirmación antes de modificar
4. **Búsqueda y Filtros**: Implementar búsqueda por año o periodo
5. **Histórico**: Mostrar comparativo de cuotas entre años
6. **Exportación**: Permitir exportar cuotas a Excel

---

## Conclusión
El módulo **CuotasEnergia** es fundamental para la gestión de cobros de energía eléctrica en los mercados, permitiendo mantener actualizadas las tarifas bimestrales que se aplican a los locales comerciales. Su integración con el módulo de mantenimiento proporciona una interfaz limpia y eficiente para la administración de estas cuotas.
