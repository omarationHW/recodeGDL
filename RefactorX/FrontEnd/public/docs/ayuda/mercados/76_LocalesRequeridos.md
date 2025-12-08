# Documentación Técnica - LocalesRequeridos.pas

**Sistema:** Mercados de Guadalajara
**Módulo:** Reportes y Consultas
**Archivo:** LocalesRequeridos.pas
**Tipo:** Formulario de Consulta
**Fecha de Análisis:** 2025-11-04

---

## 1. INFORMACIÓN GENERAL

### 1.1 Propósito del Módulo
Este módulo permite consultar y generar reportes de locales que tienen notificaciones y/o requerimientos emitidos desde un año específico, hasta un periodo determinado de adeudo.

### 1.2 Alcance Funcional
- Consulta de locales con notificaciones/requerimientos emitidos
- Filtrado por mercado, año de emisión y periodo de adeudo
- Exportación de resultados a Excel
- Visualización de folios de notificaciones

### 1.3 Dependencias Principales
```
ModuloBD         - Módulo de datos principal
RptAdeudosLocales - Reportes de adeudos
Menu             - Menú principal del sistema
DateUtils        - Utilidades de manejo de fechas
```

---

## 2. ANÁLISIS TÉCNICO

### 2.1 Componentes Visuales Principales

**Formulario: TFrmLocalesRequeridos**
```
- FlatCboxMercado: TFlatComboBox          -> Selección de mercado
- axoemitido: TFlatSpinEditInteger        -> Año de emisión de requerimiento
- axoade: TFlatSpinEditInteger            -> Año de adeudo
- mesade: TFlatSpinEditInteger            -> Mes de adeudo
- ExDBGrid1: TExDBGrid                    -> Grilla de resultados
- SaveDialog1: TSaveDialog                 -> Diálogo para exportar
```

### 2.2 Estructuras de Datos

**Stored Procedure: Axoemitidos**
```pascal
Campos:
- mercado: TStringField          -> Nombre del mercado
- rec: TIntegerField             -> ID de recaudadora
- merc: TIntegerField            -> ID de mercado
- seccion: TStringField          -> Sección del local
- local: TIntegerField           -> Número de local
- letra: TStringField            -> Letra del local
- bloque: TStringField           -> Bloque del local
- adeudo: TCurrencyField         -> Monto de adeudo
- folios: TStringField           -> Folios de notificaciones
```

**Query: QryMerc**
```pascal
Campos:
- oficina: TSmallintField
- num_mercado_nvo: TSmallintField
- categoria: TSmallintField
- descripcion: TStringField
- cuenta_ingreso: TIntegerField
```

### 2.3 Variables Globales
```pascal
Laxo, Lperiodo, contrec1: integer
Lporcentaje: double
Lopc, folios: string
renta: double
alo, mes, dia: word
multas, gastos: currency
```

---

## 3. ANÁLISIS DE FUNCIONES

### 3.1 FormShow
```pascal
procedure TFrmLocalesRequeridos.FormShow(Sender: TObject);
```
**Propósito:** Inicialización del formulario al mostrarse.

**Proceso:**
1. Obtiene la fecha actual del sistema
2. Carga la lista de mercados en el combo
3. Establece valores por defecto:
   - Año de emisión: 2013
   - Año de adeudo: año actual
   - Mes de adeudo: mes actual
4. Deshabilita el botón de exportación

**Interacciones:**
- Lee fecha del servidor desde DMGral.FechaHora
- Carga catálogo de mercados desde QryMerc
- Llena FlatCboxMercado con descripción de mercados

### 3.2 FlatButton4Click (Consultar)
```pascal
procedure TFrmLocalesRequeridos.FlatButton4Click(Sender: TObject);
```
**Propósito:** Ejecutar la consulta de locales con requerimientos.

**Parámetros del SP:**
```pascal
pmerc: SmallInt  -> ID del mercado seleccionado
paxo: SmallInt   -> Año de emisión del requerimiento
paxoa: SmallInt  -> Año límite de adeudo
pmesa: SmallInt  -> Mes límite de adeudo
```

**Proceso:**
1. Cierra el stored procedure si está activo
2. Asigna parámetros desde los controles
3. Ejecuta el stored procedure
4. Habilita el botón de exportación

### 3.3 FlatButton3Click (Exportar)
```pascal
procedure TFrmLocalesRequeridos.FlatButton3Click(Sender: TObject);
```
**Propósito:** Exportar resultados a Excel.

**Proceso:**
1. Establece el encabezado del reporte
2. Ejecuta la exportación mediante SxDbGrid2Excel1

**Formato del encabezado:**
```
"LOCALES CON NOTIFICACIONES Y/O REQUERIMIENTOS EMITIDOS DESDE [AÑO]"
```

### 3.4 FormClose
```pascal
procedure TFrmLocalesRequeridos.FormClose(Sender: TObject; var Action: TCloseAction);
```
**Propósito:** Limpieza al cerrar el formulario.

**Proceso:**
1. Cierra el stored procedure Axoemitidos si está activo
2. Habilita el menú principal (JvLookOut1)
3. Libera el formulario (caFree)

---

## 4. MODELO DE DATOS

### 4.1 Consultas Principales

**Stored Procedure: Axoemitidos**
```sql
-- Parámetros de entrada:
-- @pmerc: ID del mercado
-- @paxo: Año de emisión del requerimiento
-- @paxoa: Año hasta el cual se considera adeudo
-- @pmesa: Mes hasta el cual se considera adeudo

-- Retorna locales con:
-- - Notificaciones/requerimientos emitidos desde @paxo
-- - Que tengan adeudos hasta @paxoa-@pmesa
-- - Del mercado específico o todos
-- - Concatenación de folios de notificaciones
```

