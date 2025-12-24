# Consulta de Anuncios del Año 2000 (Sistema 400)

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite consultar información de anuncios publicitarios que fueron registrados en el sistema anterior (año 2000, sistema 400). Muestra datos históricos de anuncios antiguos para referencia administrativa y verificación de antecedentes.

### ¿Para qué sirve en el proceso administrativo?
- Consulta información histórica de anuncios del sistema año 2000
- Visualiza datos completos de anuncios registrados en sistema anterior
- Muestra historial de pagos de anuncios antiguos
- Facilita verificación de antecedentes de anuncios publicitarios
- Proporciona referencia para renovaciones y regularizaciones
- Permite validar información histórica

### ¿Quiénes lo utilizan?
- Personal de Padrón y Licencias
- Personal de ventanilla
- Inspectores municipales
- Personal de archivo y consulta
- Personal de cobranza

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

1. **Inicio de consulta**
   - Sistema activa pestaña 1 por defecto (TabSheet1)
   - Usuario ingresa número de anuncio del sistema 400
   - Presiona ENTER o botón "Buscar"

2. **Búsqueda en sistema antiguo**
   - Sistema cierra queries anteriores:
     - pagoAnun400
     - Anun400
   - Ejecuta consulta con parámetro: número de anuncio

3. **Carga de información**
   - Si existe el anuncio:
     - Carga datos completos en dos pestañas
     - Carga información de pagos asociados
   - Si no existe:
     - Muestra pestañas vacías

4. **Visualización en pestañas**

   **TabSheet1 - Información del Anuncio (Parte 1):**
   - Datos básicos del anuncio
   - Información del propietario/licencia
   - Características del anuncio
   - Ubicación
   - Fechas relevantes
   - Aproximadamente 50+ campos de información

   **TabSheet2 - Información del Anuncio (Parte 2) y Pagos:**
   - Datos adicionales del anuncio
   - Información complementaria
   - Grid con historial de pagos
   - Detalle de conceptos pagados

5. **Navegación**
   - Usuario puede usar DBNavigator para navegar entre registros
   - Puede cambiar entre pestañas para ver diferentes secciones de datos

### ¿Qué información requiere el usuario?
- **Número de anuncio del sistema 400** (obligatorio): Identificador del anuncio en el sistema del año 2000

### ¿Qué validaciones se realizan?

1. **Validación de existencia**
   - Verifica que el número de anuncio exista en tabla anun400
   - Si no existe, no muestra datos

2. **Formato de entrada**
   - Solo acepta valores numéricos
   - Presionar ENTER ejecuta búsqueda automáticamente

### ¿Qué documentos genera?
Ninguno. Este es un módulo de consulta histórica que solo visualiza información.

## Tablas de Base de Datos

### Tablas que Consulta

1. **anun400**
   - Tabla con anuncios del sistema año 2000
   - Contiene información completa de anuncios históricos:
     - Número de anuncio
     - Datos de la licencia asociada
     - Información del propietario
     - RFC y CURP
     - Domicilio del propietario
     - Teléfono, email
     - Ubicación del anuncio
     - Tipo de anuncio
     - Medidas y características
     - Área del anuncio
     - Número de caras
     - Texto del anuncio
     - Fabricante
     - Fechas de otorgamiento y baja
     - Estado del anuncio
     - Observaciones
     - Y múltiples campos adicionales (95+ campos de información)

2. **pagoAnun400**
   - Tabla con pagos asociados a anuncios del sistema 400
   - Registros históricos de pagos
   - Conceptos pagados
   - Montos y fechas de pago

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
1. **Consulta histórica**: Permite verificar antecedentes de anuncios
2. **Referencia para regularización**: Proporciona información de anuncios anteriores

## Flujo de Trabajo

```
INICIO
  ↓
Activar TabSheet1 (Datos del anuncio parte 1)
  ↓
Usuario ingresa número de anuncio 400
  ↓
Presiona ENTER o botón "Buscar"
  ↓
Cerrar queries:
  - pagoAnun400
  - Anun400
  ↓
Ejecutar consulta con parámetro:
  - anuncio = número ingresado
  ↓
Abrir query Anun400
  ↓
Abrir query pagoAnun400
  ↓
¿Encontró datos? → NO → Mostrar pestañas vacías
  ↓ SÍ
Mostrar información en TabSheet1:
  (Aproximadamente 50 campos de datos)
  ↓
Mostrar información en TabSheet2:
  (Más campos de datos del anuncio)
  ↓
Mostrar pagos en grid de TabSheet2:
  (Historial de pagos)
  ↓
Usuario puede:
  - Ver datos
  - Navegar entre registros (DBNavigator)
  - Cambiar entre pestañas
  ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Sistema antiguo (año 2000)**
   - Datos históricos del sistema previo
   - Estructura diferente al sistema actual
   - Algunos anuncios pueden estar descontinuados

2. **Solo lectura**
   - No permite modificar datos históricos
   - Cambios deben hacerse en sistema actual si el anuncio migró

3. **Información extensa**
   - Más de 95 campos de información
   - Datos distribuidos en dos pestañas
   - Incluye información muy detallada del anuncio

4. **Referencia histórica**
   - Útil para consultar antecedentes
   - Ayuda en procesos de renovación
   - Permite validar información de anuncios antiguos

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
  - anun400
  - pagoAnun400

### Recomendaciones de uso

1. **Para consultas históricas**
   - Verificar si anuncio tenía registro previo
   - Consultar ubicación anterior del anuncio
   - Validar antigüedad del anuncio
   - Revisar historial de pagos

2. **Para renovaciones**
   - Comparar datos actuales con históricos
   - Validar continuidad del propietario
   - Verificar cambios en características del anuncio
   - Revisar si hay adeudos antiguos

3. **Para regularizaciones**
   - Localizar anuncios que deben regularizarse
   - Verificar datos para actualización a sistema nuevo
   - Validar información antes de migrar

4. **Interpretación de datos**
   - Considerar que datos son del año 2000
   - Validar si anuncio migró a sistema actual
   - Cruzar información con inspección física cuando sea necesario

### Información principal que muestra

**Pestaña 1 - Información básica:**
- Número de anuncio 400
- Datos de licencia asociada
- Información del propietario
- Ubicación del anuncio
- Tipo y clasificación del anuncio
- Medidas (medidas1, medidas2)
- Área total del anuncio
- Número de caras
- Texto del anuncio
- Fabricante
- Fechas importantes
- Estado del anuncio
- Y aproximadamente 40+ campos más

**Pestaña 2 - Información complementaria y pagos:**
- Datos adicionales del anuncio
- Información técnica
- Características especiales
- Grid con historial de pagos:
  - Fecha de pago
  - Concepto
  - Monto
  - Referencia
