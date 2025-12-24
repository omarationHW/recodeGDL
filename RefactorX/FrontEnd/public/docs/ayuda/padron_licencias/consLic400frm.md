# Consulta de Licencias del Año 2000 (Sistema 400)

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite consultar información de licencias que fueron registradas en el sistema anterior (año 2000, sistema 400). Muestra datos históricos de licencias antiguas que aún están vigentes o que sirven como referencia administrativa.

### ¿Para qué sirve en el proceso administrativo?
- Consulta información de licencias del sistema anterior (año 2000)
- Visualiza historial completo de licencias antiguas
- Muestra datos de pagos realizados en sistema previo
- Facilita la verificación de antecedentes de establecimientos
- Permite validar información histórica para renovaciones
- Proporciona referencia para migración de datos

### ¿Quiénes lo utilizan?
- Personal de Padrón y Licencias
- Personal de ventanilla
- Personal de archivo y consulta
- Supervisores que requieren información histórica
- Personal de cobranza

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

1. **Inicio de consulta**
   - Usuario ingresa número de licencia del sistema 400
   - Presiona ENTER o botón "Buscar"

2. **Búsqueda en sistema antiguo**
   - Sistema consulta tabla lic400 (licencias año 2000)
   - Busca por número de licencia

3. **Carga de información**
   - Si existe la licencia:
     - Carga datos completos en dos pestañas
     - Carga información de pagos asociados
   - Si no existe:
     - Muestra pestañas vacías

4. **Visualización en pestañas**
   - **TabSheet1 - Datos de la licencia:**
     - Información general del establecimiento
     - Datos del propietario
     - Ubicación
     - Giro comercial
     - Fechas relevantes
     - Datos de otorgamiento

   - **TabSheet2 - Pagos:**
     - Grid con historial de pagos
     - Detalle de cada pago realizado
     - Conceptos pagados
     - Fechas de pago

5. **Navegación de registros**
   - Usuario puede usar DBNavigator para:
     - Ir al primer registro
     - Registro anterior
     - Registro siguiente
     - Último registro

### ¿Qué información requiere el usuario?
- **Número de licencia del sistema 400** (obligatorio): Identificador de la licencia en el sistema del año 2000

### ¿Qué validaciones se realizan?

1. **Validación de existencia**
   - Verifica que el número de licencia exista en tabla lic400
   - Si no existe, no muestra datos (pestañas vacías)

2. **Formato de entrada**
   - Solo acepta valores numéricos
   - Presionar ENTER ejecuta la búsqueda automáticamente

### ¿Qué documentos genera?
Ninguno. Este es un módulo de consulta histórica que solo visualiza información.

## Tablas de Base de Datos

### Tablas que Consulta

1. **lic400**
   - Tabla con licencias del sistema año 2000
   - Contiene aproximadamente 36 campos con información de:
     - Número de licencia antigua
     - Propietario
     - RFC
     - CURP
     - Domicilio del propietario
     - Teléfono
     - Email
     - Ubicación del establecimiento
     - Números exterior e interior
     - Colonia
     - Giro comercial
     - Superficie construida y autorizada
     - Número de cajones
     - Número de empleados
     - Fechas de otorgamiento y consejo
     - Estado de la licencia
     - Observaciones
     - Y otros datos históricos

2. **pagoLic400**
   - Tabla con pagos asociados a licencias del sistema 400
   - Registros de pagos históricos
   - Conceptos pagados
   - Montos y fechas

### Tablas que Modifica
**Ninguna**. Este módulo es de solo lectura.

## Stored Procedures
Este módulo no utiliza stored procedures. Realiza consultas directas mediante queries parametrizadas.

## Impacto y Repercusiones

### ¿Qué registros afecta?
Ninguno. Es un módulo de solo consulta.

### ¿Qué cambios de estado provoca?
Ninguno. No realiza cambios en el sistema.

### ¿Qué documentos/reportes genera?
Ninguno. Solo muestra información en pantalla.

### ¿Qué validaciones de negocio aplica?
1. **Consulta histórica**: Permite verificar antecedentes de establecimientos
2. **Referencia para renovaciones**: Proporciona información de licencias anteriores

## Flujo de Trabajo

```
INICIO
  ↓
Activar pestaña 1 (Datos de licencia)
  ↓
Usuario ingresa número de licencia 400
  ↓
Presiona ENTER o botón "Buscar"
  ↓
Cerrar queries:
  - pagoLic400
  - lic400
  ↓
Ejecutar consulta con parámetro:
  - licencia = número ingresado
  ↓
Abrir query lic400
  ↓
Abrir query pagoLic400
  ↓
¿Encontró datos? → NO → Mostrar pestañas vacías
  ↓ SÍ
Mostrar información en TabSheet1:
  (36 campos de datos)
  ↓
Mostrar pagos en TabSheet2:
  (Grid con historial)
  ↓
Usuario puede:
  - Ver datos
  - Navegar entre registros (DBNavigator)
  - Cambiar de pestaña
  ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Sistema antiguo (año 2000)**
   - Datos históricos del sistema previo
   - Estructura de datos diferente al sistema actual
   - Algunas licencias pueden estar descontinuadas

2. **Solo lectura**
   - No permite modificar datos históricos
   - Cambios deben hacerse en sistema actual si la licencia migró

3. **Información de referencia**
   - Útil para consultar antecedentes
   - Ayuda en procesos de renovación
   - Permite validar información histórica

4. **DBNavigator habilitado**
   - Permite navegar entre múltiples resultados
   - Útil si hay varios registros

### Restricciones

1. **Datos históricos**
   - Información puede estar desactualizada
   - Refleja estado al año 2000
   - No se sincroniza con sistema actual

2. **Solo consulta**
   - No se pueden editar datos
   - No se pueden agregar nuevos registros
   - No se pueden eliminar registros

3. **Formato antiguo**
   - Estructura de datos del sistema 400
   - Algunos campos pueden no tener equivalente en sistema actual

### Permisos necesarios

- Acceso al módulo de Padrón y Licencias
- Permisos de lectura a tablas:
  - lic400
  - pagoLic400

### Recomendaciones de uso

1. **Para consultas históricas**
   - Verificar si establecimiento tenía licencia previa
   - Consultar giro anterior del local
   - Validar antigüedad del negocio
   - Revisar historial de pagos

2. **Para renovaciones**
   - Comparar datos actuales con históricos
   - Validar continuidad del propietario
   - Verificar cambios de giro
   - Revisar si hay adeudos antiguos

3. **Para aclaraciones**
   - Consultar información cuando contribuyente pregunta por licencia antigua
   - Validar números de licencia del sistema previo
   - Buscar referencia de establecimientos antiguos

4. **Interpretación de datos**
   - Considerar que datos son del año 2000
   - Validar si licencia migró a sistema actual
   - Cruzar información con archivo físico si es necesario

### Campos principales que muestra

**Pestaña 1 - Información de licencia:**
- Número de licencia 400
- Datos del titular (nombre, RFC, CURP)
- Domicilio del propietario
- Teléfono y email
- Ubicación del establecimiento
- Giro comercial
- Zona y subzona
- Superficie construida y autorizada
- Número de cajones de estacionamiento
- Número de empleados
- Fecha de otorgamiento
- Fecha de consejo
- Estado de la licencia
- Observaciones
- Y aproximadamente 20+ campos más

**Pestaña 2 - Pagos:**
- Historial de pagos en formato grid
- Fecha de cada pago
- Concepto pagado
- Monto
- Referencia del pago