### 4.2 Relaciones de Datos

```
ta_11_locales (Locales)
    ↓
ta_11_adeudo_local (Adeudos)
    ↓
ta_11_requerimientos (Requerimientos/Notificaciones)
    ↓
SP: Axoemitidos (Resultado consolidado)
```

---

## 5. FLUJO DE PROCESOS

### 5.1 Flujo de Consulta de Locales Requeridos

```
[INICIO]
    ↓
[FormShow]
    ↓
[Usuario selecciona mercado]
    ↓
[Usuario establece año emisión]
    ↓
[Usuario establece periodo adeudo]
    ↓
[Click Consultar - FlatButton4Click]
    ↓
[Ejecuta SP Axoemitidos con parámetros]
    ↓
[Muestra resultados en grilla]
    ↓
[Habilita botón Exportar]
    ↓
[Usuario puede exportar a Excel]
    ↓
[FIN]
```

---

## 6. CONSIDERACIONES TÉCNICAS

### 6.1 Validaciones Implementadas
- Ninguna validación explícita antes de consultar
- El SP maneja mercado "000" o específico

### 6.2 Manejo de Errores
- Sin manejo explícito de errores en el código
- Depende de manejo de excepciones de Delphi

### 6.3 Rendimiento
- Consulta basada en Stored Procedure (eficiente)
- Carga completa de resultados en memoria
- No hay paginación de resultados

### 6.4 Seguridad
- Control de acceso a nivel de menú
- Usuario tomado de variable global GloId_usuario
- Sin validaciones específicas en el formulario

---

## 7. MEJORAS POTENCIALES

### 7.1 Mejoras Sugeridas

**Alta Prioridad:**
1. Agregar validación antes de consultar (campos obligatorios)
2. Implementar manejo de errores con try-except
3. Agregar indicador de progreso para consultas largas
4. Validar que existe información antes de exportar

**Media Prioridad:**
5. Agregar filtros adicionales (por sección, por monto)
6. Implementar paginación de resultados
7. Permitir vista previa antes de exportar
8. Agregar totales y subtotales en el reporte

**Baja Prioridad:**
9. Permitir ordenamiento por columnas en la grilla
10. Implementar búsqueda rápida en resultados
11. Guardar criterios de búsqueda preferidos
12. Exportar a diferentes formatos (PDF, CSV)

### 7.2 Refactorización Recomendada

```pascal
// Validación antes de consultar
procedure ValidarParametros;
begin
  if FlatCboxMercado.ItemIndex < 0 then
    raise Exception.Create('Debe seleccionar un mercado');

  if axoade.Value < axoemitido.Value then
    raise Exception.Create('El año de adeudo no puede ser menor al año de emisión');
end;

// Manejo de errores en consulta
procedure ConsultarConManejo;
begin
  try
    ValidarParametros;
    Axoemitidos.Close;
    Axoemitidos.ParamByName('pmerc').AsSmallInt := GetMercadoId;
    // ... resto de parámetros
    Axoemitidos.Open;

    if Axoemitidos.IsEmpty then
      ShowMessage('No se encontraron locales con los criterios especificados')
    else
      FlatButton3.Enabled := True;
  except
    on E: Exception do
      ShowMessage('Error al consultar: ' + E.Message);
  end;
end;
```

---

## 8. IMPACTO EN EL NEGOCIO

### 8.1 Valor para el Negocio
- **Crítico**: Permite identificar locales con notificaciones pendientes
- Facilita seguimiento de cobro judicial
- Ayuda en planificación de recuperación de cartera

### 8.2 Usuarios Afectados
- Personal de cobranza
- Área jurídica
- Gerencia de mercados

### 8.3 Frecuencia de Uso
- Uso regular (mensual)
- Reportes para seguimiento legal

---

## 9. DEPENDENCIAS DEL SISTEMA

### 9.1 Módulos que Dependen de Este
- RptAdeudosLocales (reportes relacionados)

### 9.2 Módulos de los que Depende
```
ModuloBD          -> Acceso a datos
Menu              -> Navegación principal
DateUtils         -> Manejo de fechas
```

### 9.3 Componentes de Terceros
```
TFlatButton       -> Botones con estilo
TFlatSpinEdit     -> Controles numéricos
TFlatComboBox     -> Listas desplegables
ExDBGrid          -> Grilla mejorada
SxDbGrid2Excel    -> Exportación a Excel
```

---

## 10. HISTORIAL DE CAMBIOS

### Versión Actual
- Año de emisión por defecto: 2013
- Filtro por mercado, año emisión y periodo adeudo
- Exportación a Excel

### Cambios Potenciales Identificados
- Actualizar año por defecto de 2013 a configurable
- Agregar validaciones de entrada
- Mejorar manejo de errores

---

## 11. INFORMACIÓN ADICIONAL

### 11.1 Archivos Relacionados
- LocalesRequeridos.dfm (diseño visual)
- RptAdeudosLocales.pas (reportes)

### 11.2 Stored Procedures Utilizados
- Axoemitidos (consulta principal)

### 11.3 Tablas Involucradas
- ta_11_locales
- ta_11_adeudo_local
- ta_11_requerimientos
- ta_11_mercados

### 11.4 Notas Técnicas
- El año 2013 está hardcodeado como año base
- No hay límite de registros en la consulta
- La exportación usa el componente SxDbGrid2Excel
- Los folios se concatenan en el SP como string

---

**Documentado por:** Sistema de Análisis Automático
**Fecha:** 2025-11-04
**Versión del Documento:** 1.0
